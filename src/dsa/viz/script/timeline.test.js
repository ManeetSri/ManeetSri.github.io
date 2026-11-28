import { test } from 'node:test';
import assert from 'node:assert/strict';
import { checkTimeline, formatTime, ticks, timelineFrames, timelineLayout, timelineModel, timelineSummary } from './timeline.js';

// Two devices edit the same note while one of them is offline
const conflict = () => ({
    unit: 's',
    lanes: [{ id: 'phone', label: 'iPhone' }, { id: 'server', label: 'Server' }, { id: 'mac', label: 'Mac' }],
    spans: [
        { lane: 'phone', from: 0, to: 4, label: 'offline edit: "Groceries"', tone: 'wait' },
        { lane: 'mac', from: 1, to: 2, label: 'edit: "Shopping"', tone: 'active' },
        { lane: 'server', from: 2, to: 2.5, label: 'v2', tone: 'ok' },
        { lane: 'phone', from: 4, to: 5, label: 'upload (based on v1)' },
        { lane: 'server', from: 5, to: 5.6, label: 'conflict', tone: 'error' },
        { lane: 'phone', from: 5.6, to: 7, label: 'merge', tone: 'ok' },
    ],
    markers: [{ at: 2, label: 'Mac syncs' }, { at: 4, label: 'back online' }, { at: 4.2, label: 'retry' }],
    steps: [
        { at: 0, say: 'The iPhone goes offline and keeps editing.' },
        { at: 1.5, say: 'Meanwhile the Mac edits the same note.' },
        { at: 2.5, say: 'The server stores the Mac’s version as **v2**.' },
        { at: 4.5, say: 'The iPhone reconnects and uploads an edit based on v1.' },
        { at: 5.3, say: 'The server sees two edits of v1: a **conflict**.' },
        { at: 7, say: 'The client merges both titles.' },
    ],
});

const problem = (mutate) => {
    const props = conflict();
    mutate(props);
    const verdict = checkTimeline(props);
    assert.equal(typeof verdict, 'string', 'expected a problem');
    return verdict;
};

test('a realistic timeline passes', () => {
    assert.equal(checkTimeline(conflict()), true);
    assert.equal(checkTimeline({ lanes: [{ id: 'a' }], markers: [{ at: 3, label: 'now' }] }), true);
});

test('spans and markers appear as the cursor reaches them; running spans are active', () => {
    const frames = timelineFrames(conflict());
    assert.equal(frames.length, 6);
    assert.deepEqual(frames.map((frame) => frame.at), [0, 1.5, 2.5, 4.5, 5.3, 7]);
    assert.deepEqual(frames[0].visible, ['s0']);
    assert.deepEqual(frames[1].visible, ['s0', 's1']);
    assert.deepEqual(frames[1].active, ['s0', 's1']);
    assert.deepEqual(frames[2].visible, ['s0', 's1', 's2', 'm0']);
    assert.deepEqual(frames[2].active, ['s0']);
    assert.deepEqual(frames[3].active, ['s3']);
    assert.deepEqual(frames[3].visible.filter((id) => id.startsWith('m')), ['m0', 'm1', 'm2']);
    assert.deepEqual(frames[5].active, []);
});

test('without steps the timeline is one still frame showing everything', () => {
    const { steps: _unused, ...still } = conflict();
    const [frame] = timelineFrames({ ...still, caption: 'Last write would lose the iPhone’s edit.' });
    assert.equal(frame.at, null);
    assert.equal(frame.visible.length, 9);
    assert.equal(frame.message, 'Last write would lose the iPhone’s edit.');
});

test('the axis starts at zero unless told otherwise, with round ticks', () => {
    const model = timelineModel(conflict());
    assert.equal(model.start, 0);
    assert.equal(model.end, 7);
    assert.deepEqual(ticks(0, 7), [0, 2, 4, 6]);
    assert.deepEqual(ticks(0, 900), [0, 200, 400, 600, 800]);
    assert.deepEqual(ticks(1000, 1600), [1000, 1100, 1200, 1300, 1400, 1500, 1600]);
    assert.equal(timelineModel({ ...conflict(), start: 1, end: 8 }).start, 1);
    assert.equal(formatTime(0.1 + 0.2, 's'), '0.3 s');
    assert.equal(formatTime(120, 'ms'), '120 ms');
});

test('the layout stacks close marker labels and keeps span labels readable', () => {
    const layout = timelineLayout(timelineModel(conflict()));
    const rows = Object.fromEntries(layout.markers.map((marker) => [marker.label, marker.row]));
    assert.equal(rows['back online'], 0);
    assert.equal(rows.retry, 1, 'too close to "back online" to share its row');
    const spans = layout.spans;
    assert.equal(spans[0].label.inside, true);
    assert.equal(spans[0].label.text, 'offline edit: "Groceries"');
    // The 0.5 s "v2" span is narrow, but its label still fits inside
    assert.equal(spans[2].label.inside, true);
    // "conflict" doesn't fit in 0.6 s, but there's free room after it in the server lane
    assert.deepEqual([spans[4].label.inside, spans[4].label.anchor], [false, 'start']);
    assert.ok(layout.lanes.every((lane, index) => index === 0 || lane.y > layout.lanes[index - 1].y));
    assert.ok(layout.x(7) <= layout.width && layout.x(0) > layout.labelW);
});

test('the summary reads out lanes, spans and markers', () => {
    const summary = timelineSummary(timelineModel(conflict()));
    assert.match(summary, /^Timeline with lanes iPhone, Server, Mac\./);
    assert.match(summary, /Server: conflict from 5 s to 5\.6 s/);
    assert.match(summary, /Markers: Mac syncs at 2 s; back online at 4 s; retry at 4\.2 s\./);
});

test('the timeline schema explains what is wrong', () => {
    assert.match(checkTimeline({}), /needs `lanes`/);
    assert.match(problem((props) => { props.unit = 'hours'; }), /unit `hours` isn't one of ms, s, min/);
    assert.match(problem((props) => { props.lanes[1].id = 'phone'; }), /`phone` is used twice/);
    assert.match(problem((props) => { props.spans = []; props.markers = []; }), /there is nothing to draw/);
    assert.match(problem((props) => { props.spans[1].lane = 'ipad'; }), /spans\[1\] is in lane `ipad`, which isn't a lane \(lanes: `phone`, `server`, `mac`\)/);
    assert.match(problem((props) => { props.spans[1].to = 1; }), /`to` must be later \(use a marker for an instant\)/);
    assert.match(problem((props) => { props.spans[1].from = 'soon'; }), /needs numbers for `from` and `to`/);
    assert.match(problem((props) => { props.spans[1].tone = 'warning'; }), /tone `warning` isn't one of neutral, active, ok, error, wait/);
    assert.match(problem((props) => { props.spans[3].from = 3.5; }), /spans\[0\] and spans\[3\] overlap in lane `phone`/);
    assert.match(problem((props) => { props.markers[0] = { at: 2 }; }), /markers\[0\] needs `label`/);
    assert.match(problem((props) => { props.markers[0].at = 'later'; }), /markers\[0\] needs `at`/);
    assert.match(problem((props) => { props.start = 3; props.end = 1; }), /`start` must come before `end`/);
    assert.match(problem((props) => { props.end = 6; }), /spans\[5\]\.to is 7, after `end` \(6\)/);
});

test('timeline steps must not go back in time', () => {
    assert.match(problem((props) => { props.steps[2].at = 1; }), /steps\[2\] is at 1, before the previous step \(1\.5\); the cursor only moves forward/);
    assert.match(problem((props) => { props.steps[0] = { say: 'x' }; }), /steps\[0\] needs `at`/);
    assert.match(problem((props) => { props.steps[0] = { at: 0 }; }), /steps\[0\] needs `say`/);
    assert.match(problem((props) => { props.steps = []; }), /`steps` must be a list/);
    // Two steps at the same moment are fine: one can explain what the other shows
    assert.equal(checkTimeline({ ...conflict(), steps: [{ at: 1, say: 'a' }, { at: 1, say: 'b' }] }), true);
});
