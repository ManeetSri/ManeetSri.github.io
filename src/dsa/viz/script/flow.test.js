import { test } from 'node:test';
import assert from 'node:assert/strict';
import { checkFlow, edgeLabelAt, flowFrames, flowLayout, flowModel, flowSummary, normaliseEdge } from './flow.js';

// A token refresh across App → API client → Auth server
const refresh = () => ({
    layers: [{ label: 'Device', rows: [0, 0] }, { label: 'Backend', rows: 2 }],
    nodes: [
        { id: 'app', label: 'App', kind: 'client', at: [0, 0] },
        { id: 'client', label: 'API client', kind: 'service', at: [2, 0] },
        { id: 'keychain', label: 'Keychain', kind: 'store', at: [4, 0] },
        { id: 'api', label: 'API', kind: 'service', at: [1, 2] },
        { id: 'auth', label: 'Auth server', kind: 'external', at: [3, 2] },
    ],
    groups: [{ id: 'phone', label: 'iPhone', nodes: ['app', 'client', 'keychain'] }],
    edges: [
        ['app', 'client', 'GET /me'],
        ['client', 'keychain', 'token', { style: 'data' }],
        ['client', 'api', 'request'],
        ['api', 'client', 'response'],
        ['client', 'auth', 'refresh', { style: 'async' }],
        { from: 'auth', to: 'client', label: 'new tokens' },
    ],
    steps: [
        { say: 'The app asks for the profile.', show: ['app', 'client'], send: 'app->client' },
        { say: 'The client reads the token.', show: ['keychain'], send: 'client->keychain' },
        { say: 'It calls the API.', show: ['api'], send: 'client->api' },
        { say: 'Expired: `401`.', send: 'api->client', state: { api: 'error' }, label: { 'api->client': '401' } },
        { say: 'One refresh; others wait.', show: ['auth'], send: 'client->auth', state: { client: 'wait' }, label: { client: 'refreshing' } },
        { say: 'New tokens arrive.', send: 'auth->client', state: { auth: 'ok', client: null }, label: { client: null } },
        { say: 'Back to the app.', send: 'client->app', active: ['app'], line: 3 },
    ],
});

const problem = (mutate) => {
    const props = refresh();
    mutate(props);
    const verdict = checkFlow(props);
    assert.equal(typeof verdict, 'string', 'expected a problem');
    return verdict;
};

test('a realistic flow passes, and a bare one with nodes only does too', () => {
    assert.equal(checkFlow(refresh()), true);
    assert.equal(checkFlow({ nodes: [{ id: 'a', at: [0, 0] }] }), true);
});

test('edges normalise from lists or mappings, with options third or fourth', () => {
    assert.deepEqual(normaliseEdge(['a', 'b']), { from: 'a', to: 'b', label: '', style: 'sync' });
    assert.deepEqual(normaliseEdge(['a', 'b', { style: 'async' }]), { from: 'a', to: 'b', label: '', style: 'async' });
    assert.deepEqual(normaliseEdge(['a', 'b', 'push', { style: 'data' }]), { from: 'a', to: 'b', label: 'push', style: 'data' });
    assert.deepEqual(normaliseEdge({ from: 'a', to: 'b', label: 'x' }), { from: 'a', to: 'b', label: 'x', style: 'sync' });
});

test('flow frames reveal parts step by step and travel both ways along an edge', () => {
    const frames = flowFrames(refresh());
    assert.equal(frames.length, 7);
    assert.deepEqual(frames[0].visible, ['app', 'client', 'app->client', 'phone']);
    assert.ok(frames[2].visible.includes('client->api') && frames[2].visible.includes('api->client'));
    assert.deepEqual(frames[3].labels, { 'api->client': '401' });
    assert.deepEqual(frames[4].states, { api: 'error', client: 'wait' });
    assert.deepEqual(frames[5].states, { api: 'error', auth: 'ok' });
    assert.deepEqual(frames[5].labels, { 'api->client': '401' });
    assert.deepEqual(frames[6].send, ['client->app']);
    assert.equal(frames[6].line, 3);
    assert.equal(frames.at(-1).visible.length, 5 + 6 + 1);
});

test('a flow without steps is one still frame with its caption', () => {
    const { steps: _unused, ...still } = refresh();
    const frames = flowFrames({ ...still, caption: 'The parts involved.' });
    assert.equal(frames.length, 1);
    assert.equal(frames[0].message, 'The parts involved.');
    assert.equal(frames[0].visible.length, 12);
});

test('the layout clips edges, offsets opposite pairs and wraps groups around their nodes', () => {
    const layout = flowLayout(flowModel(refresh()));
    const there = layout.edges.find((edge) => edge.key === 'client->api');
    const back = layout.edges.find((edge) => edge.key === 'api->client');
    assert.ok(there.paired && back.paired);
    // Offset to opposite sides: the two lines run 14 apart, measured across them
    const across = (there.mid.x - back.mid.x) * there.normal.x + (there.mid.y - back.mid.y) * there.normal.y;
    assert.ok(Math.abs(across - 14) < 1e-6, `${across}`);
    const single = layout.edges.find((edge) => edge.key === 'app->client');
    assert.equal(single.paired, false);
    const app = layout.rects.app;
    const client = layout.rects.client;
    assert.equal(single.start.x, app.x + app.w + 2);
    assert.equal(single.end.x, client.x - 3);
    const phone = layout.groups[0].rect;
    ['app', 'client', 'keychain'].forEach((id) => {
        const rect = layout.rects[id];
        assert.ok(rect.x > phone.x && rect.y > phone.y && rect.x + rect.w < phone.x + phone.w && rect.y + rect.h < phone.y + phone.h, `${id} inside the group`);
    });
    assert.equal(layout.gutter, 24);
    assert.equal(layout.layers.length, 2);
    assert.ok(layout.rects.app.x >= 24, 'room for layer labels');
    assert.ok(layout.width > layout.rects.keychain.x + layout.rects.keychain.w);
});

test('edge labels sit on the line, beside it for a pair, and off it when the line is too short', () => {
    const layout = flowLayout(flowModel(refresh()));
    const edge = (key) => layout.edges.find((entry) => entry.key === key);
    // App → API client spans an empty column: the label fits on the line
    assert.deepEqual(edgeLabelAt(edge('app->client'), 'GET /me'), edge('app->client').mid);
    const there = edgeLabelAt(edge('client->api'), 'request');
    const back = edgeLabelAt(edge('api->client'), 'response');
    const n = edge('client->api').normal;
    const side = (point) => (point.x - edge('client->api').mid.x) * n.x + (point.y - edge('client->api').mid.y) * n.y;
    assert.ok(side(there) > 0 && side(back) < 0, 'pair labels on opposite sides');
    // Neighbouring cells leave a 28 px line: a long label moves into the row gap below it
    const near = flowLayout(flowModel({ nodes: [{ id: 'a', at: [0, 0] }, { id: 'b', at: [1, 0] }], edges: [['a', 'b', 'a long label']] }));
    const label = edgeLabelAt(near.edges[0], 'a long label');
    assert.ok(label.y - near.rects.a.y - near.rects.a.h >= 8, 'clear of the boxes');
    assert.ok(label.y + 9 <= near.height, 'and inside the picture');
    const apart = flowLayout(flowModel({ nodes: [{ id: 'a', at: [0, 0] }, { id: 'b', at: [2, 0] }], edges: [['a', 'b', 'a long label']] }));
    assert.deepEqual(edgeLabelAt(apart.edges[0], 'a long label'), apart.edges[0].mid);
});

test('nested groups get their own margins', () => {
    const layout = flowLayout(flowModel({
        nodes: [{ id: 'a', at: [0, 0] }, { id: 'b', at: [1, 0] }],
        groups: [{ id: 'outer', nodes: ['a', 'b'] }, { id: 'inner', nodes: ['a', 'b'] }],
    }));
    const [outer, inner] = layout.groups.map((group) => group.rect);
    // Same members: the first listed is drawn around the other. Both wrap a and b.
    assert.ok(outer.w >= inner.w && outer.h >= inner.h);
});

test('the summary names the parts and connections', () => {
    const summary = flowSummary(flowModel(refresh()));
    assert.match(summary, /^Flow diagram of 5 parts: App \(client\), API client \(service\)/);
    assert.match(summary, /API client to Auth server: refresh \(async\)/);
    assert.match(summary, /iPhone contains App, API client, Keychain/);
});

test('the flow schema explains what is wrong', () => {
    assert.match(checkFlow({}), /needs `nodes`/);
    assert.match(problem((props) => { props.nodes[1].id = 'app'; }), /`app` is used twice/);
    assert.match(problem((props) => { props.groups[0].id = 'api'; }), /`api` is used twice/);
    assert.match(problem((props) => { props.nodes[0].kind = 'phone'; }), /kind `phone` isn't one of client, view/);
    assert.match(problem((props) => { delete props.nodes[2].at; }), /nodes\[2\] \(`keychain`\) needs `at: \[col, row\]`/);
    assert.match(problem((props) => { props.nodes[2].at = [-1, 0]; }), /needs `at/);
    assert.match(problem((props) => { props.nodes[2].w = 0; }), /`w` is its width/);
    assert.match(problem((props) => { props.nodes[0].id = 'app server'; }), /no spaces/);
    assert.match(problem((props) => { props.nodes[0].id = 7; }), /quote numbers/);
    assert.match(problem((props) => { props.nodes[3].at = [1.5, 0]; }), /nodes `client` and `api` overlap/);
    assert.match(problem((props) => { props.groups[0].nodes.push('cdn'); }), /groups\[0\] \(`phone`\) lists `cdn`, which isn't a node/);
    assert.match(problem((props) => { props.groups[0].nodes = []; }), /needs `nodes`/);
    assert.match(problem((props) => { props.layers[0].rows = [2, 1]; }), /put the smaller row first/);
    assert.match(problem((props) => { props.layers[0].rows = 'top'; }), /needs `rows: \[from, to\]`/);
    assert.match(problem((props) => { props.edges.push(['app', 'cache']); }), /edges\[6\] \(`app->cache`\) names `cache`, which isn't a node \(nodes: `app`, `client`/);
    assert.match(problem((props) => { props.edges.push(['app', 'app']); }), /to itself/);
    assert.match(problem((props) => { props.edges.push(['app', 'client']); }), /repeats the edge `app->client`/);
    assert.match(problem((props) => { props.edges[0] = ['app', 'client', 'GET', { style: 'stream' }]; }), /style `stream` isn't one of sync, async, data/);
    assert.match(problem((props) => { props.edges[0] = ['app']; }), /edges\[0\] must be/);
});

test('the flow schema checks every step reference', () => {
    assert.match(problem((props) => { delete props.steps[1].say; }), /steps\[1\] needs `say`/);
    assert.match(problem((props) => { props.steps[0].show = ['app', 'cdn']; }), /steps\[0\]\.show names `cdn`, which isn't a node, group or edge/);
    assert.match(problem((props) => { props.steps[0].active = ['app->keychain']; }), /steps\[0\]\.active names `app->keychain`, but there's no edge/);
    assert.match(problem((props) => { props.steps[0].send = 'app->auth'; }), /steps\[0\]\.send names `app->auth`, but there's no edge between those nodes/);
    assert.match(problem((props) => { props.steps[0].send = 'app'; }), /write an edge as from->to/);
    assert.match(problem((props) => { props.steps[3].state = { api: 'broken' }; }), /tone `broken`; use one of neutral, active, ok, error, wait/);
    assert.match(problem((props) => { props.steps[3].state = { cdn: 'error' }; }), /steps\[3\]\.state names `cdn`/);
    assert.match(problem((props) => { props.steps[3].label = { phone: 'x' }; }), /names the group `phone`; only nodes and edges go here/);
    assert.match(problem((props) => { props.steps[3].label = 'x'; }), /must be a mapping of id: text/);
    assert.match(problem((props) => { props.steps[0].reset = 'yes'; }), /reset must be true or false/);
    assert.match(problem((props) => { props.steps[0].line = 0; }), /`line` must be a line number/);
    assert.match(problem((props) => { props.steps = 'go'; }), /`steps` must be a list/);
    // Either direction names the declared edge
    assert.equal(checkFlow({ ...refresh(), steps: [{ say: 'ok', active: ['client->app'], show: ['keychain->client'] }] }), true);
});
