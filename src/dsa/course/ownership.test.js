import { test } from 'node:test';
import assert from 'node:assert/strict';
import { courseOfId, DEFAULT_COURSE, filterState, ownerOf } from './ownership.js';
import { courseProfile, profilePatch } from './profile.js';

test('records without another course’s prefix belong to DSA', () => {
    assert.equal(DEFAULT_COURSE, 'dsa');
    assert.equal(courseOfId('two-sum'), 'dsa');
    assert.equal(ownerOf('cards', 'arr-basics~card~x', { lessonId: 'arr-basics' }), 'dsa');
    assert.equal(ownerOf('cards', 'problem~two-sum', { ref: 'two-sum' }), 'dsa');
    assert.equal(ownerOf('mocks', '123', { at: 123 }), 'dsa');
    assert.equal(ownerOf('meta', 'profile'), null);
    assert.equal(ownerOf('activity', '2026-11-27'), null);
});

test('filtering keeps shared collections and caches per collection object', () => {
    const lessons = { a: { completedAt: 1 } };
    const state = { lessons, activity: { d: { minutes: { mac: 3 } } }, meta: { profile: { goal: 'interview' } }, sync: 'synced' };
    const filtered = filterState(state, 'dsa');
    assert.deepEqual(filtered.lessons, lessons);
    assert.equal(filtered.activity, state.activity);
    assert.equal(filtered.meta, state.meta);
    assert.equal(filterState(state, 'dsa').lessons, filtered.lessons);
    assert.deepEqual(filterState(state, 'other').lessons, {});
});

test('DSA keeps its settings at the top of the profile; other courses get their own slot', () => {
    const dsa = { defaultGoal: 'foundations', profileSlot: null };
    const other = { defaultGoal: 'core', profileSlot: 'design' };
    const profile = { goal: 'interview', minutesPerDay: 60, textSize: 'large', courses: { design: { goal: null, daysPerWeek: 3 } } };
    assert.deepEqual(courseProfile(profile, dsa), { minutesPerDay: 60, daysPerWeek: 5, targetDate: null, goal: 'interview', textSize: 'large' });
    assert.deepEqual(courseProfile(profile, other), { minutesPerDay: 45, daysPerWeek: 3, targetDate: null, goal: 'core', textSize: 'large' });
    assert.deepEqual(profilePatch(dsa, { goal: 'ios' }), { goal: 'ios' });
    assert.deepEqual(profilePatch(other, { goal: 'lead' }), { courses: { design: { goal: 'lead' } } });
});
