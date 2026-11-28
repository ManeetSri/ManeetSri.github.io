import { test } from 'node:test';
import assert from 'node:assert/strict';
import { matrixFrames } from './matrix.js';

const spiralReference = (grid) => {
    // Peel the top row, then rotate what's left counterclockwise, until nothing is left
    const result = [];
    let rest = grid.map((row) => [...row]);
    while (rest.length && rest[0].length) {
        result.push(...rest.shift());
        if (!rest.length) break;
        rest = rest[0].map((_, c) => rest.map((row) => row[row.length - 1 - c]));
    }
    return result;
};

test('spiral order matches a reference on every shape up to 5 × 5', () => {
    for (let rows = 1; rows <= 5; rows += 1) {
        for (let columns = 1; columns <= 5; columns += 1) {
            const grid = Array.from({ length: rows }, (_, r) => Array.from({ length: columns }, (_, c) => r * columns + c + 1));
            const frames = matrixFrames('spiral', { grid });
            assert.deepEqual(frames.at(-1).output, spiralReference(grid), `${rows} × ${columns}`);
            assert.equal(Object.keys(frames.at(-1).grids[0].order).length, rows * columns);
        }
    }
});

test('rotate turns a square grid clockwise in place', () => {
    assert.deepEqual(matrixFrames('rotate').at(-1).grids[0].cells, [[7, 4, 1], [8, 5, 2], [9, 6, 3]]);
    assert.deepEqual(matrixFrames('rotate', { grid: [[1, 2], [3, 4]] }).at(-1).grids[0].cells, [[3, 1], [4, 2]]);
    // Earlier frames keep their own copy of the grid
    assert.deepEqual(matrixFrames('rotate')[0].grids[0].cells, [[1, 2, 3], [4, 5, 6], [7, 8, 9]]);
});

test('life moves the glider one cell down and right every 4 generations', () => {
    const glider = matrixFrames('life').at(-1).grids[0].cells;
    const live = glider.flatMap((row, r) => row.flatMap((value, c) => (value ? [[r, c]] : [])));
    assert.deepEqual(live, [[1, 2], [2, 3], [3, 1], [3, 2], [3, 3]]);
    // A blinker flips between horizontal and vertical
    const blinker = [[0, 0, 0], [1, 1, 1], [0, 0, 0]];
    const frames = matrixFrames('life', { grid: blinker, generations: 1 });
    assert.deepEqual(frames.at(-1).grids[1].cells, [[0, 1, 0], [0, 1, 0], [0, 1, 0]]);
});
