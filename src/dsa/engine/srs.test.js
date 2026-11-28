import { test } from 'node:test';
import assert from 'node:assert/strict';
import { addDays, dayKey } from './dates.js';
import { dueCards, isDue, newCard, reviewCard } from './srs.js';

const NOW = new Date(2026, 10, 27, 9, 30).getTime();

test('a new card is due straight away', () => {
    assert.equal(isDue(newCard({ kind: 'card' }, NOW), NOW), true);
});

test('"Good" grows the interval 1 → 3 → ease-multiplied', () => {
    let card = newCard({}, NOW);
    card = reviewCard(card, 'good', NOW);
    assert.equal(card.interval, 1);
    assert.equal(dayKey(card.due), dayKey(addDays(NOW, 1)));
    card = reviewCard(card, 'good', card.due);
    assert.equal(card.interval, 3);
    card = reviewCard(card, 'good', card.due);
    assert.equal(card.interval, 8);
    assert.equal(card.reviews, 3);
});

test('"Again" resets the card, lowers ease and brings it back today', () => {
    let card = reviewCard(reviewCard(newCard({}, NOW), 'good', NOW), 'good', NOW);
    card = reviewCard(card, 'again', NOW);
    assert.equal(card.reps, 0);
    assert.equal(card.lapses, 1);
    assert.equal(card.ease, 2.3);
    assert.equal(isDue(card, NOW), true);
});

test('ease never drops below 1.3', () => {
    let card = newCard({}, NOW);
    for (let index = 0; index < 20; index += 1) card = reviewCard(card, 'again', NOW);
    assert.equal(card.ease, 1.3);
});

test('a card is not due before its day, and is due all of its day', () => {
    const card = reviewCard(newCard({}, NOW), 'good', NOW);
    assert.equal(isDue(card, NOW), false);
    assert.equal(isDue(card, new Date(2026, 10, 28, 0, 1).getTime()), true);
    assert.equal(isDue(card, new Date(2026, 10, 28, 23, 59).getTime()), true);
});

test('dueCards lists the most overdue first', () => {
    const cards = { a: { ...newCard({}, NOW), due: NOW - 1000 }, b: { ...newCard({}, NOW), due: NOW - 5000 }, c: reviewCard(newCard({}, NOW), 'easy', NOW) };
    assert.deepEqual(dueCards(cards, NOW).map((card) => card.id), ['b', 'a']);
});

test('unknown ratings are rejected', () => {
    assert.throws(() => reviewCard(newCard({}, NOW), 'great', NOW));
});
