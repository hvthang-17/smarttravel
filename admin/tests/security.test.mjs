import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { stripTypeScriptTypes } from 'node:module';

class Storage {
  values = new Map();
  getItem(key) { return this.values.get(key) ?? null; }
  setItem(key, value) { this.values.set(key, String(value)); }
  removeItem(key) { this.values.delete(key); }
}

async function app(fetch, timers = {}) {
  const localStorage = new Storage();
  const sessionStorage = new Storage();
  const window = new EventTarget();
  window.setTimeout = timers.setTimeout ?? setTimeout;
  window.clearTimeout = timers.clearTimeout ?? clearTimeout;
  const context = vm.createContext({ localStorage, sessionStorage, window, fetch,
    Headers, Response, Event, FormData, URLSearchParams, AbortController, console });
  const modules = new Map();
  const root = fileURLToPath(new URL('../src/core/', import.meta.url));
  async function load(filename) {
    if (modules.has(filename)) return modules.get(filename);
    const source = await readFile(filename, 'utf8');
    const code = stripTypeScriptTypes(source);
    const module = new vm.SourceTextModule(code, { context, identifier: filename,
      initializeImportMeta(meta) { meta.env = {}; } });
    modules.set(filename, module);
    await module.link((specifier, parent) => load(path.resolve(path.dirname(parent.identifier), `${specifier}.ts`)));
    return module;
  }
  async function imported(name) {
    const module = await load(path.join(root, name));
    if (module.status !== 'evaluated') await module.evaluate();
    return module.namespace;
  }
  return { localStorage, sessionStorage, window, imported };
}

const user = { id: 1, email: 'admin@example.test', fullName: 'Admin', role: 'ROLE_ADMIN' };
const json = (data, status = 200) => new Response(JSON.stringify({ success: status < 400, data }),
  { status, headers: { 'Content-Type': 'application/json' } });

test('offline login fails without creating an account or storing credentials', async () => {
  const env = await app(async () => { throw new TypeError('Failed to fetch'); });
  const auth = await env.imported('authApi.ts');
  await assert.rejects(auth.loginApi({ email: 'admin@smarttravel.vn', password: 'admin123' }));
  assert.equal(env.localStorage.values.size, 0);
  assert.equal(env.sessionStorage.values.size, 0);
});

test('non-remembered login authorizes every protected API including multipart uploads', async () => {
  const requests = [];
  const env = await app(async (url, options) => {
    requests.push({ url, options });
    if (url.endsWith('/auth/login')) return json({ ...user, token: 'header.payload.signature' });
    return json([]);
  });
  const auth = await env.imported('authApi.ts');
  await auth.loginApi({ email: user.email, password: 'secure-password', remember: false });
  assert.equal(env.localStorage.getItem('smarttravel_admin_token'), null);
  const destinations = await env.imported('api.ts');
  await destinations.fetchDestinations();
  const categories = await env.imported('categoryApi.ts');
  await categories.fetchCategoriesApi();
  const users = await env.imported('userApi.ts');
  await users.fetchUsersApi();
  const session = await env.imported('session.ts');
  await session.apiFetch('http://localhost:8080/api/v1/destinations/upload-image', { method: 'POST', body: new FormData() });
  for (const { options } of requests.slice(1)) assert.equal(options.headers.get('Authorization'), 'Bearer header.payload.signature');
  assert.equal(requests.at(-1).options.headers.has('Content-Type'), false);
});

test('401 clears session and emits expiry; 403 keeps session and emits permission refresh', async () => {
  let status = 401;
  const env = await app(async () => json(null, status));
  const session = await env.imported('session.ts');
  let expired = 0;
  let changed = 0;
  env.window.addEventListener(session.SESSION_EXPIRED, () => expired++);
  env.window.addEventListener(session.PERMISSIONS_CHANGED, () => changed++);
  session.setStoredAuth(user, 'header.payload.signature', false);
  await session.apiFetch('http://localhost:8080/api/v1/admin/users');
  assert.equal(session.getStoredToken(), null);
  assert.equal(expired, 1);
  status = 403;
  session.setStoredAuth(user, 'header.payload.signature');
  await session.apiFetch('http://localhost:8080/api/v1/admin/users');
  assert.equal(session.getStoredToken(), 'header.payload.signature');
  assert.equal(changed, 1);
});

test('stale 401 cannot delete a newer session', async () => {
  let resolve;
  const env = await app(() => new Promise(done => { resolve = done; }));
  const session = await env.imported('session.ts');
  session.setStoredAuth(user, 'old.payload.signature');
  const request = session.apiFetch('http://localhost:8080/api/v1/auth/profile');
  session.setStoredAuth(user, 'new.payload.signature');
  resolve(json(null, 401));
  await request;
  assert.equal(session.getStoredToken(), 'new.payload.signature');
});

test('refresh uses server role and registration never submits a chosen role', async () => {
  let submitted;
  const env = await app(async (url, options) => {
    if (url.endsWith('/register')) submitted = JSON.parse(options.body);
    return json({ ...user, role: 'ROLE_USER', token: 'server.payload.signature' });
  });
  const auth = await env.imported('authApi.ts');
  auth.setStoredAuth(user, 'cached.payload.signature');
  assert.equal((await auth.refreshSession()).role, 'ROLE_USER');
  await auth.registerApi({ email: ' USER@example.test ', password: 'secure-password', fullName: ' User ', role: 'ROLE_ADMIN' });
  assert.equal(submitted.role, undefined);
  assert.equal(submitted.email, 'user@example.test');
});

test('legacy password database and fake token are removed during session validation', async () => {
  const env = await app(async () => { throw new Error('must not call backend'); });
  env.localStorage.setItem('smarttravel_registered_users_db', 'legacy-plaintext');
  env.localStorage.setItem('smarttravel_admin_token', 'mock_jwt_token');
  const auth = await env.imported('authApi.ts');
  assert.equal(await auth.refreshSession(), null);
  assert.equal(env.localStorage.values.size, 0);
});


test('timeout aborts once, retains the session and does not automatically retry a write', async () => {
  let requests = 0;
  const env = await app((_url, options) => {
    requests++;
    return new Promise((_resolve, reject) => options.signal.addEventListener('abort',
      () => reject(new DOMException('Aborted', 'AbortError')), { once: true }));
  }, { setTimeout(callback) { queueMicrotask(callback); return 1; }, clearTimeout() {} });
  const session = await env.imported('session.ts');
  session.setStoredAuth(user, 'valid.test.token');
  await assert.rejects(session.apiFetch('/api/v1/destinations', { method: 'POST' }), /timed out/);
  assert.equal(requests, 1);
  assert.equal(session.getStoredToken(), 'valid.test.token');
});

test('login and session refresh retain the language returned by the server profile', async () => {
  const env = await app(async () => json({ ...user, token: 'valid.test.token', travelerProfile: { language: 'en' } }));
  const auth = await env.imported('authApi.ts');
  assert.equal((await auth.loginApi({ email: user.email, password: 'secret123' })).language, 'en');
  assert.equal((await auth.refreshSession()).language, 'en');
});
