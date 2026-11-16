import test from 'node:test';
import assert from 'node:assert/strict';
import { initialDraft, scheduleDraft, serializeSchedule, buildDestinationPayload } from '../src/features/destinations/form/destinationForm.ts';

const categories = [{ id: 1, code: 'FOOD', name: 'Ẩm thực', status: 'ACTIVE' }, { id: 2, code: 'HOTEL', name: 'Khách sạn', status: 'ACTIVE' }];
const draft = () => ({ ...initialDraft(null, categories), name: 'Quán ăn', latitude: '16.05', longitude: '108.2' });
const payload = (fields = {}, days = scheduleDraft()) => buildDestinationPayload({ ...draft(), ...fields }, days, categories);

test('blank prices and Google statistics explicitly clear to NULL', () => {
  const result = JSON.parse(JSON.stringify(payload()));
  assert.equal(result.openingSchedule, null);
  for (const field of ['priceMinVnd', 'priceMaxVnd', 'googleRating', 'googleReviewCount']) assert.equal(result[field], null);
  for (const field of ['rating', 'reviewCount', 'openingHours']) assert.equal(field in result, false);
  assert.equal(result.visitDurationMinutes, 60);
  assert.equal(result.category, 'FOOD');
  assert.equal(result.categoryId, 1);
});

test('free prices, Google decimals and translations survive payload construction', () => {
  const result = payload({ priceMinVnd: '0', priceMaxVnd: '0', rating: '4.6', reviewCount: '1200', nameEn: 'Restaurant', descriptionEn: 'English description' });
  assert.equal(result.priceMinVnd, 0);
  assert.equal(result.priceMaxVnd, 0);
  assert.equal(result.googleRating, 4.6);
  assert.equal(result.nameEn, 'Restaurant');
});

test('weekly schedule supports split shifts, 24-hour, closed and unknown days', () => {
  const days = scheduleDraft();
  days[0] = { mode: 'custom', periods: [{ start: '13:30', end: '17:00' }, { start: '08:00', end: '11:30' }] };
  days[1] = { mode: 'allDay', periods: [] };
  days[2] = { mode: 'closed', periods: [] };
  const schedule = serializeSchedule(days);
  assert.deepEqual(schedule.week['1'], [[480, 690], [810, 1020]]);
  assert.deepEqual(schedule.week['2'], [[0, 1440]]);
  assert.deepEqual(schedule.week['3'], []);
  assert.equal(schedule.week['4'], null);
  assert.deepEqual(serializeSchedule(scheduleDraft(schedule)), schedule);
});

test('overlap, invalid hours and unsplit overnight shifts are rejected', () => {
  for (const periods of [[{ start: '08:00', end: '12:00' }, { start: '11:30', end: '17:00' }], [{ start: '20:00', end: '02:00' }], [{ start: '25:00', end: '26:00' }]]) {
    const days = scheduleDraft(); days[0] = { mode: 'custom', periods };
    assert.throws(() => serializeSchedule(days));
  }
});

test('price ranges, integer counts and ratings match backend constraints', () => {
  for (const fields of [{ priceMinVnd: '20', priceMaxVnd: '10' }, { priceMinVnd: '-1' }, { priceMinVnd: '1.5' }, { rating: '0' }, { rating: '4.55' }, { reviewCount: '1.5' }, { reviewCount: '2147483648' }, { visitDurationMinutes: '0' }, { latitude: '' }, { latitude: '16abc' }]) assert.throws(() => payload(fields));
});

test('HOTEL and inactive categories cannot be submitted', () => {
  assert.throws(() => payload({ category: 'Khách sạn' }));
  assert.throws(() => buildDestinationPayload(draft(), scheduleDraft(), [{ ...categories[0], status: 'INACTIVE' }]));
});

test('edit initialization retains translations, statistics, schedule and custom duration', () => {
  const original = { id: 3, name: 'Quán ăn', nameEn: 'Restaurant', descriptionEn: 'English', categoryId: 1, latitude: 16.05, longitude: 108.2, googleRating: 4.6, googleReviewCount: 10, visitDurationMinutes: 75, status: 'ACTIVE' };
  const edited = initialDraft(original, categories);
  const result = buildDestinationPayload(edited, scheduleDraft(), categories);
  assert.equal(result.nameEn, 'Restaurant'); assert.equal(result.descriptionEn, 'English');
  assert.equal(result.googleRating, 4.6); assert.equal(result.visitDurationMinutes, 75);
});

test('missing category during edit is not silently replaced with first category', () => {
  const edited = initialDraft({ name: 'Old point', categoryId: 999, latitude: 16, longitude: 108, status: 'ACTIVE' }, categories);
  assert.equal(edited.category, '');
  assert.throws(() => buildDestinationPayload(edited, scheduleDraft(), categories));
});

import { readFileSync } from 'node:fs';
import { googleRating, googleReviewCount, averageGoogleRating, formatPrice, destinationCsvRow, smartTravelReviewLabel } from '../src/features/destinations/destinationContract.ts';

test('SmartTravel score rounds only in the display label and never borrows Google data', () => {
  assert.equal(smartTravelReviewLabel({ googleRating: 4.8, googleReviewCount: 900, appRating: null }), 'Chưa có · 0 lượt');
  assert.equal(smartTravelReviewLabel({ appRating: 13 / 3, appReviewCount: 3 }), '4.3 · 3 lượt');
});
const contract = JSON.parse(readFileSync(new URL('../../contracts/schema-sync.json', import.meta.url), 'utf8'));
test('shared contract preserves canonical NULL, schedule, zero coordinates and independent app ratings', () => {
  const point = contract.destination;
  assert.equal(googleRating(point), null);
  assert.equal(googleReviewCount(point), null);
  assert.equal(initialDraft(point, categories).rating, '');
  assert.equal(initialDraft(point, categories).reviewCount, '');
  assert.equal(averageGoogleRating([point]), null);
  assert.equal(averageGoogleRating([point, { ...point, googleRating: 4.8 }]), 4.8);
  assert.equal(googleRating({ rating: 4.2 }), 4.2);
  assert.equal(formatPrice(null, null), 'Chưa rõ giá');
  assert.equal(formatPrice(0, 0), 'Miễn phí');
  assert.match(formatPrice(null, 50000), /Tối đa/);
  assert.match(destinationCsvRow(point), /"0","0"/);
  assert.ok(!destinationCsvRow(point).includes('4.5'));
  assert.deepEqual(serializeSchedule(scheduleDraft(point.openingSchedule)), point.openingSchedule);
});
