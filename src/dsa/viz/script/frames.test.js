import { test } from 'node:test';
import assert from 'node:assert/strict';
import { asList, buildFrames, edgeKey, splitEdgeKey } from './frames.js';

const items = ['app', 'api', 'db'];
const edges = [['app', 'api'], ['api', 'db']];

test('edge keys split back into their ends', () => {
    assert.equal(edgeKey('app', 'api'), 'app->api');
    assert.deepEqual(splitEdgeKey('app->api'), ['app', 'api']);
    assert.deepEqual(splitEdgeKey('api-gw->db'), ['api-gw', 'db']);
    assert.equal(splitEdgeKey('app'), null);
    assert.equal(splitEdgeKey('->api'), null);
    assert.equal(splitEdgeKey('app->'), null);
    assert.deepEqual(asList('a'), ['a']);
    assert.deepEqual(asList(undefined), []);
});

test('no steps make one still frame with everything visible', () => {
    const frames = buildFrames(undefined, { items, edges, groups: [{ id: 'backend', nodes: ['api', 'db'] }], fallback: 'Overview' });
    assert.equal(frames.length, 1);
    assert.deepEqual(frames[0], { message: 'Overview', visible: ['app', 'api', 'db', 'app->api', 'api->db', 'backend'], active: [], states: {}, labels: {}, send: [] });
});

test('without show or hide everything stays visible; active is per step; states and labels carry over', () => {
    const frames = buildFrames([
        { say: 'one', active: ['api'], state: { api: 'wait' }, label: { api: 'busy' } },
        { say: 'two', state: { db: 'error' } },
        { say: 'three', state: { api: 'neutral', db: null }, label: { api: '' }, line: 4 },
    ], { items, edges });
    assert.deepEqual(frames.map((frame) => frame.visible), Array(3).fill(['app', 'api', 'db', 'app->api', 'api->db']));
    assert.deepEqual(frames.map((frame) => frame.active), [['api'], [], []]);
    assert.deepEqual(frames.map((frame) => frame.states), [{ api: 'wait' }, { api: 'wait', db: 'error' }, {}]);
    assert.deepEqual(frames.map((frame) => frame.labels), [{ api: 'busy' }, { api: 'busy' }, {}]);
    assert.equal(frames[2].line, 4);
    assert.equal('line' in frames[0], false);
});

test('show accumulates, hide removes, and reset starts again', () => {
    const frames = buildFrames([
        { say: 'a', show: 'app' },
        { say: 'b', show: ['api'], state: { api: 'ok' }, label: { app: 'v2' } },
        { say: 'c', show: ['db'], hide: ['app'] },
        { say: 'd', reset: true, show: ['db'] },
    ], { items, edges });
    assert.deepEqual(frames.map((frame) => frame.visible), [
        ['app'],
        ['app', 'api', 'app->api'],
        ['api', 'db', 'api->db'],
        ['db'],
    ]);
    assert.deepEqual(frames[3].states, {});
    assert.deepEqual(frames[3].labels, {});
    assert.deepEqual(frames[2].states, { api: 'ok' });
});

test('an edge named in show or hide follows the script instead of its ends', () => {
    const frames = buildFrames([
        { say: 'nodes first', show: ['app', 'api', 'db'] },
        { say: 'then the call', show: ['app->api'] },
        { say: 'gone again', hide: ['api->app'] },
    ], { items, edges });
    assert.deepEqual(frames.map((frame) => frame.visible), [
        ['app', 'api', 'db', 'api->db'],
        ['app', 'api', 'db', 'app->api', 'api->db'],
        ['app', 'api', 'db', 'api->db'],
    ]);
});

test('send shows the edge and its ends, keeps the direction written, and active names the declared edge', () => {
    const frames = buildFrames([
        { say: 'start', show: ['app'] },
        { say: 'reply', send: 'api -> app', active: ['api->app'] },
        { say: 'both', send: ['app->api', 'api->db'] },
    ], { items, edges });
    assert.deepEqual(frames[1].visible, ['app', 'api', 'app->api']);
    assert.deepEqual(frames[1].send, ['api->app']);
    assert.deepEqual(frames[1].active, ['app->api']);
    assert.deepEqual(frames[2].send, ['app->api', 'api->db']);
    assert.deepEqual(frames[2].visible, ['app', 'api', 'db', 'app->api', 'api->db']);
});

test('a group in show stands for its nodes, and a group is visible while any member is', () => {
    const groups = [{ id: 'backend', nodes: ['api', 'db'] }];
    const frames = buildFrames([
        { say: 'client', show: ['app'] },
        { say: 'backend', show: ['backend'], state: { backend: 'error' } },
        { say: 'db gone', hide: ['db'] },
        { say: 'all gone', hide: ['backend'] },
    ], { items, edges, groups });
    assert.deepEqual(frames.map((frame) => frame.visible), [
        ['app'],
        ['app', 'api', 'db', 'app->api', 'api->db', 'backend'],
        ['app', 'api', 'app->api', 'backend'],
        ['app'],
    ]);
    assert.deepEqual(frames[1].states, { backend: 'error' });
});
