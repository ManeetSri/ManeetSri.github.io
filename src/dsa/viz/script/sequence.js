// ```visual sequence: participants with lifelines, messages between them (calls, async sends, replies,
// self-calls and notes) and loop/alt/opt/par fragments around runs of messages. One frame per message, or
// author-written steps that each reveal messages up to an index. Pure; views/SequenceView.jsx draws it.
import { textWidth, wrapText } from '../svg.js';
import { asList } from './frames.js';
import { checkEntries, checkLine, fail, isNumber, isObject, isText, listOf, need, optionalText, quote, schema } from './check.js';

export const FRAGMENT_KINDS = ['loop', 'alt', 'opt', 'par'];

const TOP = 10;
const HEAD_H = 28;
const MIN_GAP = 120;
const ROW = 34;
const SELF_ROW = 48;
const LOOP_W = 30;
const FRAGMENT_HEAD = 24;
const FRAGMENT_END = 10;
const ELSE_GAP = 20;
const NOTE_LINE = 14;
const NOTE_SINGLE_W = 156;
const NOTE_SPAN_PAD = 44;
const MARGIN = 12;
export const LABEL_FONT = 10.5;
export const NOTE_FONT = 11;
const HEAD_FONT = 11.5;

const isNote = (entry) => isObject(entry) && entry.note !== undefined;

export const sequenceModel = (props = {}) => {
    const participants = (props.participants ?? []).map((participant) => ({ id: participant.id, label: String(participant.label ?? participant.id) }));
    const entries = (props.messages ?? []).map((entry, index) => {
        if (isNote(entry)) {
            return { index, type: 'note', text: String(entry.note), over: asList(entry.over).map(String), say: entry.say, line: entry.line };
        }
        const [from, to, text, options = {}] = entry;
        return {
            index, type: 'message', from: String(from), to: String(to), text: String(text ?? ''), self: from === to,
            reply: Boolean(options.reply), async: Boolean(options.async), say: options.say, line: options.line,
        };
    });
    const fragments = (props.fragments ?? []).map((fragment) => ({
        kind: fragment.kind, label: String(fragment.label ?? ''), from: fragment.from, to: fragment.to,
        else: fragment.else, elseLabel: String(fragment.elseLabel ?? ''),
    }));
    return { participants, entries, fragments };
};

const headWidth = (participant) => Math.max(84, textWidth(participant.label, HEAD_FONT, false) + 24);
const labelWidth = (text) => textWidth(text, LABEL_FONT);

// How many fragments sit strictly inside each one, so outer boxes get wider margins than inner ones
const innerDepth = (fragments) => {
    const inside = (outer, inner) => outer !== inner && outer.from <= inner.from && inner.to <= outer.to && (outer.from !== inner.from || outer.to !== inner.to || fragments.indexOf(outer) < fragments.indexOf(inner));
    const depth = (fragment) => Math.max(0, ...fragments.filter((other) => inside(fragment, other)).map((other) => depth(other) + 1));
    return fragments.map(depth);
};

export const sequenceLayout = (model) => {
    const { participants, entries, fragments } = model;
    const column = Object.fromEntries(participants.map((participant, index) => [participant.id, index]));
    const heads = participants.map(headWidth);

    // Gaps between neighbouring lifelines grow to fit the messages that cross them
    const gaps = participants.slice(1).map((_, index) => Math.max(MIN_GAP, heads[index] / 2 + heads[index + 1] / 2 + 16));
    entries.filter((entry) => entry.type === 'message').forEach((entry) => {
        const a = column[entry.from];
        const b = column[entry.to];
        if (entry.self) {
            if (a < gaps.length) gaps[a] = Math.max(gaps[a], LOOP_W + 14 + labelWidth(entry.text) + 16);
            return;
        }
        const [lo, hi] = [Math.min(a, b), Math.max(a, b)];
        const each = (labelWidth(entry.text) + 24) / (hi - lo);
        for (let gap = lo; gap < hi; gap += 1) gaps[gap] = Math.max(gaps[gap], each);
    });
    const xs = participants.map((_, index) => gaps.slice(0, index).reduce((sum, gap) => sum + gap, 0));
    const x = (id) => xs[column[id]];

    // Rows, top to bottom; fragments open and close around their messages
    let y = TOP + HEAD_H + 12;
    const rows = [];
    const boxes = fragments.map(() => ({}));
    // Outer fragments open first and close last; of two with the same messages, the first listed is outer
    const size = (fragment) => fragment.to - fragment.from;
    const order = (list, opening) => list.sort((a, b) => (opening ? size(b) - size(a) || a.at - b.at : size(a) - size(b) || b.at - a.at));
    entries.forEach((entry, index) => {
        order(fragments.map((fragment, at) => ({ ...fragment, at })).filter((fragment) => fragment.from === index), true).forEach((fragment) => {
            boxes[fragment.at].top = y;
            y += FRAGMENT_HEAD;
        });
        fragments.forEach((fragment, at) => {
            if (fragment.else === index) {
                boxes[at].elseY = y;
                y += ELSE_GAP;
            }
        });
        if (entry.type === 'note') {
            const cols = entry.over.map((id) => xs[column[id]]);
            const [left, right] = [Math.min(...cols), Math.max(...cols)];
            const width = cols.length > 1 || left !== right ? right - left + NOTE_SPAN_PAD * 2 : NOTE_SINGLE_W;
            const boxX = cols.length > 1 || left !== right ? left - NOTE_SPAN_PAD : left - NOTE_SINGLE_W / 2;
            const lines = wrapText(entry.text, Math.max(8, Math.floor((width - 16) / (NOTE_FONT * 0.56))));
            const height = lines.length * NOTE_LINE + 10;
            rows.push({ ...entry, box: { x: boxX, y: y + 4, w: width, h: height }, lines, left: boxX, right: boxX + width });
            y += height + 14;
        } else if (entry.self) {
            const at = x(entry.from);
            rows.push({ ...entry, x1: at, x2: at, y: y + 18, loopBottom: y + 36, labelX: at + LOOP_W + 8, labelY: y + 31, left: at, right: at + LOOP_W + 8 + labelWidth(entry.text) });
            y += SELF_ROW;
        } else {
            const [x1, x2] = [x(entry.from), x(entry.to)];
            rows.push({ ...entry, x1, x2, y: y + 22, labelX: (x1 + x2) / 2, labelY: y + 14, left: Math.min(x1, x2), right: Math.max(x1, x2) });
            y += ROW;
        }
        order(fragments.map((fragment, at) => ({ ...fragment, at })).filter((fragment) => fragment.to === index), false).forEach((fragment) => {
            y += FRAGMENT_END;
            boxes[fragment.at].bottom = y;
        });
    });
    const height = y + 14;

    const depths = innerDepth(fragments);
    const frames = fragments.map((fragment, at) => {
        const inside = rows.slice(fragment.from, fragment.to + 1);
        const cols = inside.flatMap((row) => (row.type === 'note' ? row.over : [row.from, row.to])).map((id) => xs[column[id]]);
        const pad = 16 + depths[at] * 9;
        const left = Math.min(...cols, ...inside.map((row) => row.left)) - pad;
        const tab = textWidth(fragment.kind, 9.5) + 14;
        const right = Math.max(...cols, ...inside.map((row) => row.right), left + tab + textWidth(fragment.label, 10, false) + 30) + pad;
        return { ...fragment, ...boxes[at], x: left, w: right - left, tab };
    });

    // Shift everything right so the leftmost box clears the margin
    const lefts = [...xs.map((value, index) => value - heads[index] / 2), ...rows.map((row) => row.left), ...frames.map((frame) => frame.x)];
    const rights = [...xs.map((value, index) => value + heads[index] / 2), ...rows.map((row) => row.right), ...frames.map((frame) => frame.x + frame.w)];
    const shift = MARGIN - Math.min(...lefts);
    const width = Math.max(...rights) - Math.min(...lefts) + MARGIN * 2;
    const moved = (value) => value + shift;

    return {
        width,
        height,
        headTop: TOP,
        headHeight: HEAD_H,
        lifelineTop: TOP + HEAD_H,
        lifelineBottom: height - 6,
        participants: participants.map((participant, index) => ({ ...participant, x: moved(xs[index]), headW: heads[index] })),
        rows: rows.map((row) => (row.type === 'note'
            ? { ...row, box: { ...row.box, x: moved(row.box.x) } }
            : { ...row, x1: moved(row.x1), x2: moved(row.x2), labelX: moved(row.labelX) })),
        fragments: frames.map((frame) => ({ ...frame, x: moved(frame.x) })),
    };
};

const nameOf = (model) => Object.fromEntries(model.participants.map((participant) => [participant.id, participant.label]));

export const defaultMessage = (entry, names) => (entry.type === 'note' ? entry.text : `${names[entry.from]} → ${names[entry.to]}: ${entry.text}`);

// One frame per entry, or one per step. A frame shows entries 0…upTo and highlights the new ones.
export const sequenceFrames = (props = {}) => {
    const model = sequenceModel(props);
    const names = nameOf(model);
    const ids = model.entries.map((entry) => `m${entry.index}`);
    const frame = (upTo, current, message, line) => ({
        message,
        visible: ids.slice(0, upTo + 1),
        active: current.map((index) => ids[index]),
        states: {},
        labels: {},
        send: current.filter((index) => model.entries[index].type === 'message').map((index) => `${model.entries[index].from}->${model.entries[index].to}`),
        upTo,
        ...(line === undefined ? {} : { line }),
    });
    if (Array.isArray(props.steps) && props.steps.length) {
        let previous = -1;
        return props.steps.map((step) => {
            const upTo = step.upTo;
            const fresh = [];
            for (let index = previous + 1; index <= upTo; index += 1) fresh.push(index);
            const current = fresh.length || upTo < 0 ? fresh : [upTo];
            previous = Math.max(previous, upTo);
            return frame(upTo, current, String(step.say ?? ''), step.line);
        });
    }
    return model.entries.map((entry) => frame(entry.index, [entry.index], entry.say === undefined ? defaultMessage(entry, names) : String(entry.say), entry.line));
};

export const sequenceSummary = (model) => {
    const names = nameOf(model);
    const people = model.participants.map((participant) => participant.label);
    const list = people.length > 1 ? `${people.slice(0, -1).join(', ')} and ${people.at(-1)}` : people[0];
    const messages = model.entries.filter((entry) => entry.type === 'message');
    const steps = model.entries.slice(0, 14).map((entry, index) => `${index + 1}. ${entry.type === 'note' ? `note: ${entry.text}` : `${names[entry.from]} to ${names[entry.to]}${entry.reply ? ' (reply)' : ''}: ${entry.text}`}`);
    return `Sequence diagram between ${list}, with ${messages.length} message${messages.length === 1 ? '' : 's'}. ${steps.join('; ')}${model.entries.length > 14 ? '; and more' : ''}.`;
};

export const checkSequence = schema((props) => {
    const participants = checkEntries(props.participants, 'participants');
    const ids = participants.map((participant) => participant.id);
    const known = (id, where) => need(ids.includes(id), `${where} names ${quote(id)}, which isn't a participant (participants: ${listOf(ids)})`);

    need(Array.isArray(props.messages) && props.messages.length > 0, 'needs `messages`: a list of [from, to, text] (or { note, over })');
    const count = props.messages.length;
    props.messages.forEach((entry, index) => {
        const where = `messages[${index}]`;
        if (isNote(entry)) {
            need(isText(entry.note), `${where}: \`note\` must be text`);
            const over = asList(entry.over);
            need(over.length > 0, `${where} needs \`over\`: the participant (or list of participants) the note sits over`);
            over.forEach((id) => known(id, `${where}.over`));
            need(entry.say === undefined || isText(entry.say), `${where}: \`say\` must be text`);
            checkLine(entry.line, where);
            return;
        }
        need(Array.isArray(entry) && entry.length >= 3 && entry.length <= 4, `${where} must be [from, to, text], [from, to, text, { reply: true }] or { note, over }`);
        const [from, to, text, options] = entry;
        known(from, where);
        known(to, where);
        need(isText(text) || isNumber(text), `${where} (${quote(`${from}->${to}`)}) needs the message text third`);
        if (options === undefined) return;
        need(isObject(options), `${where}: the fourth item must be options like { reply: true }, { async: true } or { say: … }`);
        ['reply', 'async'].forEach((flag) => need(options[flag] === undefined || typeof options[flag] === 'boolean', `${where}: \`${flag}\` must be true or false`));
        need(options.say === undefined || isText(options.say), `${where}: \`say\` must be text`);
        checkLine(options.line, where);
    });

    const index = (value, where, field) => need(Number.isInteger(value) && value >= 0 && value < count, `${where}.${field} must be a message index from 0 to ${count - 1} (got ${JSON.stringify(value)})`);
    need(props.fragments === undefined || Array.isArray(props.fragments), '`fragments` must be a list of { kind, label, from, to }');
    const fragments = props.fragments ?? [];
    fragments.forEach((fragment, at) => {
        const where = `fragments[${at}]`;
        need(isObject(fragment), `${where} must be a mapping like { kind: loop, label: "every 30 s", from: 2, to: 4 }`);
        need(FRAGMENT_KINDS.includes(fragment.kind), `${where}: kind ${quote(fragment.kind)} isn't one of ${FRAGMENT_KINDS.join(', ')}`);
        need(optionalText(fragment.label) && optionalText(fragment.elseLabel), `${where}: \`label\` and \`elseLabel\` must be text`);
        index(fragment.from, where, 'from');
        index(fragment.to, where, 'to');
        need(fragment.from <= fragment.to, `${where} runs from message ${fragment.from} to ${fragment.to}; \`from\` comes first`);
        if (fragment.else !== undefined) {
            need(Number.isInteger(fragment.else) && fragment.else > fragment.from && fragment.else <= fragment.to, `${where}.else must be the index of a message after \`from\` and up to \`to\` (${fragment.from + 1}–${fragment.to}), where the second branch starts`);
        }
    });
    fragments.forEach((a, i) => fragments.slice(i + 1).forEach((b, offset) => {
        const crosses = (p, q) => p.from < q.from && q.from <= p.to && p.to < q.to;
        if (crosses(a, b) || crosses(b, a)) fail(`fragments[${i}] (${a.from}–${a.to}) and fragments[${i + 1 + offset}] (${b.from}–${b.to}) cross: one must sit inside the other or after it`);
    }));

    if (props.steps === undefined) return;
    need(Array.isArray(props.steps) && props.steps.length > 0, '`steps` must be a list of { say, upTo }');
    let previous = -1;
    props.steps.forEach((step, at) => {
        const where = `steps[${at}]`;
        need(isObject(step), `${where} must be a mapping like { say: …, upTo: 2 }`);
        need(isText(step.say), `${where} needs \`say\`: the sentence shown for this step`);
        need(Number.isInteger(step.upTo) && step.upTo >= -1 && step.upTo < count, `${where}.upTo must be a message index from 0 to ${count - 1} (or -1 for before the first)`);
        need(step.upTo >= previous, `${where}.upTo is ${step.upTo}, before the previous step's ${previous}; steps only move forward`);
        previous = step.upTo;
        checkLine(step.line, where);
    });
});
