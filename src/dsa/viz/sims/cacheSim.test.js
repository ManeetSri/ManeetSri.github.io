import { test } from 'node:test';
import assert from 'node:assert/strict';
import { cacheSimFrames, cacheSimSchema, requestTimes } from './cacheSim.js';

const one = (capacity, policy, requests, extra = {}) => ({ layers: [{ name: 'Memory', capacity }], policy, requests, ...extra });
const contents = (frame, layer = 0) => frame.layers[layer].entries.map((entry) => entry.key);
const evictions = (frames) => frames.flatMap((frame) => frame.layers.flatMap((layer) => layer.gone.filter((entry) => entry.reason === 'evicted').map((entry) => entry.key)));

test('every frame has a message', () => {
    const frames = cacheSimFrames({ layers: [{ name: 'Memory', capacity: 2 }, { name: 'Disk', capacity: 3 }], ttl: 4, requests: ['a', 'b', 'c', 'a', { key: 'b', at: 9 }] });
    frames.forEach((frame) => assert.ok(typeof frame.message === 'string' && frame.message.length > 0));
});

test('plain keys arrive a second apart and `at` sets the time', () => {
    assert.deepEqual(requestTimes(['a', 'b', { key: 'c', at: 10 }, 'd', 7]).map((request) => [request.key, request.time]), [['a', 0], ['b', 1], ['c', 10], ['d', 11], ['7', 12]]);
    assert.deepEqual(requestTimes([{ key: 'a', at: 3 }, 'b']).map((request) => request.time), [3, 4]);
});

test('LRU evicts the least recently used and lists most recent first', () => {
    const frames = cacheSimFrames(one(3, 'lru', ['a', 'b', 'c', 'a', 'd', 'b', 'e']));
    // d evicts b (a was used again), then b evicts c, then e evicts a
    assert.deepEqual(evictions(frames), ['b', 'c', 'a']);
    assert.deepEqual(contents(frames.at(-1)), ['e', 'b', 'd']);
});

test('FIFO ignores hits and evicts in insertion order', () => {
    const frames = cacheSimFrames(one(3, 'fifo', ['a', 'b', 'c', 'a', 'd', 'a']));
    assert.deepEqual(evictions(frames), ['a', 'b']);
    assert.deepEqual(contents(frames.at(-1)), ['a', 'd', 'c']);
});

test('LFU evicts the least used, breaking ties by recency, and shows counts', () => {
    const frames = cacheSimFrames(one(3, 'lfu', ['a', 'a', 'b', 'b', 'c', 'd', 'e']));
    // c (1 use) goes for d, then d (1 use, more recent than nothing else at 1) goes for e
    assert.deepEqual(evictions(frames), ['c', 'd']);
    const last = frames.at(-1).layers[0].entries;
    assert.deepEqual(last.map((entry) => [entry.key, entry.count]), [['b', 2], ['a', 2], ['e', 1]]);
});

test('a hit lower down is promoted, and hit rates are per layer', () => {
    const frames = cacheSimFrames({ layers: [{ name: 'Memory', capacity: 1 }, { name: 'Disk', capacity: 3 }], origin: 'Network', requests: ['a', 'b', 'a', 'a'] });
    const final = frames.at(-1);
    assert.deepEqual(contents(final, 0), ['a']);
    assert.deepEqual(contents(final, 1), ['a', 'b']);
    // Memory: 4 lookups, 1 hit (the last a). Disk: 3 lookups (a, b, a), 1 hit (the second a).
    assert.deepEqual([final.layers[0].hits, final.layers[0].lookups], [1, 4]);
    assert.deepEqual([final.layers[1].hits, final.layers[1].lookups], [1, 3]);
    assert.equal(final.origin.fetches, 2);
    assert.deepEqual(final.timeline.map((request) => request.served), [-1, -1, 1, 0]);
    assert.ok(frames.some((frame) => frame.message.includes('Copy a up into Memory')));
});

test('TTL expiry drops entries from every layer, keeping the original expiry on promotion', () => {
    const frames = cacheSimFrames({ layers: [{ name: 'Memory', capacity: 1 }, { name: 'Disk', capacity: 3 }], ttl: 5, requests: ['a', 'b', 'a', { key: 'a', at: 5 }] });
    const expiry = frames.find((frame) => frame.layers.some((layer) => layer.gone.some((entry) => entry.reason === 'expired')));
    assert.ok(expiry, 'an expiry frame');
    assert.equal(expiry.time, 5);
    assert.deepEqual(expiry.layers.map((layer) => layer.gone.map((entry) => entry.key)), [['a'], ['a']]);
    assert.equal(frames.at(-1).timeline.at(-1).served, -1);
    assert.equal(frames.at(-1).origin.fetches, 3);
});

test('cacheSim schema accepts good settings', () => {
    assert.equal(cacheSimSchema({ layers: [{ name: 'Memory', capacity: 3 }, { name: 'Disk', capacity: 6 }], origin: 'Network', policy: 'lfu', ttl: 10, requests: ['a', 'b', { key: 'c', at: 12 }, 4] }), true);
    assert.equal(cacheSimSchema({ layers: [{ name: 'Memory', capacity: 1 }], requests: ['a'] }), true);
});

test('cacheSim schema explains what is wrong', () => {
    const base = { layers: [{ name: 'Memory', capacity: 2 }], requests: ['a'] };
    const cases = [
        [null, /expected settings/],
        [{ ...base, layers: [] }, /`layers` must be a list/],
        [{ ...base, layers: [{ name: 'Memory', capacity: 0 }] }, /layers\[0\] \(Memory\): `capacity` must be at least 1/],
        [{ ...base, layers: [{ name: 'Memory', capacity: 1.5 }] }, /whole number/],
        [{ ...base, layers: [{ capacity: 2 }] }, /layers\[0\] needs a `name`/],
        [{ ...base, layers: [{ name: 'M', capacity: 1 }, { name: 'M', capacity: 2 }] }, /two layers are called "M"/],
        [{ ...base, layers: [{ name: 'M', capacity: 1, size: 3 }] }, /unknown field `size`/],
        [{ ...base, policy: 'LRU' }, /unknown `policy` "LRU": use lru, lfu or fifo/],
        [{ ...base, ttl: 0 }, /`ttl` must be more than 0/],
        [{ ...base, origin: 'Memory' }, /like one of the layers/],
        [{ ...base, requests: [] }, /`requests` must be a list/],
        [{ ...base, requests: ['a', true] }, /requests\[1\] must be a key/],
        [{ ...base, requests: ['a', { key: 'b', at: -1 }] }, /`at` must be a time/],
        [{ ...base, requests: [{ key: 'a', at: 5 }, { key: 'b', at: 3 }] }, /time order: requests\[1\] \(b\) is at 3s/],
        [{ ...base, requests: [{ key: 'a', when: 5 }] }, /unknown field `when`/],
        [{ ...base, polcy: 'lru' }, /unknown field `polcy`/],
    ];
    cases.forEach(([props, pattern]) => {
        const verdict = cacheSimSchema(props);
        assert.equal(typeof verdict, 'string', `expected a problem for ${JSON.stringify(props)}`);
        assert.match(verdict, pattern);
    });
});
