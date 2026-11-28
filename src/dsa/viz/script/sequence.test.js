import { test } from 'node:test';
import assert from 'node:assert/strict';
import { checkSequence, sequenceFrames, sequenceLayout, sequenceModel, sequenceSummary } from './sequence.js';

// Sign in with OAuth and PKCE
const pkce = () => ({
    participants: [
        { id: 'app', label: 'App' },
        { id: 'session', label: 'Auth session' },
        { id: 'auth', label: 'Auth server' },
        { id: 'api', label: 'API' },
    ],
    messages: [
        ['app', 'app', 'make verifier + challenge'],
        { note: 'Only the challenge leaves the device', over: 'app' },
        ['app', 'session', 'open /authorize?challenge'],
        ['session', 'auth', 'GET /authorize'],
        ['auth', 'session', 'login page', { reply: true }],
        ['session', 'app', 'callback ?code', { reply: true, say: 'The redirect hands the app a one-time **code**.' }],
        ['app', 'auth', 'POST /token (code, verifier)'],
        ['auth', 'app', 'access + refresh tokens', { reply: true }],
        ['auth', 'app', 'invalid_grant', { reply: true }],
        ['app', 'api', 'GET /me', { async: true }],
        { note: 'Bearer token on every call', over: ['app', 'api'] },
    ],
    fragments: [
        { kind: 'opt', label: 'no session cookie', from: 3, to: 4 },
        { kind: 'alt', label: 'verifier matches', from: 7, to: 8, else: 8, elseLabel: 'mismatch' },
        { kind: 'loop', label: 'until signed in', from: 2, to: 8 },
    ],
});

const problem = (mutate) => {
    const props = pkce();
    mutate(props);
    const verdict = checkSequence(props);
    assert.equal(typeof verdict, 'string', 'expected a problem');
    return verdict;
};

test('a realistic sequence passes', () => {
    assert.equal(checkSequence(pkce()), true);
    assert.equal(checkSequence({ ...pkce(), steps: [{ say: 'Before anything', upTo: -1 }, { say: 'Start', upTo: 2 }, { say: 'Again', upTo: 2 }] }), true);
});

test('one frame per message by default, with a readable default message', () => {
    const frames = sequenceFrames(pkce());
    assert.equal(frames.length, 11);
    assert.equal(frames[0].message, 'App → App: make verifier + challenge');
    assert.equal(frames[1].message, 'Only the challenge leaves the device');
    assert.equal(frames[5].message, 'The redirect hands the app a one-time **code**.');
    assert.deepEqual(frames[3].visible, ['m0', 'm1', 'm2', 'm3']);
    assert.deepEqual(frames[3].active, ['m3']);
    assert.deepEqual(frames[3].send, ['session->auth']);
    assert.deepEqual(frames[1].send, []);
    assert.equal(frames[3].upTo, 3);
});

test('steps reveal several messages at once and can pause before the first', () => {
    const frames = sequenceFrames({ ...pkce(), steps: [{ say: 'Nothing yet', upTo: -1 }, { say: 'Set up', upTo: 2, line: 5 }, { say: 'Still there', upTo: 2 }, { say: 'Round trip', upTo: 5 }] });
    assert.deepEqual(frames.map((frame) => frame.active), [[], ['m0', 'm1', 'm2'], ['m2'], ['m3', 'm4', 'm5']]);
    assert.deepEqual(frames[0].visible, []);
    assert.equal(frames[1].line, 5);
});

test('the layout widens gaps for long labels and nests fragments', () => {
    const layout = sequenceLayout(sequenceModel(pkce()));
    const [app, session, auth] = layout.participants;
    assert.ok(session.x - app.x >= 120);
    // 'POST /token (code, verifier)' spans two gaps; each must hold half of it
    assert.ok(auth.x - app.x >= 28 * 6.3 + 24);
    const [opt, alt, loop] = layout.fragments;
    assert.ok(loop.top < opt.top && loop.bottom > alt.bottom, 'loop wraps the others vertically');
    assert.ok(loop.x < opt.x && loop.x + loop.w > alt.x + alt.w, 'and horizontally');
    assert.ok(alt.elseY > alt.top && alt.elseY < alt.bottom);
    const rows = layout.rows;
    assert.equal(rows[0].self, true);
    assert.ok(rows[0].loopBottom > rows[0].y);
    assert.ok(rows.every((row, index) => index === 0 || (row.y ?? row.box.y) > (rows[index - 1].y ?? rows[index - 1].box.y)), 'rows go down the page');
    assert.ok(layout.fragments.every((fragment) => fragment.x >= 0 && fragment.x + fragment.w <= layout.width));
});

test('the summary lists the participants and messages', () => {
    const summary = sequenceSummary(sequenceModel(pkce()));
    assert.match(summary, /^Sequence diagram between App, Auth session, Auth server and API, with 9 messages\./);
    assert.match(summary, /5\. Auth server to Auth session \(reply\): login page/);
});

test('the sequence schema explains what is wrong', () => {
    assert.match(checkSequence({}), /needs `participants`/);
    assert.match(problem((props) => { props.participants.push({ id: 'app' }); }), /`app` is used twice/);
    assert.match(problem((props) => { props.messages = []; }), /needs `messages`/);
    assert.match(problem((props) => { props.messages[2] = ['app', 'browser', 'open']; }), /messages\[2\] names `browser`, which isn't a participant \(participants: `app`, `session`/);
    assert.match(problem((props) => { props.messages[2] = ['app', 'session']; }), /must be \[from, to, text\]/);
    assert.match(problem((props) => { props.messages[2] = ['app', 'session', '']; }), /needs the message text/);
    assert.match(problem((props) => { props.messages[2] = ['app', 'session', 'x', 'reply']; }), /fourth item must be options/);
    assert.match(problem((props) => { props.messages[2] = ['app', 'session', 'x', { reply: 'yes' }]; }), /`reply` must be true or false/);
    assert.match(problem((props) => { props.messages[1] = { note: 'hi' }; }), /needs `over`/);
    assert.match(problem((props) => { props.messages[1] = { note: 'hi', over: ['app', 'db'] }; }), /messages\[1\]\.over names `db`/);
    assert.match(problem((props) => { props.messages[1] = { text: 'hi' }; }), /must be \[from, to, text\]/);
});

test('the sequence schema checks fragments and steps', () => {
    assert.match(problem((props) => { props.fragments[0].kind = 'break'; }), /kind `break` isn't one of loop, alt, opt, par/);
    assert.match(problem((props) => { props.fragments[0].to = 11; }), /fragments\[0\]\.to must be a message index from 0 to 10 \(got 11\)/);
    assert.match(problem((props) => { props.fragments[0].from = 5; }), /`from` comes first/);
    assert.match(problem((props) => { props.fragments[1].else = 7; }), /fragments\[1\]\.else must be the index of a message after `from`/);
    assert.match(problem((props) => { props.fragments[2].to = 7; }), /fragments\[1\] \(7–8\) and fragments\[2\] \(2–7\) cross/);
    assert.match(problem((props) => { props.steps = [{ say: 'a', upTo: 3 }, { say: 'b', upTo: 1 }]; }), /steps\[1\]\.upTo is 1, before the previous step's 3/);
    assert.match(problem((props) => { props.steps = [{ say: 'a', upTo: 11 }]; }), /steps\[0\]\.upTo must be a message index from 0 to 10/);
    assert.match(problem((props) => { props.steps = [{ upTo: 1 }]; }), /steps\[0\] needs `say`/);
    assert.match(problem((props) => { props.steps = []; }), /`steps` must be a list/);
});
