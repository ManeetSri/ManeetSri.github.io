import { test } from 'node:test';
import assert from 'node:assert/strict';
import { critiqueScore, latestSkills, ratingFromCritique, ratingFromRubric, rubricAverage, skillScores, statusFromCritique, statusFromRubric } from './exercises.js';

test('rubric ratings keep the DSA mock thresholds', () => {
    assert.equal(ratingFromRubric({ a: 4, b: 4 }, 'solved'), 'easy');
    assert.equal(ratingFromRubric({ a: 3, b: 3 }, 'solved'), 'good');
    assert.equal(ratingFromRubric({ a: 3, b: 2 }, 'solved'), 'hard');
    assert.equal(ratingFromRubric({ a: 1, b: 2 }, 'solved'), 'again');
    assert.equal(ratingFromRubric({ a: 4, b: 4 }, 'attempted'), 'again');
    assert.equal(rubricAverage({}), 0);
    assert.equal(statusFromRubric({ a: 3, b: 3 }), 'solved');
    assert.equal(statusFromRubric({ a: 2, b: 2 }), 'helped');
    assert.equal(statusFromRubric({ a: 1 }), 'attempted');
});

test('a skill scores its weakest criterion', () => {
    const criteria = [{ id: 'scope', skill: 'requirements' }, { id: 'nfr', skill: 'requirements' }, { id: 'cache', skill: 'data' }, { id: 'talk' }];
    assert.deepEqual(skillScores({ scope: 4, nfr: 2, cache: 3, talk: 1 }, criteria), { requirements: 2, data: 3 });
});

test('architecture reviews weigh findings by severity', () => {
    const findings = [{ id: 'race', severity: 'high' }, { id: 'naming', severity: 'low' }, { id: 'leak', severity: 'medium' }];
    assert.equal(critiqueScore({ race: 'found', naming: 'found', leak: 'found' }, findings), 1);
    assert.equal(critiqueScore({ race: 'found' }, findings), 0.5);
    assert.equal(critiqueScore({ race: 'partial', leak: 'found' }, findings), 3.5 / 6);
    assert.equal(critiqueScore({}, []), 0);
    assert.equal(ratingFromCritique(0.9), 'easy');
    assert.equal(ratingFromCritique(0.7), 'good');
    assert.equal(ratingFromCritique(0.5), 'hard');
    assert.equal(ratingFromCritique(0.2), 'again');
    assert.equal(statusFromCritique(0.7), 'solved');
    assert.equal(statusFromCritique(0.5), 'helped');
    assert.equal(statusFromCritique(0.1), 'attempted');
});

test('each skill shows its most recent score', () => {
    const designs = {
        a: { attempts: { 1: { at: 1, skills: { data: 2, api: 3 } }, 5: { at: 5, skills: { data: 4 } } } },
        b: { attempts: { 3: { at: 3, skills: { api: 1, offline: 2 } } } },
        c: { attempts: { 4: { at: 4, marks: { x: 'found' } } } },
    };
    assert.deepEqual(latestSkills(designs), { data: 4, api: 1, offline: 2 });
});
