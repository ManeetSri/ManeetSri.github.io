// ```visual states: a state machine on a grid. Transitions are [from, to, event, guard?]; an `events`
// list is walked from the initial state, one frame per event, lighting the current state and the
// transition taken. The schema runs the same walk, so an event that can't happen fails the build.
// Pure; views/StatesView.jsx draws it.
import { arcBetweenRects, exitRect, placeLabel, pointAt, rectCenter, segmentBetweenRects, selfLoop, textWidth } from '../svg.js';
import { asList } from './frames.js';
import { checkAt, checkEntries, checkLine, fail, isObject, isText, listOf, need, optionalText, overlaps, quote, schema } from './check.js';

const CELL_W = 172;
const CELL_H = 112;
export const BOX_W = 120;
export const BOX_H = 44;
const MARGIN = 14;
const BEND = 20;
const LINE_H = 13;
export const LABEL_FONT = 10.5;
const DOT_GAP = 30;

// 'retry [attempts < 3]' → { event: 'retry', guard: 'attempts < 3' }
export const parseEvent = (entry) => {
    if (isObject(entry)) {
        return { event: String(entry.event ?? '').trim(), guard: entry.guard === undefined || entry.guard === null ? undefined : String(entry.guard).trim(), say: entry.say, line: entry.line };
    }
    const text = String(entry ?? '').trim();
    const match = text.match(/^(.*?)\s*\[(.*)\]$/);
    return match ? { event: match[1].trim(), guard: match[2].trim() } : { event: text };
};

export const transitionText = (transition) => `${transition.event}${transition.guard ? ` [${transition.guard}]` : ''}`;

export const statesModel = (props = {}) => ({
    states: (props.states ?? []).map((state) => ({ id: state.id, label: String(state.label ?? state.id), col: state.at[0], row: state.at[1] })),
    initial: props.initial,
    final: asList(props.final),
    transitions: (props.transitions ?? []).map(([from, to, event, guard], index) => ({
        index, from: String(from), to: String(to), event: String(event).trim(), guard: guard === undefined || guard === null ? undefined : String(guard).trim(),
    })),
    events: asList(props.events).map(parseEvent),
    intro: props.intro,
});

// Walks the events from the initial state. Stops at the first one that can't happen, with the reason.
export const walkEvents = (model) => {
    let current = model.initial;
    const steps = [];
    for (const [index, entry] of model.events.entries()) {
        const leaving = model.transitions.filter((transition) => transition.from === current);
        const named = leaving.filter((transition) => transition.event === entry.event);
        const matches = entry.guard === undefined ? named : named.filter((transition) => transition.guard === entry.guard);
        const written = entry.guard === undefined ? quote(entry.event) : quote(`${entry.event} [${entry.guard}]`);
        if (!matches.length) {
            const handled = [...new Set(leaving.map(transitionText))];
            const reason = named.length
                ? `no \`${entry.event}\` transition out of ${quote(current)} has the guard [${entry.guard}] (guards: ${named.map((transition) => `[${transition.guard ?? ''}]`).join(', ')})`
                : `${quote(current)} has no ${quote(entry.event)} transition (${handled.length ? `it handles ${listOf(handled)}` : "nothing leaves it"})`;
            return { steps, problem: `events[${index}] is ${written}, but after ${steps.length ? `${steps.length} event${steps.length === 1 ? '' : 's'}` : 'starting'} the machine is in ${quote(current)} and ${reason}` };
        }
        if (matches.length > 1) {
            return { steps, problem: `events[${index}] is ${written}, which ${matches.length} transitions out of ${quote(current)} match; name the guard to pick one, like ${quote(transitionText(matches[0]))}` };
        }
        const [transition] = matches;
        steps.push({ entry, transition, from: current, to: transition.to });
        current = transition.to;
    }
    return { steps, problem: null, final: current };
};

export const statesFrames = (props = {}) => {
    const model = statesModel(props);
    const label = Object.fromEntries(model.states.map((state) => [state.id, state.label]));
    const all = [...model.states.map((state) => state.id), ...model.transitions.map((transition) => `t${transition.index}`)];
    const finals = new Set(model.final);
    const intro = model.intro === undefined ? undefined : String(model.intro);
    if (!model.events.length) {
        return [{ message: intro ?? '', visible: all, active: [], states: {}, labels: {}, send: [], current: null, transition: null }];
    }
    const { steps } = walkEvents(model);
    const start = { message: intro ?? `Starts in **${label[model.initial]}**.`, visible: all, active: [model.initial], states: { [model.initial]: 'active' }, labels: {}, send: [], current: model.initial, transition: null };
    return [start, ...steps.map(({ entry, transition, from, to }) => {
        const move = from === to ? `**${label[from]}** handles it and stays put.` : `**${label[from]}** → **${label[to]}**.`;
        const ending = finals.has(to) ? ` **${label[to]}** is a final state.` : '';
        const frame = {
            message: entry.say === undefined ? `\`${transitionText(transition)}\`: ${move}${ending}` : String(entry.say),
            visible: all,
            active: [to, `t${transition.index}`],
            states: { [to]: 'active' },
            labels: {},
            send: [`${from}->${to}`],
            current: to,
            transition: transition.index,
        };
        if (entry.line !== undefined) frame.line = entry.line;
        return frame;
    })];
};

const stateRect = (state) => ({ x: state.col * CELL_W, y: state.row * CELL_H, w: BOX_W, h: BOX_H });
// A transition's label: the event, with its guard on a line of its own so labels stay narrow
const labelLines = (transitions) => transitions.flatMap((transition) => [
    { text: transition.event, transition: transition.index },
    ...(transition.guard ? [{ text: `[${transition.guard}]`, transition: transition.index, guard: true }] : []),
]);
const blockSize = (lines) => ({ w: Math.max(...lines.map((line) => textWidth(line.text, LABEL_FONT))) + 10, h: lines.length * LINE_H + 5 });
const boxAt = (centre, size) => ({ x: centre.x - size.w / 2, y: centre.y - size.h / 2, w: size.w, h: size.h });
const grow = (rect, by) => ({ x: rect.x - by, y: rect.y - by, w: rect.w + by * 2, h: rect.h + by * 2 });
const sideOf = (from, to) => {
    const dx = to.x - from.x;
    const dy = to.y - from.y;
    if (Math.abs(dx) >= Math.abs(dy)) return dx >= 0 ? 'right' : 'left';
    return dy >= 0 ? 'bottom' : 'top';
};
const OUT = { top: { x: 0, y: -1 }, bottom: { x: 0, y: 1 }, left: { x: -1, y: 0 }, right: { x: 1, y: 0 } };

// The edges, labels, loops and start marker for states placed at `rects`
const geometry = (model, rects) => {
    const pairs = new Map();
    model.transitions.forEach((transition) => {
        const key = `${transition.from}->${transition.to}`;
        if (!pairs.has(key)) pairs.set(key, []);
        pairs.get(key).push(transition);
    });
    // Which sides of each state already have lines, so loops and the start marker go somewhere free
    const busy = Object.fromEntries(model.states.map((state) => [state.id, { top: 0, bottom: 0, left: 0, right: 0 }]));
    model.transitions.filter((transition) => transition.from !== transition.to).forEach((transition) => {
        const a = rectCenter(rects[transition.from]);
        const b = rectCenter(rects[transition.to]);
        busy[transition.from][sideOf(a, b)] += 1;
        busy[transition.to][sideOf(b, a)] += 1;
    });
    const freeSide = (id, preference) => preference.reduce((best, side) => (busy[id][side] < busy[id][best] ? side : best), preference[0]);

    const start = (() => {
        const rect = rects[model.initial];
        if (!rect) return null;
        const side = freeSide(model.initial, ['left', 'top', 'bottom', 'right']);
        busy[model.initial][side] += 1;
        const centre = rectCenter(rect);
        const out = OUT[side];
        const reach = side === 'left' || side === 'right' ? rect.w / 2 + DOT_GAP : rect.h / 2 + DOT_GAP;
        const dot = { x: centre.x + out.x * reach, y: centre.y + out.y * reach };
        const tip = exitRect(rect, centre, dot, 2);
        return { dot, d: `M ${dot.x} ${dot.y} L ${tip.x} ${tip.y}` };
    })();

    const shapes = [...pairs.entries()].map(([key, transitions]) => {
        const { from, to } = transitions[0];
        const lines = labelLines(transitions);
        const size = blockSize(lines);
        if (from === to) {
            const side = freeSide(from, ['top', 'bottom', 'right', 'left']);
            busy[from][side] += 1;
            const loop = selfLoop(rects[from], side, { reach: 38, spread: 16 });
            const reach = loop.out.x ? size.w / 2 + 5 : size.h / 2 + 4;
            const spots = [{ x: loop.apex.x + loop.out.x * reach, y: loop.apex.y + loop.out.y * reach }];
            return { key, from, to, transitions, lines, size, d: loop.d, start: loop.start, end: loop.end, spots, self: true, order: 0 };
        }
        const bidirectional = pairs.has(`${to}->${from}`);
        const shape = bidirectional
            ? arcBetweenRects(rects[from], rects[to], BEND, { gapStart: 2, gapEnd: 3 })
            : segmentBetweenRects(rects[from], rects[to], { gapStart: 2, gapEnd: 3 });
        const n = shape.normal;
        // Where the label may go, best first: an arc's label sits outside its bulge; a straight line's
        // label sits on the line, or beside it when the line is short or the middle is taken
        // `aside` clears the line; `clear` also clears the states beside a short line
        const aside = Math.abs(n.x) * (size.w / 2 + 5) + Math.abs(n.y) * (size.h / 2 + 4);
        const clear = Math.abs(n.x) * (size.w / 2 + 6) + Math.abs(n.y) * (BOX_H / 2 + size.h / 2 + 9);
        const shifted = (t, by) => {
            const point = pointAt(shape, t);
            return { x: point.x + n.x * by, y: point.y + n.y * by };
        };
        const spread = [0.5, 0.4, 0.6, 0.3, 0.7];
        // Beside a line, try above a flat line first and right of a steep one
        const first = (Math.abs(n.y) >= Math.abs(n.x) ? n.y < 0 : n.x > 0) ? 1 : -1;
        const spots = bidirectional
            ? [...spread.map((t) => shifted(t, aside)), ...spread.map((t) => shifted(t, clear + 6))]
            : [
                ...[...spread, 0.22, 0.78].map((t) => shifted(t, 0)),
                ...[aside, clear].flatMap((by) => spread.flatMap((t) => [shifted(t, by * first), shifted(t, -by * first)])),
            ];
        return { key, from, to, transitions, lines, size, d: shape.d, start: shape.start, end: shape.end, spots, self: false, order: bidirectional ? 1 : 2 };
    });

    // Labels go down one by one, each avoiding the states (with room for arrowheads) and those before it:
    // loops first (they have one spot), then arcs, then straight lines, bigger labels before smaller
    const obstacles = [...Object.values(rects).map((rect) => grow(rect, 7)), ...(start ? [grow({ x: start.dot.x, y: start.dot.y, w: 0, h: 0 }, 8)] : [])];
    const placed = new Map();
    [...shapes].sort((a, b) => a.order - b.order || b.size.w * b.size.h - a.size.w * a.size.h).forEach((shape) => {
        const centre = placeLabel(shape.spots, shape.size, obstacles);
        obstacles.push(grow(boxAt(centre, shape.size), 2));
        placed.set(shape.key, centre);
    });
    const edges = shapes.map(({ spots: _spots, order: _order, size, ...shape }) => ({ ...shape, label: { ...placed.get(shape.key), ...size } }));
    return { edges, start };
};

const extents = (rects, shapes) => {
    const boxes = [
        ...Object.values(rects),
        ...shapes.edges.map((edge) => ({ x: edge.label.x - edge.label.w / 2, y: edge.label.y - edge.label.h / 2, w: edge.label.w, h: edge.label.h })),
        ...shapes.edges.filter((edge) => edge.self).flatMap((edge) => [edge.start, edge.end].map((point) => ({ x: point.x - 2, y: point.y - 2, w: 4, h: 4 }))),
        ...(shapes.start ? [{ x: shapes.start.dot.x - 8, y: shapes.start.dot.y - 8, w: 16, h: 16 }] : []),
    ];
    const x = Math.min(...boxes.map((box) => box.x));
    const y = Math.min(...boxes.map((box) => box.y));
    return { x, y, w: Math.max(...boxes.map((box) => box.x + box.w)) - x, h: Math.max(...boxes.map((box) => box.y + box.h)) - y };
};

export const statesLayout = (model) => {
    const raw = Object.fromEntries(model.states.map((state) => [state.id, stateRect(state)]));
    const bounds = extents(raw, geometry(model, raw));
    // Loops reach a fixed distance out, so they need a little room beyond the label boxes
    const dx = MARGIN + 10 - bounds.x;
    const dy = MARGIN + 10 - bounds.y;
    const rects = Object.fromEntries(Object.entries(raw).map(([id, rect]) => [id, { ...rect, x: rect.x + dx, y: rect.y + dy }]));
    const shapes = geometry(model, rects);
    return { width: bounds.w + (MARGIN + 10) * 2, height: bounds.h + (MARGIN + 10) * 2, rects, ...shapes, lineHeight: LINE_H };
};

export const statesSummary = (model) => {
    const label = Object.fromEntries(model.states.map((state) => [state.id, state.label]));
    const moves = model.transitions.map((transition) => `${label[transition.from]} to ${label[transition.to]} on ${transitionText(transition)}`);
    const finals = model.final.map((id) => label[id]);
    return `State machine with ${model.states.length} states: ${model.states.map((state) => state.label).join(', ')}. Starts in ${label[model.initial]}${finals.length ? `; final: ${finals.join(', ')}` : ''}. Transitions: ${moves.join('; ')}.`;
};

export const checkStates = schema((props) => {
    const states = checkEntries(props.states, 'states');
    states.forEach((state, index) => checkAt(state.at, `states[${index}] (${quote(state.id)})`));
    const ids = states.map((state) => state.id);
    const known = (id, where) => need(ids.includes(id), `${where} names ${quote(id)}, which isn't a state (states: ${listOf(ids)})`);
    const placed = states.map((state) => ({ id: state.id, rect: stateRect({ col: state.at[0], row: state.at[1] }) }));
    placed.forEach((a, i) => placed.slice(i + 1).forEach((b) => need(!overlaps(a.rect, b.rect), `states ${quote(a.id)} and ${quote(b.id)} overlap: give them different \`at\` cells`)));

    need(props.initial !== undefined, 'needs `initial`: the id of the state it starts in');
    known(props.initial, '`initial`');
    asList(props.final).forEach((id) => known(id, '`final`'));

    need(Array.isArray(props.transitions) && props.transitions.length > 0, 'needs `transitions`: a list of [from, to, event] or [from, to, event, guard]');
    const seen = new Map();
    props.transitions.forEach((entry, index) => {
        const where = `transitions[${index}]`;
        need(Array.isArray(entry) && entry.length >= 3 && entry.length <= 4, `${where} must be [from, to, event] or [from, to, event, guard]`);
        const [from, to, event, guard] = entry;
        known(from, where);
        known(to, where);
        need(isText(event), `${where} (${quote(`${from}->${to}`)}) needs an event name third`);
        need(guard === undefined || guard === null || isText(guard), `${where}: the guard (fourth) must be text`);
        const key = `${from}|${String(event).trim()}|${guard ?? ''}`;
        need(!seen.has(key), `${where} and transitions[${seen.get(key)}] both leave ${quote(from)} on ${quote(event)}${guard ? ` [${guard}]` : ''}; give one a different event or guard`);
        seen.set(key, index);
    });

    need(optionalText(props.intro), '`intro` must be text');
    if (props.events === undefined) return;
    need(Array.isArray(props.events), '`events` must be a list of event names, like [start, pause, resume]');
    props.events.forEach((entry, index) => {
        const where = `events[${index}]`;
        if (isObject(entry)) {
            need(isText(entry.event), `${where} needs \`event\`: the event's name`);
            need(entry.guard === undefined || isText(entry.guard), `${where}: \`guard\` must be text`);
            need(entry.say === undefined || isText(entry.say), `${where}: \`say\` must be text`);
            checkLine(entry.line, where);
        } else {
            need(isText(entry), `${where} must be an event name (or { event, guard?, say? })`);
        }
    });
    const { problem } = walkEvents(statesModel(props));
    if (problem) fail(problem);
});
