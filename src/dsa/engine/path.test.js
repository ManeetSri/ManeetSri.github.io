import { test } from 'node:test';
import assert from 'node:assert/strict';
import { GOALS, lessons, modules } from '../data/curriculum.js';
import { completion, isOnPath, lessonState, nextOnPath, pathFor, projection } from './path.js';

test('every goal includes every core lesson', () => {
    const core = lessons.filter((lesson) => lesson.tracks.includes('core'));
    Object.keys(GOALS).forEach((goal) => {
        assert.ok(core.every((lesson) => isOnPath(lesson, goal, GOALS)), goal);
    });
});

test('wider goals are supersets of narrower ones', () => {
    const ids = (goal) => new Set(pathFor(goal, lessons, GOALS).map((lesson) => lesson.id));
    const subset = (a, b) => [...ids(a)].every((id) => ids(b).has(id));
    assert.ok(subset('foundations', 'interview'));
    assert.ok(subset('interview', 'ios'));
    assert.ok(subset('interview', 'cp'));
    assert.ok(subset('cp', 'everything'));
    assert.equal(pathFor('everything', lessons, GOALS).length, lessons.length);
});

test('the path keeps curriculum order', () => {
    const path = pathFor('interview', lessons, GOALS);
    const order = new Map(lessons.map((lesson, index) => [lesson.id, index]));
    path.slice(1).forEach((lesson, index) => assert.ok(order.get(lesson.id) > order.get(path[index].id)));
});

test('modules only require modules listed before them', () => {
    const seen = new Set();
    modules.forEach((module) => {
        module.requires.forEach((id) => assert.ok(seen.has(id), `${module.id} requires ${id}, which comes later`));
        seen.add(module.id);
    });
});

test('next lesson and states follow progress', () => {
    const path = pathFor('foundations', lessons, GOALS);
    const progress = { [path[0].id]: { completedAt: 1 }, [path[1].id]: { openedAt: 2 } };
    assert.equal(nextOnPath(path, progress).id, path[1].id);
    assert.equal(lessonState(path[0], progress), 'done');
    assert.equal(lessonState(path[1], progress), 'started');
    assert.equal(completion(path.slice(0, 4), progress).done, 1);
});

test('tested-out lessons count as done but keep their own state', () => {
    const path = pathFor('foundations', lessons, GOALS);
    const progress = { [path[0].id]: { testedOutAt: 1 } };
    assert.equal(lessonState(path[0], progress), 'skipped');
    assert.equal(nextOnPath(path, progress).id, path[1].id);
    assert.equal(completion(path.slice(0, 2), progress).done, 1);
});

test('projection divides the minutes left by the weekly pace', () => {
    const path = [{ id: 'a', minutes: 60 }, { id: 'b', minutes: 60 }];
    const result = projection({ path, progress: {}, minutesPerDay: 30, daysPerWeek: 4, now: 0 });
    assert.equal(result.minutesLeft, 120);
    assert.equal(result.weeks, 1);
});
