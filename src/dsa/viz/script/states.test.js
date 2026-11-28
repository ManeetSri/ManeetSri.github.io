import { test } from 'node:test';
import assert from 'node:assert/strict';
import { checkStates, parseEvent, statesFrames, statesLayout, statesModel, statesSummary, walkEvents } from './states.js';

// A background download
const download = () => ({
    states: [
        { id: 'idle', label: 'Idle', at: [0, 0] },
        { id: 'queued', label: 'Queued', at: [1, 0] },
        { id: 'downloading', label: 'Downloading', at: [2, 0] },
        { id: 'paused', label: 'Paused', at: [2, 1] },
        { id: 'failed', label: 'Failed', at: [1, 1] },
        { id: 'done', label: 'Done', at: [3, 0] },
    ],
    initial: 'idle',
    final: ['done'],
    transitions: [
        ['idle', 'queued', 'enqueue'],
        ['queued', 'downloading', 'start'],
        ['downloading', 'downloading', 'progress'],
        ['downloading', 'paused', 'pause'],
        ['paused', 'downloading', 'resume'],
        ['downloading', 'failed', 'error'],
        ['failed', 'queued', 'retry', 'attempts < 3'],
        ['failed', 'idle', 'retry', 'attempts = 3'],
        ['downloading', 'done', 'finish'],
    ],
    events: ['enqueue', 'start', 'progress', 'pause', 'resume', 'error', 'retry [attempts < 3]', { event: 'start', say: 'The queue picks it up again.' }, 'finish'],
});

const problem = (mutate) => {
    const props = download();
    mutate(props);
    const verdict = checkStates(props);
    assert.equal(typeof verdict, 'string', 'expected a problem');
    return verdict;
};

test('events parse from text with an optional guard, or from a mapping', () => {
    assert.deepEqual(parseEvent('pause'), { event: 'pause' });
    assert.deepEqual(parseEvent('retry [attempts < 3]'), { event: 'retry', guard: 'attempts < 3' });
    assert.deepEqual(parseEvent({ event: 'retry', guard: 'attempts = 3', say: 'Give up.' }), { event: 'retry', guard: 'attempts = 3', say: 'Give up.', line: undefined });
});

test('a realistic machine passes and walks to its final state', () => {
    assert.equal(checkStates(download()), true);
    const { steps, problem: none, final } = walkEvents(statesModel(download()));
    assert.equal(none, null);
    assert.equal(final, 'done');
    assert.deepEqual(steps.map((step) => step.to), ['queued', 'downloading', 'downloading', 'paused', 'downloading', 'failed', 'queued', 'downloading', 'done']);
});

test('frames start in the initial state, then light each state and transition taken', () => {
    const frames = statesFrames(download());
    assert.equal(frames.length, 10);
    assert.equal(frames[0].message, 'Starts in **Idle**.');
    assert.deepEqual(frames[0].states, { idle: 'active' });
    assert.equal(frames[0].transition, null);
    assert.equal(frames[1].message, '`enqueue`: **Idle** → **Queued**.');
    assert.deepEqual(frames[1].active, ['queued', 't0']);
    assert.deepEqual(frames[1].send, ['idle->queued']);
    assert.equal(frames[3].message, '`progress`: **Downloading** handles it and stays put.');
    assert.equal(frames[7].message, '`retry [attempts < 3]`: **Failed** → **Queued**.');
    assert.equal(frames[7].transition, 6);
    assert.equal(frames[8].message, 'The queue picks it up again.');
    assert.equal(frames[9].message, '`finish`: **Downloading** → **Done**. **Done** is a final state.');
    assert.equal(frames[9].current, 'done');
});

test('without events the machine is one still frame', () => {
    const { events: _unused, ...still } = download();
    const frames = statesFrames({ ...still, intro: 'A download’s life.' });
    assert.equal(frames.length, 1);
    assert.equal(frames[0].message, 'A download’s life.');
    assert.equal(frames[0].current, null);
});

test('the layout draws both directions as arcs on opposite sides and puts loops on a free side', () => {
    const layout = statesLayout(statesModel(download()));
    const pause = layout.edges.find((edge) => edge.key === 'downloading->paused');
    const resume = layout.edges.find((edge) => edge.key === 'paused->downloading');
    assert.match(pause.d, / Q /);
    assert.match(resume.d, / Q /);
    // Downloading sits above Paused, so the two arcs' labels go to either side
    const middle = layout.rects.downloading.x + layout.rects.downloading.w / 2;
    assert.ok((pause.label.x - middle) * (resume.label.x - middle) < 0, 'labels on opposite sides');
    const enqueue = layout.edges.find((edge) => edge.key === 'idle->queued');
    assert.match(enqueue.d, / L /);
    const loop = layout.edges.find((edge) => edge.self);
    assert.equal(loop.key, 'downloading->downloading');
    // Downloading has lines left, right and below, so its loop goes on top
    assert.ok(loop.label.y < layout.rects.downloading.y);
    // Two retry transitions leave Failed for different states: each its own edge
    assert.equal(layout.edges.filter((edge) => edge.from === 'failed').length, 2);
    assert.ok(layout.start.dot.x < layout.rects.idle.x, 'start marker on the left');
    Object.values(layout.rects).forEach((rect) => assert.ok(rect.x > 0 && rect.y > 0 && rect.x + rect.w < layout.width && rect.y + rect.h < layout.height));
    assert.ok(layout.edges.every((edge) => edge.label.y - edge.label.h / 2 > 0), 'labels inside the picture');
});

test('several transitions on one arrow stack their labels', () => {
    const layout = statesLayout(statesModel({
        states: [{ id: 'a', at: [0, 0] }, { id: 'b', at: [1, 0] }],
        initial: 'a',
        transitions: [['a', 'b', 'go'], ['a', 'b', 'jump'], ['a', 'a', 'tick'], ['a', 'a', 'tock']],
    }));
    const edge = layout.edges.find((entry) => entry.key === 'a->b');
    assert.deepEqual(edge.lines, [{ text: 'go', transition: 0 }, { text: 'jump', transition: 1 }]);
    assert.ok(edge.label.h > 26);
    assert.deepEqual(layout.edges.find((entry) => entry.self).lines.map((line) => line.text), ['tick', 'tock']);
});

test('guards get their own line, and labels keep clear of states and of each other', () => {
    const layout = statesLayout(statesModel(download()));
    const retry = layout.edges.find((edge) => edge.key === 'failed->queued');
    assert.deepEqual(retry.lines, [{ text: 'retry', transition: 6 }, { text: '[attempts < 3]', transition: 6, guard: true }]);
    // The text inside each plate (plates pad it by about 4 px, in the background colour)
    const boxes = layout.edges.map((edge) => ({ key: edge.key, x: edge.label.x - edge.label.w / 2 + 4, y: edge.label.y - edge.label.h / 2 + 2, w: edge.label.w - 8, h: edge.label.h - 4 }));
    const hit = (a, b) => a.x < b.x + b.w && b.x < a.x + a.w && a.y < b.y + b.h && b.y < a.y + a.h;
    boxes.forEach((a, i) => boxes.slice(i + 1).forEach((b) => assert.ok(!hit(a, b), `${a.key} and ${b.key} labels overlap`)));
    boxes.forEach((box) => Object.entries(layout.rects).forEach(([id, rect]) => assert.ok(!hit(box, rect), `${box.key} label covers ${id}`)));
});

test('the summary names states, the start and the transitions', () => {
    const summary = statesSummary(statesModel(download()));
    assert.match(summary, /^State machine with 6 states: Idle, Queued, Downloading, Paused, Failed, Done\. Starts in Idle; final: Done\./);
    assert.match(summary, /Failed to Queued on retry \[attempts < 3\]/);
});

test('the schema simulates the events and names the impossible one', () => {
    assert.match(problem((props) => { props.events = ['enqueue', 'pause']; }), /events\[1\] is `pause`, but after 1 event the machine is in `queued` and `queued` has no `pause` transition \(it handles `start`\)/);
    assert.match(problem((props) => { props.events = ['finish']; }), /after starting the machine is in `idle`/);
    assert.match(problem((props) => { props.events = ['enqueue', 'start', 'error', 'retry']; }), /events\[3\] is `retry`, which 2 transitions out of `failed` match; name the guard to pick one, like `retry \[attempts < 3\]`/);
    assert.match(problem((props) => { props.events = ['enqueue', 'start', 'error', 'retry [attempts > 9]']; }), /no `retry` transition out of `failed` has the guard \[attempts > 9\]/);
    assert.match(problem((props) => { props.events = ['enqueue', 'start', 'finish', 'start']; }), /`done` has no `start` transition \(nothing leaves it\)/);
});

test('the states schema explains what is wrong', () => {
    assert.match(checkStates({}), /needs `states`/);
    assert.match(problem((props) => { props.states[1].id = 'idle'; }), /`idle` is used twice/);
    assert.match(problem((props) => { props.states[1].at = [0, 0]; }), /states `idle` and `queued` overlap/);
    assert.match(problem((props) => { delete props.states[1].at; }), /needs `at: \[col, row\]`/);
    assert.match(problem((props) => { delete props.initial; }), /needs `initial`/);
    assert.match(problem((props) => { props.initial = 'start'; }), /`initial` names `start`, which isn't a state/);
    assert.match(problem((props) => { props.final = ['done', 'gone']; }), /`final` names `gone`/);
    assert.match(problem((props) => { props.transitions = []; }), /needs `transitions`/);
    assert.match(problem((props) => { props.transitions.push(['idle', 'nowhere', 'jump']); }), /transitions\[9\] names `nowhere`, which isn't a state/);
    assert.match(problem((props) => { props.transitions.push(['idle', 'done']); }), /must be \[from, to, event\]/);
    assert.match(problem((props) => { props.transitions.push(['idle', 'done', 'enqueue']); }), /transitions\[9\] and transitions\[0\] both leave `idle` on `enqueue`/);
    assert.match(problem((props) => { props.events = 'start'; }), /`events` must be a list/);
    assert.match(problem((props) => { props.events = [{ guard: 'x' }]; }), /events\[0\] needs `event`/);
    assert.match(problem((props) => { props.events = [42]; }), /events\[0\] must be an event name/);
});
