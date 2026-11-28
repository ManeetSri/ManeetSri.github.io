import { test } from 'node:test';
import assert from 'node:assert/strict';
import { busiestSpan, expandRequests, rateLimiterFrames, rateLimiterSchema } from './rateLimiter.js';

const verdicts = (props) => rateLimiterFrames(props).at(-1).results.map((result) => result.allowed);
const allowedTimes = (props) => rateLimiterFrames(props).at(-1).results.filter((result) => result.allowed).map((result) => result.time);

test('bursts expand and every frame has a message', () => {
    assert.deepEqual(expandRequests([0, { at: 1, count: 3 }, { at: 2 }]), [0, 1, 1, 1, 2]);
    const frames = rateLimiterFrames({ algorithm: 'sliding-log', window: 1, limit: 2, requests: [0, 0.5, 0.7] });
    assert.equal(frames.length, 5);
    frames.forEach((frame) => assert.ok(frame.message.length > 0));
});

test('a token bucket allows a burst of `capacity`, then the refill rate', () => {
    const props = { algorithm: 'token-bucket', capacity: 5, refillPerSecond: 2, requests: [{ at: 0, count: 8 }, 0.4, 0.5, 1, 1.4] };
    // 5 tokens, then empty; one token back by 0.5s, another by 1s; 0.4 has only 0.8 of one
    assert.deepEqual(verdicts(props), [true, true, true, true, true, false, false, false, false, true, true, false]);
    // The last request, at 1.4s, finds 0.8 of a token
    assert.ok(Math.abs(rateLimiterFrames(props).at(-2).state.tokens - 0.8) < 1e-9);
    // Tokens never exceed the capacity, however long the gap
    const idle = rateLimiterFrames({ algorithm: 'token-bucket', capacity: 3, refillPerSecond: 1, requests: [0, 100, 100, 100, 100] });
    assert.deepEqual(idle.at(-1).results.map((result) => result.allowed), [true, true, true, true, false]);
});

test('a leaky bucket queues up to `capacity` and lets them out at the leak rate', () => {
    const frames = rateLimiterFrames({ algorithm: 'leaky-bucket', capacity: 3, leakPerSecond: 2, requests: [{ at: 0, count: 5 }, 1.2] });
    const results = frames.at(-1).results;
    assert.deepEqual(results.map((result) => result.allowed), [true, true, true, false, false, true]);
    assert.deepEqual(results.filter((result) => result.allowed).map((result) => result.leaves), [0.5, 1, 1.5, 2]);
    // Output is smooth: never more than 2 leave in any second
    assert.ok(busiestSpan(results.filter((result) => result.allowed).map((result) => result.leaves), 1).count <= 2);
});

test('a fixed window lets twice the limit through across a boundary', () => {
    const props = { algorithm: 'fixed-window', window: 1, limit: 5, requests: [{ at: 0.9, count: 6 }, { at: 1.1, count: 6 }] };
    assert.deepEqual(verdicts(props), [true, true, true, true, true, false, true, true, true, true, true, false]);
    assert.equal(busiestSpan(allowedTimes(props), 1).count, 10);
    assert.match(rateLimiterFrames(props).at(-1).message, /10 were allowed within one 1s span .* 2× the limit/);
});

test('a sliding log never allows more than the limit in any window', () => {
    const props = { algorithm: 'sliding-log', window: 1, limit: 5, requests: [{ at: 0.9, count: 6 }, { at: 1.1, count: 6 }, { at: 1.95, count: 3 }] };
    assert.deepEqual(verdicts(props), [true, true, true, true, true, false, false, false, false, false, false, false, true, true, true]);
    assert.ok(busiestSpan(allowedTimes(props), 1).count <= 5);
    // Random arrivals: the limit always holds
    let seed = 3;
    const next = () => { seed = (seed * 1103515245 + 12345) % 2147483648; return seed / 2147483648; };
    const times = Array.from({ length: 150 }, () => Math.round(next() * 1000) / 100).sort((a, b) => a - b);
    assert.ok(busiestSpan(allowedTimes({ algorithm: 'sliding-log', window: 1, limit: 4, requests: times }), 1).count <= 4);
});

test('a sliding counter weights the previous window by how much still overlaps', () => {
    const frames = rateLimiterFrames({ algorithm: 'sliding-counter', window: 1, limit: 4, requests: [{ at: 0.5, count: 4 }, 1.25, 1.5, 1.75] });
    const results = frames.at(-1).results.map((result) => result.allowed);
    // At 1.25: 4 × 0.75 + 0 = 3 < 4 → allowed; at 1.5: 4 × 0.5 + 1 = 3 → allowed; at 1.75: 4 × 0.25 + 2 = 3 → allowed
    assert.deepEqual(results, [true, true, true, true, true, true, true]);
    const tight = rateLimiterFrames({ algorithm: 'sliding-counter', window: 1, limit: 4, requests: [{ at: 0.5, count: 4 }, 1.1, 1.2] });
    // At 1.1: 4 × 0.9 = 3.6 → allowed (now 1); at 1.2: 4 × 0.8 + 1 = 4.2 → rejected
    assert.deepEqual(tight.at(-1).results.map((result) => result.allowed), [true, true, true, true, true, false]);
    assert.ok(Math.abs(tight.at(-3).state.estimate - 3.6) < 1e-9);
});

test('busiestSpan counts a half-open span', () => {
    assert.deepEqual(busiestSpan([0, 0.5, 1, 1.2, 1.9], 1), { count: 3, from: 0.5, to: 1.2 });
    assert.deepEqual(busiestSpan([0, 1, 2], 1), { count: 1, from: 0, to: 0 });
    assert.equal(busiestSpan([], 1).count, 0);
});

test('rateLimiter schema accepts good settings', () => {
    assert.equal(rateLimiterSchema({ algorithm: 'token-bucket', capacity: 5, refillPerSecond: 1, requests: [0, 0, 1] }), true);
    assert.equal(rateLimiterSchema({ algorithm: 'leaky-bucket', capacity: 3, leakPerSecond: 0.5, requests: [{ at: 0, count: 4 }] }), true);
    assert.equal(rateLimiterSchema({ algorithm: 'sliding-counter', window: 60, limit: 100, requests: [1, 2, 3], title: 'Per minute' }), true);
});

test('rateLimiter schema explains what is wrong', () => {
    const cases = [
        [{ requests: [0] }, /`algorithm` is missing/],
        [{ algorithm: 'gcra', requests: [0] }, /unknown `algorithm` "gcra"/],
        [{ algorithm: 'token-bucket', capacity: 5, requests: [0] }, /`refillPerSecond` is missing/],
        [{ algorithm: 'token-bucket', capacity: 0, refillPerSecond: 1, requests: [0] }, /`capacity` must be at least 1/],
        [{ algorithm: 'token-bucket', capacity: 5, refillPerSecond: 1, limit: 5, requests: [0] }, /token-bucket doesn't use `limit`; it takes `capacity` and `refillPerSecond`/],
        [{ algorithm: 'leaky-bucket', capacity: 5, refillPerSecond: 1, requests: [0] }, /leaky-bucket doesn't use `refillPerSecond`/],
        [{ algorithm: 'fixed-window', capacity: 5, window: 1, requests: [0] }, /fixed-window doesn't use `capacity`/],
        [{ algorithm: 'fixed-window', window: 0, limit: 5, requests: [0] }, /`window` must be more than 0/],
        [{ algorithm: 'sliding-log', window: 1, limit: 2.5, requests: [0] }, /`limit` must be a whole number/],
        [{ algorithm: 'sliding-log', window: 1, limit: 2, requests: [] }, /`requests` must be a list/],
        [{ algorithm: 'sliding-log', window: 1, limit: 2, requests: [1, 0.5] }, /time order: requests\[1\]/],
        [{ algorithm: 'sliding-log', window: 1, limit: 2, requests: [-1] }, /requests\[0\] must be a time/],
        [{ algorithm: 'sliding-log', window: 1, limit: 2, requests: [{ at: 1, count: 0 }] }, /`count` must be a whole number of at least 1/],
        [{ algorithm: 'sliding-log', window: 1, limit: 2, requests: [{ at: 1, count: 500 }] }, /keep it to 200 or fewer/],
        [{ algorithm: 'sliding-log', window: 1, limit: 2, requests: [0], burst: 3 }, /unknown field `burst`/],
    ];
    cases.forEach(([props, pattern]) => {
        const verdict = rateLimiterSchema(props);
        assert.equal(typeof verdict, 'string', `expected a problem for ${JSON.stringify(props)}`);
        assert.match(verdict, pattern);
    });
});
