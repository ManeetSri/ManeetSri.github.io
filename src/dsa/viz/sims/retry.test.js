import { test } from 'node:test';
import assert from 'node:assert/strict';
import { retryFrames, retryRun, retrySchema, splitMix64, unitRandom } from './retry.js';

const close = (actual, expected) => assert.ok(Math.abs(actual - expected) < 1e-9, `${actual} ≈ ${expected}`);

test('SplitMix64 matches the reference outputs (and DesignKit’s SeededGenerator)', () => {
    const next = splitMix64(0);
    assert.equal(next(), 0xE220A8397B1DCDAFn);
    assert.equal(next(), 0x6E789E6AA1B965F4n);
    const unit = splitMix64(7);
    for (let index = 0; index < 1000; index += 1) {
        const value = unitRandom(unit);
        assert.ok(value >= 0 && value < 1);
    }
});

test('without jitter the waits double up to the cap', () => {
    const run = retryRun({ base: 0.5, cap: 4, attempts: 7 });
    assert.deepEqual(run.attempts.map((attempt) => attempt.wait?.delay ?? null), [0.5, 1, 2, 4, 4, 4, null]);
    assert.deepEqual(run.attempts.map((attempt) => attempt.time), [0, 0.5, 1.5, 3.5, 7.5, 11.5, 15.5]);
    assert.ok(run.attempts.every((attempt) => attempt.outcome === 'failure'));
});

test('a seed gives the same schedule every time, and another seed a different one', () => {
    const props = { base: 0.5, cap: 8, attempts: 6, jitter: 'full', seed: 42 };
    const delays = (settings) => retryRun(settings).attempts.map((attempt) => attempt.wait?.delay);
    assert.deepEqual(delays(props), delays(props));
    assert.notDeepEqual(delays(props), delays({ ...props, seed: 43 }));
});

test('each jitter stays inside its range', () => {
    for (let seed = 0; seed < 50; seed += 1) {
        const full = retryRun({ base: 1, factor: 2, cap: 10, attempts: 8, jitter: 'full', seed });
        full.attempts.filter((attempt) => attempt.wait).forEach((attempt, retry) => {
            const ceiling = Math.min(10, 2 ** retry);
            assert.ok(attempt.wait.delay >= 0 && attempt.wait.delay <= ceiling);
        });
        const equal = retryRun({ base: 1, factor: 2, cap: 10, attempts: 8, jitter: 'equal', seed });
        equal.attempts.filter((attempt) => attempt.wait).forEach((attempt, retry) => {
            const ceiling = Math.min(10, 2 ** retry);
            assert.ok(attempt.wait.delay >= ceiling / 2 && attempt.wait.delay <= ceiling);
        });
        const decorrelated = retryRun({ base: 1, cap: 10, attempts: 8, jitter: 'decorrelated', seed });
        let previous = 1;
        decorrelated.attempts.filter((attempt) => attempt.wait).forEach((attempt) => {
            assert.ok(attempt.wait.delay >= 1 && attempt.wait.delay <= Math.min(10, previous * 3) + 1e-9);
            previous = attempt.wait.delay;
        });
    }
});

test('the run stops at the first success', () => {
    const run = retryRun({ base: 1, cap: 8, attempts: 6, failUntil: 3 });
    assert.deepEqual(run.attempts.map((attempt) => attempt.outcome), ['failure', 'failure', 'success']);
    assert.equal(run.attempts.at(-1).wait, null);
    assert.equal(run.end, 3);
    assert.match(retryFrames({ base: 1, cap: 8, attempts: 6, failUntil: 3 }).at(-1).message, /Succeeded on attempt 3 at 3s/);
    assert.equal(retryRun({ base: 1, cap: 8, attempts: 3, failUntil: 1 }).attempts.length, 1);
});

test('the breaker opens, short-circuits, goes half-open and closes on a good trial', () => {
    const run = retryRun({ base: 1, factor: 2, cap: 8, attempts: 7, failUntil: 5, breaker: { threshold: 3, cooldown: 5 } });
    // Attempts at 0, 1, 3, 7, 15: three failures open it at 3 until 8; 7 is short-circuited; 15 is the trial
    assert.deepEqual(run.attempts.map((attempt) => attempt.time), [0, 1, 3, 7, 15]);
    assert.deepEqual(run.attempts.map((attempt) => attempt.outcome), ['failure', 'failure', 'failure', 'rejected', 'success']);
    assert.deepEqual(run.attempts.map((attempt) => attempt.breaker), ['closed', 'closed', 'closed', 'open', 'half-open']);
    assert.equal(run.attempts[2].change, 'opened');
    assert.equal(run.attempts[2].openUntil, 8);
    assert.equal(run.attempts[4].trial, true);
    assert.equal(run.attempts[4].change, 'closed');
    assert.deepEqual(run.segments.map((segment) => [segment.state, segment.from, segment.to]), [['closed', 0, 3], ['open', 3, 8], ['half-open', 8, 15], ['closed', 15, 15]].filter(([, from, to]) => to > from));
});

test('a failed trial opens the breaker again', () => {
    const run = retryRun({ base: 2, factor: 1, cap: 2, attempts: 8, failUntil: 0, breaker: { threshold: 2, cooldown: 3 } });
    // Attempts every 2s: fail at 0 and 2 (opens until 5); 4 rejected; 6 is a trial that fails (open until 9); 8 rejected; 10 trial
    assert.deepEqual(run.attempts.map((attempt) => attempt.outcome), ['failure', 'failure', 'rejected', 'failure', 'rejected', 'failure', 'rejected', 'failure']);
    assert.deepEqual(run.attempts.filter((attempt) => attempt.trial).map((attempt) => attempt.time), [6, 10, 14]);
    assert.equal(run.attempts[3].change, 'opened');
    close(run.attempts[3].openUntil, 9);
});

test('frames reveal one attempt at a time and every frame has a message', () => {
    const frames = retryFrames({ base: 0.5, cap: 8, attempts: 6, jitter: 'equal', failUntil: 4, breaker: { threshold: 2, cooldown: 1 } });
    assert.deepEqual(frames.map((frame) => frame.shown), [0, 1, 2, 3, 4, 4]);
    frames.forEach((frame) => assert.ok(frame.message.length > 0));
    assert.match(frames.at(-1).message, /Without jitter the attempts would land at 0, 0.5, 1.5 and 3.5 s/);
});

test('retry schema accepts good settings', () => {
    assert.equal(retrySchema({ base: 0.5, factor: 2, cap: 8, attempts: 6, jitter: 'decorrelated', seed: 1, failUntil: 4, breaker: { threshold: 3, cooldown: 10 } }), true);
    assert.equal(retrySchema({ base: 1, cap: 1, attempts: 1 }), true);
});

test('retry schema explains what is wrong', () => {
    const base = { base: 0.5, cap: 8, attempts: 6 };
    const cases = [
        [{ cap: 8, attempts: 6 }, /`base` is missing/],
        [{ ...base, base: 0 }, /`base` must be more than 0/],
        [{ ...base, cap: 0.25 }, /`cap` \(0.25\) must be at least `base` \(0.5\)/],
        [{ ...base, factor: 0.5 }, /`factor` must be at least 1/],
        [{ ...base, attempts: 0 }, /`attempts` must be at least 1/],
        [{ ...base, attempts: 50 }, /at most 20/],
        [{ ...base, jitter: 'random' }, /unknown `jitter` "random": use none, full, equal or decorrelated/],
        [{ ...base, seed: -1 }, /`seed` must be at least 0/],
        [{ ...base, seed: 1.5 }, /`seed` must be a whole number/],
        [{ ...base, failUntil: 9 }, /after the last attempt/],
        [{ ...base, breaker: 3 }, /`breaker` must be/],
        [{ ...base, breaker: { threshold: 0, cooldown: 5 } }, /breaker: `threshold` must be at least 1/],
        [{ ...base, breaker: { threshold: 2 } }, /breaker: `cooldown` is missing/],
        [{ ...base, breaker: { threshold: 2, cooldown: 5, halfOpen: 1 } }, /unknown field `halfOpen`/],
        [{ ...base, retries: 3 }, /unknown field `retries`/],
    ];
    cases.forEach(([props, pattern]) => {
        const verdict = retrySchema(props);
        assert.equal(typeof verdict, 'string', `expected a problem for ${JSON.stringify(props)}`);
        assert.match(verdict, pattern);
    });
});
