import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mockMistakes, problemMistakes, quizMistakes } from './mistakes.js';

const lessonById = { 'arr-basics': {}, 'arr-rotate': {} };
const problemById = { 'two-sum': {}, 'three-sum': {}, 'easy-one': {} };

test('quiz mistakes count first-try misses and which are still wrong', () => {
    const lessons = {
        'arr-basics': { quiz: { q1: { firstTry: false, correct: true, at: 10 }, q2: { firstTry: true, correct: true, at: 11 } } },
        'arr-rotate': { quiz: { q1: { firstTry: false, correct: false, at: 20 }, q2: { firstTry: false, correct: true, at: 21 } } },
        'gone-lesson': { quiz: { q1: { firstTry: false, correct: false, at: 30 } } },
    };
    assert.deepEqual(quizMistakes(lessons, lessonById), [
        { lessonId: 'arr-rotate', missed: 2, stillWrong: 1, at: 21 },
        { lessonId: 'arr-basics', missed: 1, stillWrong: 0, at: 10 },
    ]);
});

test('problem mistakes cover unsolved, helped and hard-rated problems', () => {
    const problems = {
        'two-sum': { status: 'solved', attempts: { 1: { at: 1, rating: 'good' }, 5: { at: 5, rating: 'hard' } } },
        'three-sum': { status: 'attempted', attempts: { 3: { at: 3, rating: 'again' } } },
        'easy-one': { status: 'solved', attempts: { 4: { at: 4, rating: 'easy' } } },
    };
    assert.deepEqual(problemMistakes(problems, problemById), [
        { problemId: 'two-sum', reason: 'last rated hard', at: 5 },
        { problemId: 'three-sum', reason: 'not solved yet', at: 3 },
    ]);
});

test('mock mistakes are unfinished or low-scoring mocks, with the weakest criterion', () => {
    const mocks = {
        a: { at: 1, status: 'solved', scores: { approach: 4, communication: 3 } },
        b: { at: 2, status: 'solved', scores: { approach: 2, communication: 1 } },
        c: { at: 3, status: 'attempted', scores: { approach: 3, communication: 4 } },
    };
    const result = mockMistakes(mocks);
    assert.deepEqual(result.map((mock) => [mock.at, mock.weakest]), [[3, 'approach'], [2, 'communication']]);
});

import { designMistakes } from './mistakes.js';

test('design mistakes flag unsolved attempts, weak skills and missed findings', () => {
    const practiceById = { 'sd-a': { kind: 'design' }, 'sd-b': { kind: 'design' }, 'sd-c': { kind: 'critique' }, 'sd-d': { kind: 'design' } };
    const designs = {
        'sd-a': { attempts: { 1: { at: 1, status: 'helped' } } },
        'sd-b': { attempts: { 2: { at: 2, status: 'solved', skills: { data: 2, api: 4 } } } },
        'sd-c': { attempts: { 3: { at: 3, status: 'solved', marks: { race: 'found', leak: 'missed' } } } },
        'sd-d': { attempts: { 4: { at: 4, status: 'solved', skills: { data: 3 } } } },
        'sd-gone': { attempts: { 5: { at: 5, status: 'attempted' } } },
    };
    assert.deepEqual(designMistakes(designs, practiceById, { data: 'Data & storage' }), [
        { designId: 'sd-c', reason: 'missed findings', at: 3 },
        { designId: 'sd-b', reason: 'weak on Data & storage', at: 2 },
        { designId: 'sd-a', reason: 'partly there', at: 1 },
    ]);
});
