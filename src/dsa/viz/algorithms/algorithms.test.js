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

import { avlFrames, bstFrames, heapAsTree, heapFrames, trieFrames } from './trees.js';

const inorderValues = (tree) => {
    const out = [];
    const walk = (id) => {
        if (id === null || id === undefined) return;
        walk(tree.nodes[id].left);
        out.push(tree.nodes[id].value);
        walk(tree.nodes[id].right);
    };
    walk(tree.root);
    return out;
};

test('BST programs keep the BST property', () => {
    assert.deepEqual(inorderValues(bstFrames('insert').at(-1).tree), [20, 30, 35, 40, 50, 60, 70, 80]);
    assert.match(bstFrames('search', { target: 35 }).at(-1).message, /Found 35 after looking at 4 nodes/);
    assert.match(bstFrames('search', { target: 36 }).at(-1).message, /isn't there/);
    [50, 20, 30, 65, 70, 99].forEach((target) => {
        const values = [50, 30, 70, 20, 40, 60, 80, 65];
        const expected = values.filter((value) => value !== target).sort((a, b) => a - b);
        assert.deepEqual(inorderValues(bstFrames('remove', { values, target }).at(-1).tree), expected, `remove ${target}`);
    });
    assert.deepEqual(bstFrames('traversal', { order: 'preorder' }).at(-1).output, [50, 30, 20, 40, 70, 60, 80]);
    assert.deepEqual(bstFrames('traversal', { order: 'postorder' }).at(-1).output, [20, 40, 30, 60, 80, 70, 50]);
    assert.deepEqual(bstFrames('traversal', { order: 'levelorder' }).at(-1).output, [50, 30, 70, 20, 40, 60, 80]);
    assert.deepEqual(bstFrames('traversal', { order: 'inorder' }).at(-1).output, [20, 30, 40, 50, 60, 70, 80]);
});

test('AVL stays balanced and sorted', () => {
    const last = avlFrames({ values: [1, 2, 3, 4, 5, 6, 7] }).at(-1);
    assert.deepEqual(inorderValues(last.tree), [1, 2, 3, 4, 5, 6, 7]);
    assert.match(last.message, /height 3/);
    Object.values(last.tree.nodes).forEach((node) => assert.ok(Math.abs(Number(node.note)) <= 1));
    assert.ok(avlFrames({ values: [30, 10, 20] }).some((frame) => /left-right/.test(frame.message)));
    assert.ok(avlFrames({ values: [10, 30, 20] }).some((frame) => /right-left/.test(frame.message)));
});

test('heap pops come out sorted, and the tree view mirrors the array', () => {
    const frames = heapFrames({ operations: [5, 3, 8, 1, 9, 2, 'pop', 'pop', 'pop'] });
    const popped = frames.map((frame) => frame.message.match(/pop\(\) returned (\d+)/)?.[1]).filter(Boolean).map(Number);
    assert.deepEqual(popped, [1, 2, 3]);
    const tree = heapAsTree([1, 3, 2, 5]);
    assert.equal(tree.nodes[1].left, 3);
    assert.equal(tree.nodes[1].right, null);
});

test('trie shares prefixes and completes them', () => {
    const frames = trieFrames({ words: ['car', 'cat', 'cart', 'dog'], prefix: 'ca' });
    assert.equal(Object.keys(frames.at(-1).nodes).length, 9);
    assert.match(frames.at(-1).message, /car, cart, cat/);
    assert.match(trieFrames({ words: ['dog'], prefix: 'ca' }).at(-1).message, /no word starts with "ca"/);
});

import { astarFrames, graphFrames, gridFrames, GRAPHS } from './graphs.js';

test('graph programs', () => {
    assert.match(graphFrames('bfs').frames.at(-1).message, /A, B, C, D, E, F/);
    const dfsOrder = graphFrames('dfs').frames.at(-1).side[1].items;
    assert.deepEqual(dfsOrder, ['A', 'B', 'C', 'E', 'F', 'D']);
    const distances = graphFrames('dijkstra').frames.at(-1).labels;
    assert.deepEqual(distances, { A: '0', B: '3', C: '2', D: '8', E: '10', F: '13' });
    const order = graphFrames('topo').frames.at(-1).message;
    const position = (id) => order.indexOf(id);
    GRAPHS.dag.edges.forEach(([from, to]) => assert.ok(position(from) < position(to), `${from} before ${to}`));
    assert.match(graphFrames('kruskal').frames.at(-1).message, /5 edges with a total weight of 13/);
});

test('grid BFS finds the shortest path, or reports there is none', () => {
    const frames = gridFrames();
    assert.match(frames.at(-1).message, /Reached G in \d+ steps/);
    const steps = Number(frames.at(-1).message.match(/in (\d+) steps/)[1]);
    assert.equal(frames.at(-1).path.length, steps + 1);
    assert.match(gridFrames({ rows: ['S#', '#G'] }).at(-1).message, /no path/);
});

test('every frame is a snapshot, not a view of the final state', () => {
    const { frames } = graphFrames('bfs');
    assert.deepEqual(frames[0].labels, { A: 0 });
    assert.ok(Object.keys(frames.at(-1).labels).length === 6);
});

import { dpFrames, DP_PROGRAMS } from './dp.js';

test('DP tables give the right answers', () => {
    DP_PROGRAMS.forEach((name) => assert.ok(dpFrames(name).length > 3, name));
    assert.match(dpFrames('lcs', { a: 'ABCBDAB', b: 'BDCABA' }).at(-1).message, /length 4/);
    assert.match(dpFrames('editDistance', { a: 'kitten', b: 'sitting' }).at(-1).message, /in 3 edits/);
    assert.match(dpFrames('knapsack').at(-1).message, /is 9\./);
    assert.match(dpFrames('coinChange', { coins: [1, 3, 4], amount: 6 }).at(-1).message, /needs 2 coins\. Greedy \(biggest first\) would use 3/);
    assert.match(dpFrames('uniquePaths', { rows: 3, cols: 7 }).at(-1).message, /^28 paths/);
    assert.match(dpFrames('lis').at(-1).message, /length 4\./);
});

import { queensFrames, subsetsFrames } from './backtracking.js';

test('backtracking', () => {
    const first = queensFrames({ n: 4 }).at(-1);
    assert.deepEqual(first.queens, [1, 3, 0, 2]);
    assert.match(queensFrames({ n: 4, all: true }).at(-1).message, /2 solutions for n = 4/);
    assert.match(queensFrames({ n: 6, all: true }).at(-1).message, /4 solutions for n = 6/);
    const subsets = subsetsFrames({ items: [1, 2, 3] }).at(-1);
    assert.equal(subsets.results.length, 8);
    assert.equal(Object.values(subsets.nodes).filter((node) => node.leaf).length, 8);
});

import { fenwickFrames, segmentFrames } from './rangeTrees.js';

test('segment and Fenwick trees', () => {
    const frames = segmentFrames();
    assert.match(frames[1].message, /= 27\)/);
    assert.match(frames[2].message, /only the 4 nodes/);
    assert.match(frames[3].message, /= 19\)/);
    assert.equal(frames[3].tree.nodes[1].value, 29);
    const fenwick = fenwickFrames();
    assert.match(fenwick.find((frame) => /Sum of the first 7 items/.test(frame.message)).message, /= 16, from 3 lookups/);
    assert.match(fenwick.at(-1).message, /Only 3 entries changed/);
});

test('window maxima and ring buffers', () => {
    assert.match(arrayFrames('windowMax').at(-1).message, /Maxima: 12, 12, 12, 8, 8\./);
    const ring = arrayFrames('ringBuffer').at(-1).rows[0].values;
    assert.deepEqual(ring, [5, 6, 3, 4]);
    assert.ok(arrayFrames('ringBuffer').some((frame) => /refused/.test(frame.message)));
});

test('stacks hold text as well as numbers', () => {
    assert.deepEqual(stackQueueFrames('stack', ['push (', 'push [', 'pop']).at(-1).items, ['(']);
});

test('container and rain water bars reach the lessons’ answers', async () => {
    const { arrayFrames } = await import('./arrayPrograms.js');
    const container = arrayFrames('container');
    assert.equal(container.at(-1).vars.best, 36);
    assert.deepEqual(container.at(-1).rows[0].area, { from: 1, to: 7, level: 6 });
    const rain = arrayFrames('rainWater');
    assert.equal(rain.at(-1).vars.total, 11);
    assert.deepEqual(rain.at(-1).rows[0].water, [0, 3, 1, 4, 2, 0, 1, 0]);
    // Water settled in an early frame stays as it was
    assert.deepEqual(rain[1].rows[0].water, [null, null, null, null, null, null, null, 0]);
    assert.equal(arrayFrames('rainWater', { heights: [] }).at(-1).vars.total, 0);
});

test('histogram measures every bar once and finds the lesson’s answers', async () => {
    const { arrayFrames } = await import('./arrayPrograms.js');
    const cases = [[[2, 1, 5, 6, 2, 3], 10], [[3, 3, 3], 9], [[1, 2, 3, 4, 5], 9], [[6, 2, 5, 4, 5, 1, 6], 12], [[], 0], [[7], 7]];
    cases.forEach(([heights, best]) => {
        const frames = arrayFrames('histogram', { heights });
        assert.equal(frames.at(-1).vars.best, best, JSON.stringify(heights));
        assert.equal(frames.filter((frame) => frame.line === 10).length, heights.length);
    });
});

test('quadratic probing can miss free slots, and tombstones keep probe sequences whole', async () => {
    const { TOMBSTONE } = await import('./hashTable.js');
    const quadratic = hashTableFrames('quadratic', [10, 17, 24, 31, 38], 7);
    assert.deepEqual(quadratic.at(-2).slots, [24, null, null, 10, 17, 31, null]);
    assert.match(quadratic.at(-2).message, /can't go in, even though 3 slots are free/);

    const operations = ['insert 10', 'insert 17', 'insert 24', 'delete 17', 'find 24', 'insert 31'];
    const tombstones = hashTableFrames('probing', [], 7, operations);
    assert.equal(tombstones[4].slots[4], TOMBSTONE);
    assert.equal(tombstones[5].active, 5);
    assert.match(tombstones[5].message, /Found in slot 5/);
    assert.equal(tombstones[6].slots[4], 31);

    // Emptying the slot instead cuts the probe sequence, so 24 is lost
    const emptied = hashTableFrames('probing', [], 7, operations.slice(0, 5), 'empty');
    assert.match(emptied.at(-2).message, /isn't in the table/);
});

test('rotated search finds every value and reports missing ones', async () => {
    const { arrayFrames } = await import('./arrayPrograms.js');
    const items = [40, 50, 60, 70, 10, 20, 30];
    items.forEach((target, index) => {
        const last = arrayFrames('rotatedSearch', { items, target }).at(-1);
        assert.equal(last.rows[0].marks[index], 'found', `target ${target}`);
    });
    for (const target of [5, 35, 55, 80]) {
        assert.equal(arrayFrames('rotatedSearch', { items, target }).at(-1).line, 23);
    }
    // Every rotation of a sorted array works too
    const sorted = [1, 3, 5, 7, 9, 11];
    sorted.forEach((_, shift) => {
        const rotated = [...sorted.slice(shift), ...sorted.slice(0, shift)];
        rotated.forEach((target, index) => {
            assert.equal(arrayFrames('rotatedSearch', { items: rotated, target }).at(-1).rows[0].marks[index], 'found');
        });
    });
});

test('cyclic sort matches the lesson and stays within n swaps', async () => {
    const { arrayFrames } = await import('./arrayPrograms.js');
    const frames = arrayFrames('cyclicSort');
    assert.deepEqual(frames.filter((frame) => frame.line === 6).map((frame) => frame.rows[0].values), [[2, 5, 3, 1, 4], [5, 2, 3, 1, 4], [4, 2, 3, 1, 5], [1, 2, 3, 4, 5]]);
    const withRepeats = arrayFrames('cyclicSort', { items: [4, 3, 2, 4, 1, 2] }).at(-1);
    assert.ok(withRepeats.vars.swaps <= 6 && withRepeats.vars.moves === 6);
    assert.deepEqual(withRepeats.rows[0].values.slice(0, 4), [1, 2, 3, 4]);
});

test('partition traces match the efficient-sorts lessons', async () => {
    const { arrayFrames } = await import('./arrayPrograms.js');
    const hoare = arrayFrames('hoarePartition').at(-1);
    assert.deepEqual(hoare.rows[0].values, [3, 2, 1, 5, 7, 9]);
    assert.equal(hoare.vars.j, 2);
    const threeWay = arrayFrames('threeWay').at(-1);
    assert.deepEqual(threeWay.rows[0].values, [1, 2, 4, 4, 4, 4, 7, 9]);
    assert.deepEqual([threeWay.vars.less, threeWay.vars.greater], [2, 6]);
    const landed = arrayFrames('quickselect').filter((frame) => frame.line === 19).map((frame) => Number(Object.keys(frame.rows[0].marks)[0]));
    assert.deepEqual(landed, [4, 7, 5]);
    // Every k finds the kth smallest
    const items = [42, 7, 19, 88, 3, 56, 23, 71, 12, 64];
    const sorted = [...items].sort((a, b) => a - b);
    items.forEach((_, k) => {
        const last = arrayFrames('quickselect', { k }).at(-1);
        assert.equal(last.rows[0].values[k], sorted[k]);
    });
});

test('inversion counting matches the lesson and a brute force', async () => {
    const { arrayFrames } = await import('./arrayPrograms.js');
    assert.deepEqual(arrayFrames('inversions').filter((frame) => frame.line === 21).map((frame) => frame.vars.across), [0, 1, 0, 0, 7]);
    const brute = (items) => items.reduce((sum, value, i) => sum + items.slice(i + 1).filter((other) => other < value).length, 0);
    for (const items of [[1, 2, 3], [3, 2, 1], [2, 2], [4, 1, 3, 1, 2], [9, 8, 7, 6, 5, 4, 3, 2, 1], []]) {
        const last = arrayFrames('inversions', { items }).at(-1);
        assert.equal(last.vars.total, brute(items), JSON.stringify(items));
        assert.deepEqual(last.rows[0].values, [...items].sort((a, b) => a - b));
    }
});

test('radix sort passes match the lesson', async () => {
    const { arrayFrames } = await import('./arrayPrograms.js');
    const passes = arrayFrames('radixSort').filter((frame) => frame.rows.length === 1 && frame.rows[0].label.startsWith('after')).map((frame) => frame.rows[0].values.map(Number));
    assert.deepEqual(passes, [[260, 731, 512, 204, 45, 97, 38, 8], [204, 8, 512, 731, 38, 45, 260, 97], [8, 38, 45, 97, 204, 260, 512, 731]]);
    for (const items of [[5], [10, 1, 100, 0], [3, 3, 1], [99, 9, 999, 0, 90]]) {
        const last = arrayFrames('radixSort', { items }).at(-1);
        assert.deepEqual(last.rows[0].values.map(Number), [...items].sort((a, b) => a - b));
    }
});

test('merging two sorted lists relinks every node in order, and takes the first list on ties', async () => {
    const { linkedListFrames } = await import('./linkedList.js');
    const walk = (frame) => {
        const values = [];
        for (let id = frame.next[0]; id !== null; id = frame.next[id]) values.push(frame.nodes[id].value);
        return values;
    };
    for (const [first, second] of [[[1, 4, 6], [2, 3, 7, 8]], [[5, 5, 9], [1, 5]], [[], [1, 2]], [[3], []], [[1, 2, 3], [4, 5, 6]]]) {
        const last = linkedListFrames('merge', { first, second }).at(-1);
        assert.deepEqual(walk(last), [...first, ...second].sort((a, b) => a - b));
    }
    // On a tie the first list's node comes first: ids 1–3 are the first list
    const tie = linkedListFrames('merge', { first: [5, 5, 9], second: [1, 5] }).at(-1);
    const ids = [];
    for (let id = tie.next[0]; id !== null; id = tie.next[id]) ids.push(id);
    assert.deepEqual(ids, [4, 1, 2, 5, 3]);
});

test('trie removal with pass counts matches the lesson and prunes unused branches', async () => {
    const { trieFrames } = await import('./trees.js');
    const count = (nodes, id = '0') => Object.values(nodes[id].children).reduce((sum, child) => sum + 1 + count(nodes, String(child)), 0);
    const frames = trieFrames({ words: ['car', 'cart', 'care', 'dog'], remove: ['cart', 'ca', 'car', 'dog', 'care'] });
    assert.deepEqual(frames.filter((frame) => [2, 10, 14].includes(frame.line)).map((frame) => count(frame.nodes)), [7, 7, 7, 4, 0]);
    assert.equal(frames.at(-1).nodes[0].note, 0);
    // Without remove, the prefix search still runs as before
    assert.match(trieFrames().at(-1).message, /car, cart, cat/);
});

test('heapify and heap sort match the heaps lessons', async () => {
    const { heapifyFrames, heapSortFrames } = await import('./trees.js');
    assert.deepEqual(heapifyFrames().filter((frame) => frame.line === 9).map((frame) => frame.items), [[9, 4, 7, 1, 8, 2, 6, 3, 5], [9, 4, 2, 1, 8, 7, 6, 3, 5], [9, 1, 2, 3, 8, 7, 6, 4, 5], [1, 3, 2, 4, 8, 7, 6, 9, 5]]);
    const isMinHeap = (items) => items.every((value, index) => index === 0 || items[Math.floor((index - 1) / 2)] <= value);
    for (const items of [[3, 1, 2], [5, 4, 3, 2, 1], [1], [], [2, 2, 1, 1]]) {
        assert.ok(isMinHeap(heapifyFrames({ items }).at(-1).items), JSON.stringify(items));
        assert.deepEqual(heapSortFrames({ items }).at(-1).items, [...items].sort((a, b) => a - b));
    }
    assert.deepEqual(heapSortFrames().filter((frame) => frame.line === 23).map((frame) => frame.heapSize), [5, 4, 3, 2, 1]);
});

test('Part VII DP tables match brute-force answers', async () => {
    const { dpFrames } = await import('./dp.js');
    // House robber: compare with trying every subset with no two neighbours
    const robBrute = (houses) => {
        let best = 0;
        for (let mask = 0; mask < 1 << houses.length; mask += 1) {
            if (mask & (mask >> 1)) continue;
            best = Math.max(best, houses.reduce((sum, value, index) => sum + ((mask >> index) & 1 ? value : 0), 0));
        }
        return best;
    };
    for (const houses of [[2, 7, 9, 3, 1], [5], [1, 2], [4, 1, 1, 4, 2, 1]]) {
        assert.equal(dpFrames('houseRobber', { houses }).at(-1).table[1][houses.length], robBrute(houses));
    }
    assert.equal(dpFrames('minPathSum').at(-1).table[2][3], 10);
    assert.equal(dpFrames('matrixChain').at(-1).table[0][3], 5000);
    assert.equal(dpFrames('matrixChain', { dims: [40, 20, 30, 10, 30] }).at(-1).table[0][3], 26000);
    assert.equal(dpFrames('wordBreak').at(-1).table[0].at(-1), '✓');
    assert.equal(dpFrames('wordBreak', { text: 'creamx' }).at(-1).table[0].at(-1), '✗');
    const last = dpFrames('stockCooldown').at(-1);
    assert.equal(Math.max(last.table[2].at(-1), last.table[3].at(-1)), 6);
});

test('permutation and combination-sum trees find every answer', async () => {
    const { permutationsFrames, combinationSumFrames } = await import('./backtracking.js');
    const perms = permutationsFrames({ items: [1, 2, 3, 4] }).at(-1).results.map((r) => r.join(''));
    assert.equal(perms.length, 24);
    assert.equal(new Set(perms).size, 24);
    const sums = (candidates, target) => combinationSumFrames({ candidates, target }).at(-1).results.map((r) => r.join('+'));
    assert.deepEqual(sums([2, 3, 5], 8), ['2+2+2+2', '2+3+3', '3+5']);
    assert.deepEqual(sums([5, 3, 2], 7), ['2+2+3', '2+5']);
    assert.deepEqual(sums([4], 3), []);
});

test('Huffman codes are prefix-free and match the textbook total', async () => {
    const { huffmanFrames } = await import('./huffman.js');
    const { codes } = huffmanFrames().at(-1);
    assert.equal(codes.reduce((sum, { weight, code }) => sum + weight * code.length, 0), 224);
    const all = codes.map(({ code }) => code);
    all.forEach((code, i) => all.forEach((other, j) => assert.ok(i === j || !other.startsWith(code), `${code} prefixes ${other}`)));
    assert.equal(huffmanFrames({ frequencies: { x: 3 } }).at(-1).codes[0].code, '0');
});

test('jump game counts the fewest jumps', async () => {
    const { arrayFrames } = await import('./arrayPrograms.js');
    const fewest = (steps) => {
        const best = steps.map(() => Infinity);
        best[0] = 0;
        steps.forEach((step, i) => { for (let j = i + 1; j <= Math.min(i + step, steps.length - 1); j += 1) best[j] = Math.min(best[j], best[i] + 1); });
        return best.at(-1);
    };
    for (const steps of [[2, 3, 1, 1, 4, 2, 1, 3, 1], [2, 3, 1, 1, 4], [1, 1, 1, 1], [5, 1, 1], [1], [3, 2, 1, 1, 4]]) {
        assert.equal(arrayFrames('jumpGame', { steps }).at(-1).vars.jumps, fewest(steps), JSON.stringify(steps));
    }
});

test('Floyd–Warshall rounds match the shortest-paths lesson', async () => {
    const { dpFrames } = await import('./dp.js');
    const rounds = dpFrames('floydWarshall', { nodes: ['0', '1', '2', '3'], edges: [['0', '1', 3], ['0', '2', 8], ['1', '2', 2], ['2', '3', 1], ['3', '0', 4]] })
        .filter((frame) => frame.line === 5).map((frame) => frame.table);
    assert.deepEqual(rounds.at(0), [[0, 3, 8, '∞'], ['∞', 0, 2, '∞'], ['∞', '∞', 0, 1], [4, 7, 12, 0]]);
    assert.deepEqual(rounds.at(-1), [[0, 3, 5, 6], [7, 0, 2, 3], [5, 8, 0, 1], [4, 7, 9, 0]]);
});

test('A* on a grid matches the lesson: same cost as Dijkstra, fewer cells expanded', () => {
    const astar = astarFrames().at(-1);
    const dijkstra = astarFrames({ algorithm: 'dijkstra' }).at(-1);
    assert.equal(astar.g[4][11], 21);
    assert.equal(dijkstra.g[4][11], 21);
    assert.equal(astar.count, 48);
    assert.equal(dijkstra.count, 63);
    assert.equal(astar.path.length, 22);
    assert.match(astarFrames({ rows: ['S#G'] }).at(-1).message, /no path/);
});

test('KMP programs build π and find overlapping matches', () => {
    assert.deepEqual(arrayFrames('prefixFunction').at(-1).rows[1].values, [0, 0, 1, 0, 1, 2, 3, 2]);
    assert.deepEqual(arrayFrames('prefixFunction', { pattern: 'aabaaab' }).at(-1).rows[1].values, [0, 1, 0, 1, 2, 2, 3]);
    assert.deepEqual(arrayFrames('kmpSearch').at(-1).list.items, ['4']);
    assert.deepEqual(arrayFrames('kmpSearch', { text: 'aaaa', pattern: 'aa' }).at(-1).list.items, ['0', '1', '2']);
    assert.deepEqual(arrayFrames('kmpSearch', { text: 'abracadabra', pattern: 'abra' }).at(-1).list.items, ['0', '7']);
    assert.match(arrayFrames('kmpSearch', { text: 'abc', pattern: 'xyz' }).at(-1).message, /No match/);
});
