import { test } from 'node:test';
import assert from 'node:assert/strict';
import { answerSearchFrames } from './answerSearch.js';

const checksOf = (frames) => frames.filter((frame) => frame.check && frame.vars.mid !== undefined).map((frame) => [frame.mid, frame.check.total]);

test('speed search checks the same speeds as the lesson and finds 5', () => {
    const frames = answerSearchFrames('speed');
    assert.deepEqual(checksOf(frames), [[6, 6], [3, 11], [5, 7], [4, 9]]);
    assert.equal(frames.at(-1).answer, 5);
});

test('capacity search matches the lesson for every number of days', () => {
    const expected = [37, 20, 17, 12, 9, 9, 9];
    expected.forEach((answer, index) => {
        assert.equal(answerSearchFrames('capacity', { days: index + 1 }).at(-1).answer, answer);
    });
    const { check } = answerSearchFrames('capacity').find((frame) => frame.check);
    assert.deepEqual(check.groups.map((group) => group.detail), ['6 + 2 + 9 + 3', '5 + 4 + 8']);
});

test('the known regions only ever grow, and the answer is the first that works', () => {
    for (const piles of [[3, 6, 7, 11], [30, 11, 23, 4, 20], [1], [1000000000]]) {
        for (const hours of [piles.length, piles.length + 2, 20]) {
            const frames = answerSearchFrames('speed', { piles, hours });
            frames.slice(1).forEach((frame, index) => {
                assert.ok(frame.low >= frames[index].low && frame.high <= frames[index].high);
            });
            const answer = frames.at(-1).answer;
            const needed = (speed) => piles.reduce((sum, pile) => sum + Math.ceil(pile / speed), 0);
            assert.ok(needed(answer) <= hours);
            if (answer > 1) assert.ok(needed(answer - 1) > hours);
        }
    }
});
