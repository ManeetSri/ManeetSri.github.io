import { test } from 'node:test';
import assert from 'node:assert/strict';
import { INTERVAL_PROGRAMS, intervalFrames } from './intervals.js';

const pairs = (lane) => lane.intervals.map(({ start, end }) => [start, end]);
const finalLane = (name, input, label) => {
    const lanes = intervalFrames(name, input).at(-1).lanes;
    return pairs(label ? lanes.find((lane) => lane.label === label) : lanes.at(-1));
};

// Brute-force references to check the programs against
const mergeReference = (intervals) => {
    const merged = [];
    [...intervals].sort((a, b) => a[0] - b[0]).forEach(([start, end]) => {
        if (merged.length && start <= merged.at(-1)[1]) merged.at(-1)[1] = Math.max(merged.at(-1)[1], end);
        else merged.push([start, end]);
    });
    return merged;
};
const mostAtOnce = (meetings) => {
    const times = meetings.flatMap(([start, end]) => [start, end]);
    return Math.max(0, ...times.map((time) => meetings.filter(([start, end]) => start <= time && time < end).length));
};

test('merge and insert produce the expected intervals', () => {
    assert.deepEqual(finalLane('merge'), [[1, 7], [8, 10], [15, 20]]);
    assert.deepEqual(finalLane('merge', { intervals: [[1, 4], [2, 3]] }), [[1, 4]]);
    assert.deepEqual(finalLane('insert'), [[1, 2], [3, 10], [12, 16]]);
    assert.deepEqual(finalLane('insert', { intervals: [[1, 2], [5, 6]], newInterval: [3, 4] }), [[1, 2], [3, 4], [5, 6]]);
    assert.deepEqual(finalLane('insert', { intervals: [[1, 2]], newInterval: [7, 9] }), [[1, 2], [7, 9]]);
    assert.deepEqual(finalLane('insert', { intervals: [], newInterval: [7, 9] }), [[7, 9]]);
});

test('merge matches a reference on random inputs', () => {
    let seed = 7;
    const next = (limit) => { seed = (seed * 1103515245 + 12345) % 2147483648; return seed % limit; };
    for (let round = 0; round < 200; round += 1) {
        const intervals = Array.from({ length: 1 + next(8) }, () => { const start = next(30); return [start, start + next(8)]; });
        assert.deepEqual(finalLane('merge', { intervals }), mergeReference(intervals));
    }
});

test('fewest removals keeps a non-overlapping set', () => {
    const frames = intervalFrames('nonOverlapping');
    assert.equal(frames.at(-1).vars.removals, 3);
    const kept = frames.at(-1).lanes[0].intervals.filter((interval) => interval.tone === 'kept');
    kept.slice(1).forEach((interval, index) => assert.ok(interval.start >= kept[index].end));
});

test('meeting rooms counts the most meetings at once, with ends before starts on ties', () => {
    const meetings = [[0, 30], [5, 10], [15, 20], [10, 15], [25, 35], [8, 12]];
    const frames = intervalFrames('meetingRooms', { meetings });
    assert.equal(frames.at(-1).vars.most, mostAtOnce(meetings));
    assert.equal(frames.at(-1).lanes.length, 3);
    // Back-to-back meetings need only one room
    assert.equal(intervalFrames('meetingRooms', { meetings: [[1, 2], [2, 3], [3, 4]] }).at(-1).vars.most, 1);
});

test('room assignment never double-books a room', () => {
    const { lanes } = intervalFrames('meetingRooms', { meetings: [[1, 5], [2, 6], [5, 9], [6, 8], [3, 4]] }).at(-1);
    lanes.forEach((lane) => {
        const sorted = [...lane.intervals].sort((a, b) => a.start - b.start);
        sorted.slice(1).forEach((interval, index) => assert.ok(interval.start >= sorted[index].end));
    });
});

test('intersections finds every overlap, including single points', () => {
    assert.deepEqual(finalLane('intersections'), [[1, 2], [5, 5], [8, 10], [15, 23], [24, 24], [25, 25]]);
    assert.deepEqual(finalLane('intersections', { a: [[1, 3]], b: [[4, 6]] }), []);
});

test('every frame is a snapshot that later steps never change', () => {
    INTERVAL_PROGRAMS.forEach((name) => {
        const frames = intervalFrames(name);
        const copies = JSON.stringify(frames);
        intervalFrames(name);
        assert.equal(JSON.stringify(frames), copies);
        const merged = frames.map((frame) => JSON.stringify(frame.lanes));
        assert.equal(new Set(merged).size > 1, true, `${name} frames should change`);
    });
    // The merged lane only ever grows or stretches: an earlier frame never shows the final answer early
    const frames = intervalFrames('merge');
    assert.deepEqual(pairs(frames[2].lanes[1]), [[1, 3]]);
});
