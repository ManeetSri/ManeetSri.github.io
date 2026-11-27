import { test } from 'node:test';
import assert from 'node:assert/strict';
import { binarySearchFrames } from './binarySearch.js';
import { layoutTree, recursionFrames } from './recursion.js';
import { traceFrames } from './traceTable.js';

test('binary search finds present values and reports missing ones', () => {
    const items = [3, 8, 12, 17, 21];
    assert.equal(binarySearchFrames(items, 17).at(-1).found, 3);
    assert.equal(binarySearchFrames(items, 5).at(-1).found, null);
});

test('recursion frames compute the right answers', () => {
    assert.match(recursionFrames('factorial', [5]).at(-1).message, /= 120,/);
    assert.match(recursionFrames('fibonacci', [5]).at(-1).message, /= 5,/);
    assert.match(recursionFrames('power', [2, 5]).at(-1).message, /= 32,/);
    assert.match(recursionFrames('sumDigits', [4096]).at(-1).message, /= 19,/);
});

test('fibonacci(5) makes 15 calls, and the stack is never deeper than n', () => {
    const frames = recursionFrames('fibonacci', [5]);
    assert.equal(frames.at(-1).nodes.length, 15);
    assert.equal(Math.max(...frames.map((frame) => frame.stack.length)), 5);
    assert.equal(frames.at(-1).stack.length, 0);
});

test('exactly one call is active while the stack is not empty', () => {
    recursionFrames('fibonacci', [4]).slice(0, -1).forEach((frame) => {
        assert.equal(frame.nodes.filter((node) => node.state === 'active').length, 1);
    });
});

test('tree layout puts parents above and between their children', () => {
    const { nodes } = recursionFrames('fibonacci', [3]).at(-1);
    const { position, width, depth } = layoutTree(nodes);
    assert.equal(width, 3);
    assert.equal(depth, 3);
    assert.equal(position.get(0).x, (0.5 + 2) / 2);
});

test('trace tables match running the programs', () => {
    assert.match(traceFrames('sum').at(-1).message, /Print 21/);
    assert.match(traceFrames('largest', { numbers: [-5, -2, -8] }).at(-1).message, /Print -2/);
    assert.match(traceFrames('reverseDigits', { number: 1200 }).at(-1).message, /Print 21/);
    assert.match(traceFrames('gcd', { first: 48, second: 18 }).at(-1).message, /a = 6/);
    assert.equal(traceFrames('sum', { numbers: [1, 2, 3] }).at(-1).rows.length, 3);
});

import { arrayFrames, ARRAY_PROGRAMS } from './arrayPrograms.js';
import { linkedListFrames } from './linkedList.js';
import { stackQueueFrames } from './stackQueue.js';
import { hashOf, hashTableFrames } from './hashTable.js';

const lastRow = (name, input) => arrayFrames(name, input).at(-1).rows[0].values;

test('every array program runs and ends with a message', () => {
    ARRAY_PROGRAMS.forEach((name) => {
        const frames = arrayFrames(name);
        assert.ok(frames.length > 2, name);
        frames.forEach((frame) => assert.ok(frame.message && Number.isInteger(frame.line), name));
    });
});

test('in-place array programs leave the right result', () => {
    assert.deepEqual(lastRow('reverse', { items: [1, 2, 3, 4, 5] }), [5, 4, 3, 2, 1]);
    assert.deepEqual(lastRow('dutchFlag', { items: [2, 0, 2, 1, 1, 0] }), [0, 0, 1, 1, 2, 2]);
    assert.deepEqual(lastRow('dedupe', { items: [1, 1, 2, 3, 3] }).slice(0, 3), [1, 2, 3]);
});

test('array programs report the right answers', () => {
    assert.match(arrayFrames('pairSum', { items: [1, 3, 4, 6, 8, 11], target: 14 }).at(-1).message, /indexes 1 and 5/);
    assert.match(arrayFrames('pairSum', { items: [1, 2], target: 9 }).at(-1).message, /no pair/);
    assert.match(arrayFrames('maxSumFixed', { items: [2, 1, 5, 1, 3, 2], k: 3 }).at(-1).message, /Return 9/);
    assert.match(arrayFrames('shortestWindow', { items: [2, 3, 1, 2, 4, 3], target: 7 }).at(-1).message, /length 2/);
    assert.match(arrayFrames('longestUnique', { text: 'pwwkew' }).at(-1).message, /Return 3/);
    assert.match(arrayFrames('prefixSum', { items: [3, 1, 4, 1, 5], query: [1, 3] }).at(-1).message, /= 6\./);
    assert.match(arrayFrames('kadane').at(-1).message, /indexes 3–6, summing to 6/);
    assert.match(arrayFrames('dynamicAppend', { count: 9, capacity: 1 }).at(-1).message, /9 appends, 15 copies in total: 1\.67 per append/);
    // Doubling keeps total copies below twice the appends
    [1, 2, 5, 17, 100].forEach((count) => {
        const copies = arrayFrames('dynamicAppend', { count, capacity: 1 }).at(-1).vars.copies;
        assert.ok(copies < 2 * count, `${count} appends made ${copies} copies`);
    });
    assert.deepEqual(arrayFrames('nextGreater', { items: [2, 7, 3, 5, 4, 6, 8] }).at(-1).rows[1].values, [7, 8, 5, 6, 6, 8, -1]);
});

test('linked-list programs', () => {
    const reversed = linkedListFrames('reverse', { values: [1, 2, 3] }).at(-1);
    assert.deepEqual(reversed.next, { 0: null, 1: 0, 2: 1 });
    assert.equal(reversed.pointers.head, 2);
    assert.match(linkedListFrames('middle', { values: [1, 2, 3, 4, 5] }).at(-1).message, /slow \(3\)/);
    assert.match(linkedListFrames('cycle', { values: [1, 2, 3, 4], loopTo: 1 }).at(-1).message, /meet/);
    assert.match(linkedListFrames('cycle', { values: [1, 2, 3, 4], loopTo: null }).at(-1).message, /no cycle/);
});

test('stacks, queues and deques', () => {
    assert.deepEqual(stackQueueFrames('stack', ['push 1', 'push 2', 'pop']).at(-1).items, [1]);
    assert.deepEqual(stackQueueFrames('queue', ['enqueue 1', 'enqueue 2', 'dequeue']).at(-1).items, [2]);
    assert.deepEqual(stackQueueFrames('deque', ['pushBack 1', 'pushFront 2', 'popBack']).at(-1).items, [2]);
    assert.throws(() => stackQueueFrames('stack', ['enqueue 1']));
});

test('hash tables', () => {
    assert.equal(hashOf(-3, 7), 4);
    const chained = hashTableFrames('chaining', [10, 3, 17, 24], 7).at(-2).buckets;
    assert.deepEqual(chained[3], [10, 3, 17, 24]);
    const probed = hashTableFrames('probing', [10, 3, 17], 7).at(-2).slots;
    assert.deepEqual(probed.slice(3, 6), [10, 3, 17]);
});

test('sorting programs sort, and the searches find the right index', () => {
    const items = [9, 4, 7, 1, 8, 2, 2, 6];
    ['bubbleSort', 'selectionSort', 'insertionSort', 'mergeSort', 'quickSort'].forEach((name) => {
        const frames = arrayFrames(name, { items });
        assert.deepEqual(frames.at(-1).rows[0].values, [1, 2, 2, 4, 6, 7, 8, 9], name);
    });
    assert.deepEqual(arrayFrames('countingSort', { items: [4, 2, 2, 8, 3, 3, 1], max: 8 }).at(-1).rows[0].values, [1, 2, 2, 3, 3, 4, 8]);
    assert.match(arrayFrames('lowerBound', { items: [1, 3, 3, 3, 5], target: 3 }).at(-1).message, /== 1:/);
    assert.match(arrayFrames('lowerBound', { items: [1, 3, 5], target: 9 }).at(-1).message, /== 3:.*past the end/);
    assert.match(arrayFrames('bubbleSort', { items: [1, 2, 3] }).at(-1).message, /No swaps/);
});

test('memoised fibonacci, fast power and the sieve', () => {
    assert.match(recursionFrames('fibonacciMemo', [6]).at(-1).message, /= 8, after 11 calls/);
    assert.match(traceFrames('fastPower', { base: 3, exponent: 13 }).at(-1).message, /3\^13 = 1594323/);
    assert.match(arrayFrames('sieve', { n: 30 }).at(-1).message, /2, 3, 5, 7, 11, 13, 17, 19, 23, 29\./);
});
