import { test } from 'node:test';
import assert from 'node:assert/strict';
import { arcBetweenRects, clipCircle, exitRect, segmentBetweenRects, selfLoop, textWidth, truncate, wrapText } from '../svg.js';

const close = (actual, expected, message) => assert.ok(Math.abs(actual - expected) < 1e-9, `${message}: ${actual} ≠ ${expected}`);

test('clipCircle gives exactly what GraphDiagram computed inline', () => {
    const from = { x: 30, y: 26 };
    const to = { x: 412.4, y: 188.7 };
    const RADIUS = 20;
    const length = Math.hypot(to.x - from.x, to.y - from.y);
    const ux = (to.x - from.x) / length;
    const uy = (to.y - from.y) / length;
    assert.deepEqual(clipCircle(from, to, RADIUS), { x: from.x + ux * RADIUS, y: from.y + uy * RADIUS });
    assert.deepEqual(clipCircle(to, from, RADIUS + 2), { x: to.x - ux * (RADIUS + 2), y: to.y - uy * (RADIUS + 2) });
    assert.deepEqual(clipCircle(from, from, 5), from);
});

test('exitRect leaves a rectangle through the side it faces', () => {
    const rect = { x: 0, y: 0, w: 100, h: 50 };
    const centre = { x: 50, y: 25 };
    assert.deepEqual(exitRect(rect, centre, { x: 300, y: 25 }), { x: 100, y: 25 });
    assert.deepEqual(exitRect(rect, centre, { x: 50, y: -400 }), { x: 50, y: 0 });
    assert.deepEqual(exitRect(rect, centre, { x: -10, y: 25 }, 3), { x: -3, y: 25 });
    // Steeply down and right: the bottom edge comes first
    const point = exitRect(rect, centre, { x: 80, y: 125 });
    close(point.y, 50, 'bottom');
    close(point.x, 57.5, 'x on the bottom edge');
});

test('opposite edges between one pair sit on opposite sides, parallel and clipped', () => {
    const a = { x: 0, y: 0, w: 112, h: 50 };
    const b = { x: 280, y: 0, w: 112, h: 50 };
    const there = segmentBetweenRects(a, b, { offset: 7, gapStart: 0, gapEnd: 0 });
    const back = segmentBetweenRects(b, a, { offset: 7, gapStart: 0, gapEnd: 0 });
    assert.deepEqual([there.start, there.end], [{ x: 112, y: 32 }, { x: 280, y: 32 }]);
    assert.deepEqual([back.start, back.end], [{ x: 280, y: 18 }, { x: 112, y: 18 }]);
    const plain = segmentBetweenRects(a, b);
    assert.deepEqual([plain.start, plain.end], [{ x: 114, y: 25 }, { x: 278, y: 25 }]);
    assert.equal(plain.d, 'M 114 25 L 278 25');
});

test('arcs between one pair bow to opposite sides', () => {
    const a = { x: 0, y: 0, w: 100, h: 40 };
    const b = { x: 300, y: 0, w: 100, h: 40 };
    const there = arcBetweenRects(a, b, 20);
    const back = arcBetweenRects(b, a, 20);
    assert.ok(there.mid.y > 20 + 15, 'bows below');
    assert.ok(back.mid.y < 20 - 15, 'bows above');
    assert.match(there.d, /^M [\d.]+ [\d.]+ Q /);
});

test('self loops start and end on the chosen side', () => {
    const rect = { x: 100, y: 100, w: 120, h: 44 };
    const top = selfLoop(rect, 'top');
    assert.ok(top.start.y < 100 && top.end.y < 100 && top.apex.y < 80);
    const right = selfLoop(rect, 'right');
    assert.ok(right.start.x > 220 && right.apex.x > 240);
    const bottom = selfLoop(rect, 'bottom');
    assert.ok(bottom.apex.y > 164);
});

test('text helpers wrap, truncate and estimate', () => {
    assert.deepEqual(wrapText('Token store in the Keychain', 12), ['Token store', 'in the', 'Keychain']);
    assert.deepEqual(wrapText('averyveryverylongword', 8), ['averyver', 'yverylon', 'gword']);
    assert.deepEqual(wrapText('one\ntwo', 20), ['one', 'two']);
    assert.equal(truncate('Downloading', 6), 'Downl…');
    assert.equal(truncate('short', 6), 'short');
    assert.equal(textWidth('abcd', 10), 24);
});
