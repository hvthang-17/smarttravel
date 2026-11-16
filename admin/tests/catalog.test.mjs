import test from 'node:test';
import assert from 'node:assert/strict';
import { CATALOG_CODES, requireCatalogCode, imageUrl, galleryImages, validateImageFiles } from '../src/features/destinations/catalogContract.ts';
import { buildDestinationPayload, initialDraft, scheduleDraft } from '../src/features/destinations/form/destinationForm.ts';

test('catalog accepts the six stable codes and rejects legacy or lodging codes', () => {
  for (const code of CATALOG_CODES) assert.doesNotThrow(() => requireCatalogCode(code));
  for (const code of ['HOTEL', 'Food', 'Ẩm thực', 'FOOD_1234', 'ACCOMMODATION', '']) assert.throws(() => requireCatalogCode(code));
});
test('images reject unsafe URLs, empty or duplicate galleries and more than ten images', () => {
  assert.equal(imageUrl(''), null);
  assert.equal(imageUrl('/uploads/destinations/abc-123.png'), '/uploads/destinations/abc-123.png');
  assert.equal(imageUrl('https://example.test/a.jpg'), 'https://example.test/a.jpg');
  for (const url of ['javascript:alert(1)', 'data:image/png;base64,abc', '/uploads/../secret.png', 'https://u:password@example.test/a.png']) assert.throws(() => imageUrl(url));
  assert.throws(() => galleryImages(['']));
  assert.throws(() => galleryImages(['https://example.test/a.png', 'https://example.test/a.png']));
  assert.throws(() => galleryImages(Array.from({ length: 11 }, (_, i) => `https://example.test/${i}.png`)));
});
test('upload limits match the server before sending bytes', () => {
  assert.doesNotThrow(() => validateImageFiles([{ size: 1000, type: 'image/png' }]));
  for (const files of [[], [{ size: 0, type: 'image/png' }], [{ size: 6 * 1024 * 1024, type: 'image/png' }], [{ size: 10, type: 'image/svg+xml' }], Array.from({ length: 11 }, () => ({ size: 1, type: 'image/png' })), Array.from({ length: 6 }, () => ({ size: 5 * 1024 * 1024, type: 'image/png' }))]) assert.throws(() => validateImageFiles(files));
});
test('edit can clear translations and cover, retain its hidden category and never choose another category', () => {
  const categories = [{ id: 1, name: 'Ẩm thực', code: 'FOOD', status: 'INACTIVE' }, { id: 2, name: 'Biển', code: 'BEACH', status: 'ACTIVE' }];
  const point = { name: 'Quán', categoryId: 1, latitude: 16.05, longitude: 108.2, category: 'Ẩm thực' };
  const draft = initialDraft(point, categories);
  const payload = buildDestinationPayload(draft, scheduleDraft(), categories, 1);
  assert.equal(payload.categoryId, 1); assert.equal(payload.category, 'FOOD');
  for (const field of ['nameEn', 'descriptionEn', 'imageUrl']) assert.equal(payload[field], null);
  assert.throws(() => buildDestinationPayload(draft, scheduleDraft(), categories));
  const unknown = initialDraft({ ...point, categoryId: 999, category: 'Legacy' }, categories);
  assert.equal(unknown.category, '');
  assert.throws(() => buildDestinationPayload(unknown, scheduleDraft(), categories, 999));
});
