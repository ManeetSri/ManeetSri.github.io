import { test } from 'node:test';
import assert from 'node:assert/strict';
import { problemById } from '../data/problems.js';
import { planToday } from './today.js';
import { newCard } from './srs.js';

const NOW = new Date(2026, 10, 27, 9).getTime();
const lesson = (id, minutes, extra = {}) => ({ id, title: id, minutes, status: 'ready', problems: [], ...extra });

test('lessons fill the time budget, and there is always one', () => {
    const path = [lesson('a', 20), lesson('b', 20), lesson('c', 20)];
    assert.deepEqual(planToday({ practiceById: problemById, path, minutesPerDay: 45, now: NOW }).lessons.map((item) => item.lesson.id), ['a', 'b']);
    assert.deepEqual(planToday({ practiceById: problemById, path: [lesson('big', 90)], minutesPerDay: 15, now: NOW }).lessons.map((item) => item.lesson.id), ['big']);
});

test('reviews take at most 30% of the time', () => {
    const cards = Object.fromEntries(Array.from({ length: 50 }, (_, index) => [`c${index}`, newCard({}, NOW)]));
    const plan = planToday({ practiceById: problemById, path: [], cards, minutesPerDay: 30, now: NOW });
    assert.equal(plan.reviews.due, 50);
    assert.equal(plan.reviews.planned, 9);
});

test('the plan stops at a lesson that is not written yet', () => {
    const path = [lesson('a', 10), lesson('soon', 10, { status: 'stub' }), lesson('later', 10)];
    const plan = planToday({ practiceById: problemById, path, minutesPerDay: 60, now: NOW });
    assert.deepEqual(plan.lessons.map((item) => item.lesson.id), ['a']);
    assert.equal(plan.comingSoon.id, 'soon');
});

test('lessons finished today stay in the plan, ticked', () => {
    const path = [lesson('a', 20), lesson('b', 20)];
    const plan = planToday({ practiceById: problemById, path, lessons: { a: { completedAt: NOW - 1000 } }, minutesPerDay: 30, now: NOW });
    assert.deepEqual(plan.lessons.map((item) => [item.lesson.id, item.done]), [['a', true]]);
});

test('practice comes from lessons planned or finished, skipping solved problems', () => {
    const path = [lesson('a', 10, { problems: ['hello-swift', 'largest-element'] })];
    const plan = planToday({ practiceById: problemById, path, problems: { 'hello-swift': { status: 'solved', attempts: { [NOW - 3 * 86_400_000]: { at: NOW - 3 * 86_400_000, status: 'solved' } } } }, minutesPerDay: 60, now: NOW });
    assert.deepEqual(plan.practice.map((item) => item.problem.id), ['largest-element']);
});

test('a problem solved today stays in the plan, ticked', () => {
    const path = [lesson('a', 10, { problems: ['largest-element'] })];
    const plan = planToday({ practiceById: problemById, path, lessons: { a: { completedAt: NOW - 5000 } }, problems: { 'largest-element': { status: 'solved', attempts: { [NOW - 1000]: { at: NOW - 1000, status: 'solved' } } } }, minutesPerDay: 60, now: NOW });
    assert.deepEqual(plan.practice.map((item) => [item.problem.id, item.done]), [['largest-element', true]]);
});
