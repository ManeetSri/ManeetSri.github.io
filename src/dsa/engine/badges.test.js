import { test } from 'node:test';
import assert from 'node:assert/strict';
import { lessons } from '../data/curriculum.js';
import { badgesFor, longestStreak, masteryByPart } from './badges.js';

const earned = (facts) => badgesFor(facts).filter((badge) => badge.isEarned).map((badge) => badge.id);

test('nothing is earned at the start', () => {
    assert.deepEqual(earned({}), []);
});

test('finishing Part 0 earns its badge', () => {
    const done = Object.fromEntries(lessons.filter((lesson) => lesson.part === 0).map((lesson) => [lesson.id, { completedAt: 1 }]));
    assert.ok(earned({ lessons: done }).includes('part-0'));
});

test('streak, problem, checkpoint, mock and review badges', () => {
    assert.ok(earned({ streak: 7 }).includes('streak-7'));
    assert.ok(earned({ bestStreak: 30 }).includes('streak-30'));
    const solved = Object.fromEntries(Array.from({ length: 10 }, (_, index) => [`p${index}`, { status: 'solved' }]));
    assert.ok(earned({ problems: solved }).includes('solved-10'));
    assert.ok(earned({ checkpoints: { a: { passedAt: 1 } } }).includes('checkpoint-1'));
    assert.ok(earned({ mocks: { 1: {} } }).includes('mock-1'));
    assert.ok(earned({ cards: { a: { reviews: 60 }, b: { reviews: 40 } } }).includes('reviews-100'));
});

test('longest streak finds the longest run of consecutive days', () => {
    assert.equal(longestStreak(new Set(['2026-11-01', '2026-11-02', '2026-11-03', '2026-11-05', '2026-11-06'])), 3);
    assert.equal(longestStreak(new Set()), 0);
    assert.equal(longestStreak(new Set(['2026-10-31', '2026-11-01'])), 2);
});

test('mastery grows with finished lessons', () => {
    const before = masteryByPart({}).find((entry) => entry.part === 1).value;
    const done = Object.fromEntries(lessons.filter((lesson) => lesson.part === 1).map((lesson) => [lesson.id, { completedAt: 1 }]));
    const after = masteryByPart({ lessons: done }).find((entry) => entry.part === 1);
    assert.equal(before, 0);
    assert.ok(after.value >= 0.75, String(after.value));
    assert.equal(after.lessons.done, after.lessons.total);
});
