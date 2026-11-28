import { test } from 'node:test';
import assert from 'node:assert/strict';
import { fmix32, fnv1a32, hashRingFrames, hashRingSchema, ringHash } from './hashRing.js';

const manyKeys = (count) => Array.from({ length: count }, (_, index) => `user:${index + 1}`);

test('FNV-1a 32-bit matches the published test vectors', () => {
    assert.equal(fnv1a32(''), 0x811c9dc5);
    assert.equal(fnv1a32('a'), 0xe40c292c);
    assert.equal(fnv1a32('foobar'), 0xbf9cf968);
    assert.equal(fmix32(0), 0);
    assert.equal(ringHash('a', 'fnv1a'), 0xe40c292c);
    assert.equal(ringHash('a'), fmix32(0xe40c292c));
});

test('raw FNV-1a bunches similar keys; the mixed hash spreads them', () => {
    const octants = (mode) => new Set(manyKeys(20).map((key) => Math.floor((ringHash(key, mode) / 2 ** 32) * 8))).size;
    assert.ok(octants('fnv1a') <= 3, `raw FNV-1a used ${octants('fnv1a')} octants`);
    assert.ok(octants('mixed') >= 6, `mixed used ${octants('mixed')} octants`);
});

test('frames place nodes, then keys, then one frame per step and a summary', () => {
    const frames = hashRingFrames({ nodes: ['A', 'B', 'C'], vnodes: 2, keys: manyKeys(10), steps: [{ add: 'D' }, { remove: 'A' }] });
    assert.equal(frames.length, 5);
    assert.equal(frames[0].showKeys, false);
    assert.equal(frames[0].points.length, 6);
    assert.equal(frames[2].points.filter((point) => point.fresh).length, 2);
    assert.equal(frames[3].points.filter((point) => point.gone).length, 2);
    frames.forEach((frame) => assert.ok(frame.message.length > 0));
    // Shares of the ring add up to one
    frames.forEach((frame) => assert.ok(Math.abs(Object.values(frame.shares).reduce((sum, share) => sum + share, 0) - 1) < 1e-9));
});

test('adding a node moves only keys to it, about K/N of them; modulo moves most', () => {
    const keys = manyKeys(2000);
    const frames = hashRingFrames({ nodes: ['A', 'B', 'C'], vnodes: 8, keys, steps: [{ add: 'D' }] });
    const step = frames[2];
    const moved = step.keys.filter((key) => key.from !== null);
    assert.equal(step.moved, moved.length);
    assert.ok(moved.every((key) => key.owner === 'D'), 'every moved key goes to the new node');
    assert.equal(moved.length, step.loads.D, 'D owns exactly the keys that moved');
    const share = moved.length / keys.length;
    assert.ok(share > 0.12 && share < 0.4, `moved ${share} of the keys, expected about 1/4`);
    assert.ok(step.naiveMoved / keys.length > 0.65, `modulo moved ${step.naiveMoved / keys.length}`);
});

test('removing a node moves only its keys', () => {
    const keys = manyKeys(500);
    const frames = hashRingFrames({ nodes: ['A', 'B', 'C', 'D'], vnodes: 4, keys, steps: [{ remove: 'B' }] });
    const before = frames[1];
    const after = frames[2];
    assert.equal(after.moved, before.loads.B);
    after.keys.forEach((key, index) => {
        if (before.keys[index].owner === 'B') assert.equal(key.from, 'B');
        else assert.equal(key.from, null);
    });
    assert.equal(after.loads.B, undefined);
});

test('a key belongs to the first point clockwise, wrapping past the top', () => {
    const frames = hashRingFrames({ nodes: ['A', 'B'], keys: manyKeys(30) });
    const { points, keys } = frames[1];
    const sorted = [...points].sort((a, b) => a.at - b.at);
    keys.forEach((key) => {
        const owner = (sorted.find((point) => point.at >= key.at) ?? sorted[0]).node;
        assert.equal(key.owner, owner);
    });
});

test('hashRing schema accepts good settings', () => {
    assert.equal(hashRingSchema({ nodes: ['A', 'B', 'C'], vnodes: 3, keys: ['user:1', 'user:2', 7], steps: [{ add: 'D' }, { remove: 'B' }, { add: 'B' }] }), true);
    assert.equal(hashRingSchema({ nodes: ['A'], keys: ['k'], hash: 'fnv1a' }), true);
});

test('hashRing schema explains what is wrong', () => {
    const base = { nodes: ['A', 'B'], keys: ['k1', 'k2'] };
    const cases = [
        [{ keys: ['k'] }, /`nodes` must be a list/],
        [{ ...base, nodes: ['A', 'A'] }, /node "A" is listed twice/],
        [{ ...base, vnodes: 0 }, /`vnodes` must be at least 1/],
        [{ ...base, vnodes: 9 }, /`vnodes` must be at most 8/],
        [{ ...base, keys: [] }, /`keys` must be a list/],
        [{ ...base, keys: ['k', 'k'] }, /key "k" is listed twice/],
        [{ ...base, keys: manyKeys(61) }, /60 is the most/],
        [{ ...base, steps: [{ add: 'A' }] }, /adds A, which is already on the ring/],
        [{ ...base, steps: [{ remove: 'Z' }] }, /removes Z, which isn't on the ring/],
        [{ nodes: ['A'], keys: ['k'], steps: [{ remove: 'A' }] }, /would remove the last node/],
        [{ ...base, steps: [{ add: 'C', remove: 'A' }] }, /must be \{ add: name \} or \{ remove: name \}/],
        [{ ...base, steps: [{ join: 'C' }] }, /must be \{ add: name \}/],
        [{ ...base, steps: ['C', 'D', 'E', 'F', 'G', 'H', 'I'].map((name) => ({ add: name })) }, /9 different nodes appear; at most 8/],
        [{ ...base, hash: 'md5' }, /unknown `hash` "md5"/],
        [{ ...base, replicas: 2 }, /unknown field `replicas`/],
    ];
    cases.forEach(([props, pattern]) => {
        const verdict = hashRingSchema(props);
        assert.equal(typeof verdict, 'string', `expected a problem for ${JSON.stringify(props)}`);
        assert.match(verdict, pattern);
    });
});
