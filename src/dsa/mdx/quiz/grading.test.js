import { test } from 'node:test';
import assert from 'node:assert/strict';
import { correctAnswerText, emptyAnswer, estimateRange, isAnswered, isCorrect, parseEstimate } from './grading.js';

test('estimates read the way people write numbers', () => {
    assert.equal(parseEstimate('2500'), 2500);
    assert.equal(parseEstimate('2,500'), 2500);
    assert.equal(parseEstimate(' 2.5k '), 2500);
    assert.equal(parseEstimate('3M'), 3e6);
    assert.equal(parseEstimate('1.2e6'), 1.2e6);
    assert.equal(parseEstimate('lots'), null);
    assert.equal(parseEstimate(''), null);
});

test('an estimate counts within its factor or percentage', () => {
    const qps = { type: 'estimate', answer: 1000, unit: 'requests a second' };
    assert.deepEqual(estimateRange(qps), [500, 2000]);
    assert.equal(isCorrect(qps, '1.9k'), true);
    assert.equal(isCorrect(qps, '450'), false);
    assert.equal(isCorrect({ ...qps, within: { factor: 10 } }, '120'), true);
    assert.equal(isCorrect({ ...qps, within: { percent: 10 } }, '1080'), true);
    assert.equal(isCorrect({ ...qps, within: { percent: 10 } }, '1200'), false);
    assert.equal(isAnswered(qps, emptyAnswer(qps)), false);
    assert.equal(isAnswered(qps, '12k'), true);
    assert.match(correctAnswerText(qps), /About 1,000 requests a second \(anything from 500 to 2,000 counts\)/);
});

test('sorting needs every item in its bucket', () => {
    const question = { type: 'sort', buckets: ['Presentation', 'Domain', 'Data'], items: [['View model', 0], ['Use case', 1], ['Repository', 2], ['Entity', 1]] };
    assert.deepEqual(emptyAnswer(question), [-1, -1, -1, -1]);
    assert.equal(isAnswered(question, [0, 1, 2, -1]), false);
    assert.equal(isCorrect(question, [0, 1, 2, 1]), true);
    assert.equal(isCorrect(question, [0, 1, 1, 1]), false);
    assert.equal(correctAnswerText(question), 'Presentation: View model · Domain: Use case, Entity · Data: Repository');
});
