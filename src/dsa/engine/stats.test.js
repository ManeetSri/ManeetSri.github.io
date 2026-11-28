import { test } from 'node:test';
import assert from 'node:assert/strict';
import { activeDays, rankFor, streakFrom, xpFrom } from './stats.js';
import { dayKey } from './dates.js';
import { dsaData } from '../data/courseData.js';

const day = (date) => new Date(2026, 10, date, 12).getTime();

test('XP adds lessons, first-try answers, solved problems and reviews', () => {
    const xp = xpFrom({
        lessons: { a: { completedAt: 1, quiz: { q1: { firstTry: true }, q2: { firstTry: false } } } },
        problems: { 'largest-element': { status: 'solved' }, 'hello-swift': { status: 'helped' } },
        cards: { c: { reviews: 3 } },
    }, dsaData);
    assert.equal(xp, 50 + 10 + 30 + 8 + 15);
});

test('a passed checkpoint is worth 200 XP, once', () => {
    assert.equal(xpFrom({ checkpoints: { m: { passedAt: 1, attempts: { 1: { at: 1 }, 2: { at: 2 } } }, n: { attempts: { 3: { at: 3 } } } } }, dsaData), 200);
});

test('testing out of a lesson earns no XP', () => {
    assert.equal(xpFrom({ lessons: { a: { testedOutAt: 1 } } }, dsaData), 0);
});

test('ranks climb with XP', () => {
    assert.equal(rankFor(0).title, 'Novice');
    assert.equal(rankFor(1999).title, 'Apprentice');
    assert.equal(rankFor(30000).next, null);
    assert.equal(rankFor(1250).progress, 0.5);
});

test('active days come from every kind of activity', () => {
    const days = activeDays({
        lessons: { a: { completedAt: day(20), quiz: { q: { at: day(21) } } } },
        problems: { p: { attempts: { [day(22)]: { at: day(22) } } } },
        cards: { c: { last: day(23) } },
        activity: { [dayKey(day(24))]: { minutes: { mac: 5 } }, [dayKey(day(25))]: { minutes: { mac: 0 } } },
    });
    assert.deepEqual([...days].sort(), [20, 21, 22, 23, 24].map((date) => dayKey(day(date))));
});

test('a streak counts back from today, or from yesterday until today is active', () => {
    const days = new Set([24, 25, 26].map((date) => dayKey(day(date))));
    assert.equal(streakFrom(days, day(26)), 3);
    assert.equal(streakFrom(days, day(27)), 3);
    assert.equal(streakFrom(days, day(28)), 0);
});
