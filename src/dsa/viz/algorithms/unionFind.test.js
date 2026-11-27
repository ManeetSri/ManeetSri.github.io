import { test } from 'node:test';
import assert from 'node:assert/strict';
import { unionFindFrames } from './unionFind.js';
import { graphFrames } from './graphs.js';

test('union-find compresses paths, unions by size and counts sets', () => {
    const frames = unionFindFrames();
    const last = frames.at(-1);
    assert.equal(last.components, 2);
    assert.deepEqual(last.parent, [0, 0, 0, 0, 0, 0, 6]);
    assert.deepEqual(frames.filter((frame) => frame.result).map((frame) => frame.result), ['union(0, 1) = true', 'union(2, 3) = true', 'union(4, 5) = true', 'union(0, 2) = true', 'union(4, 0) = true', 'find(3) = 0', 'connected(1, 5) = true', 'union(1, 3) = false']);
    assert.ok(frames.some((frame) => frame.line === 14), 'path compression happens');
});

test('union-find agrees with a naive labelling on random operations', () => {
    let seed = 3;
    const next = (limit) => { seed = (seed * 1103515245 + 12345) % 2147483648; return seed % limit; };
    const count = 12;
    const operations = Array.from({ length: 40 }, () => `${next(2) ? 'union' : 'connected'} ${next(count)} ${next(count)}`);
    const labels = Array.from({ length: count }, (_, index) => index);
    const expected = operations.map((operation) => {
        const [op, a, b] = operation.split(' ');
        const [la, lb] = [labels[+a], labels[+b]];
        if (op === 'connected') return `connected(${a}, ${b}) = ${la === lb}`;
        if (la === lb) return `union(${a}, ${b}) = false`;
        labels.forEach((label, index) => { if (label === lb) labels[index] = la; });
        return `union(${a}, ${b}) = true`;
    });
    const frames = unionFindFrames({ count, operations });
    assert.deepEqual(frames.filter((frame) => frame.result).map((frame) => frame.result), expected);
    assert.equal(frames.at(-1).components, new Set(labels).size);
});

test('Prim matches Kruskal, and Bellman–Ford handles a negative edge and a negative cycle', () => {
    assert.match(graphFrames('prim').frames.at(-1).message, /Total weight 13/);
    assert.match(graphFrames('kruskal').frames.at(-1).message, /total weight of 13/);
    assert.deepEqual(graphFrames('bellmanFord').frames.at(-1).labels, { S: '0', A: '1', B: '5', C: '4', D: '5' });
    // Dijkstra gets the same graph wrong, which is the point of it
    assert.notDeepEqual(graphFrames('dijkstra', { graph: 'negative', start: 'S' }).frames.at(-1).labels, { S: '0', A: '1', B: '5', C: '4', D: '5' });
    const cycle = { directed: true, nodes: [{ id: 'S', x: 10, y: 50 }, { id: 'A', x: 50, y: 20 }, { id: 'B', x: 90, y: 50 }], edges: [['S', 'A', 1], ['A', 'B', -2], ['B', 'A', 1]] };
    assert.equal(graphFrames('bellmanFord', { graph: cycle }).frames.at(-1).line, 13);
});

test('DFS topological order respects every edge, and Kosaraju finds the components', () => {
    const graph = { directed: true, nodes: ['a', 'b', 'c', 'd', 'e'].map((id, index) => ({ id, x: index * 20, y: 50 })), edges: [['a', 'c'], ['b', 'c'], ['c', 'd'], ['b', 'e'], ['e', 'd']] };
    const order = graphFrames('topoDfs', { graph }).frames.at(-1).side[0].items;
    const position = Object.fromEntries(order.map((id, index) => [id, index]));
    graph.edges.forEach(([from, to]) => assert.ok(position[from] < position[to], `${from} before ${to}`));
    const components = graphFrames('scc').frames.at(-1).side[1].items.map((text) => text.split(': ')[1].split(' ').sort().join(''));
    assert.deepEqual(components.sort(), ['ABC', 'DE', 'F']);
    // A single cycle is one component; a chain is one per node
    const cycle = { directed: true, nodes: ['x', 'y', 'z'].map((id, index) => ({ id, x: index * 40, y: 50 })), edges: [['x', 'y'], ['y', 'z'], ['z', 'x']] };
    assert.equal(graphFrames('scc', { graph: cycle }).frames.at(-1).side[1].items.length, 1);
    const chain = { ...cycle, edges: [['x', 'y'], ['y', 'z']] };
    assert.equal(graphFrames('scc', { graph: chain }).frames.at(-1).side[1].items.length, 3);
});

test('Edmonds–Karp finds the maximum flow, equal to the minimum cut', () => {
    const frames = graphFrames('maxFlow').frames;
    assert.equal(frames.at(-1).side[0].items[0], '19');
    assert.deepEqual(frames.at(-1).edgeLabels['S-A'], '10/10');
    // Flow conservation: what enters each inner node leaves it
    const labels = frames.at(-1).edgeLabels;
    const flowOf = (key) => Number(labels[key].split('/')[0]);
    for (const node of ['A', 'B', 'C', 'D']) {
        const into = Object.keys(labels).filter((key) => key.endsWith(`-${node}`)).reduce((sum, key) => sum + flowOf(key), 0);
        const out = Object.keys(labels).filter((key) => key.startsWith(`${node}-`)).reduce((sum, key) => sum + flowOf(key), 0);
        assert.equal(into, out, node);
    }
    // The first BFS path takes A→D; the second must push that flow back (D→A) to reach 2
    const reroute = { directed: true, nodes: ['S', 'A', 'C', 'D', 'E', 'T'].map((id, index) => ({ id, x: index * 20, y: 50 })), edges: [['S', 'A', 1], ['S', 'C', 1], ['A', 'D', 1], ['A', 'E', 1], ['C', 'D', 1], ['D', 'T', 1], ['E', 'T', 1]] };
    const rerouted = graphFrames('maxFlow', { graph: reroute }).frames;
    assert.equal(rerouted.at(-1).side[0].items[0], '2');
    assert.ok(rerouted.some((frame) => /backwards/.test(frame.message) && frame.edges['A-D'] === 'rejected'));
    assert.equal(rerouted.at(-1).edgeLabels['A-D'], '0/1');
});

test('Kahn in waves gives the parallel-courses plan, and detects cycles', () => {
    const graph = { directed: true, nodes: ['0', '1', '2', '3', '4', '5', '6'].map((id, index) => ({ id, x: index * 15, y: 50 })), edges: [['0', '2'], ['0', '3'], ['1', '3'], ['2', '4'], ['3', '4'], ['4', '5'], ['1', '5'], ['5', '6'], ['2', '6']] };
    const last = graphFrames('topoWaves', { graph }).frames.at(-1);
    assert.deepEqual(last.side[2].items, ['S1: 0 1', 'S2: 2 3', 'S3: 4', 'S4: 5', 'S5: 6']);
    const cycle = { directed: true, nodes: ['a', 'b', 'c'].map((id, index) => ({ id, x: index * 40, y: 50 })), edges: [['a', 'b'], ['b', 'c'], ['c', 'b']] };
    assert.match(graphFrames('topoWaves', { graph: cycle }).frames.at(-1).message, /Only 1 of 3/);
});
