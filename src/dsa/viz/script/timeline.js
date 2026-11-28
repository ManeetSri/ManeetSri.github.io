// ```visual timeline: lanes (devices, actors, services) with labelled spans of time, instant markers,
// and steps that move a time cursor forward. A span or marker appears once the cursor reaches its start.
// Pure; views/TimelineView.jsx draws it.
import { textWidth, truncate } from '../svg.js';
import { TONE_NAMES } from '../tones.js';
import { checkEntries, checkLine, isNumber, isObject, isText, listOf, need, optionalText, quote, schema } from './check.js';

export const UNITS = ['ms', 's', 'min'];

const WIDTH = 640;
const LANE_H = 34;
const BAR_H = 20;
const MARKER_ROW = 15;
const RIGHT = 24;
export const SPAN_FONT = 10.5;
export const MARKER_FONT = 10;

export const timelineModel = (props = {}) => {
    const spans = (props.spans ?? []).map((span, index) => ({ index, lane: span.lane, from: span.from, to: span.to, label: String(span.label ?? ''), tone: span.tone ?? 'neutral' }));
    const markers = (props.markers ?? []).map((marker, index) => ({ index, at: marker.at, label: String(marker.label ?? '') }));
    const steps = (props.steps ?? []).map((step) => ({ at: step.at, say: String(step.say ?? ''), line: step.line }));
    const times = [...spans.flatMap((span) => [span.from, span.to]), ...markers.map((marker) => marker.at), ...steps.map((step) => step.at)].filter(isNumber);
    const lowest = times.length ? Math.min(...times) : 0;
    const start = isNumber(props.start) ? props.start : Math.min(0, lowest);
    let end = isNumber(props.end) ? props.end : Math.max(start, ...times);
    if (end <= start) end = start + 1;
    return {
        unit: props.unit ?? 'ms',
        lanes: (props.lanes ?? []).map((lane) => ({ id: lane.id, label: String(lane.label ?? lane.id) })),
        spans, markers, steps, start, end, caption: props.caption,
    };
};

export const formatTime = (value, unit) => `${Number(value.toFixed(3))} ${unit}`;

// Round tick spacing: 1, 2 or 5 times a power of ten, giving about six ticks
export const ticks = (start, end, target = 6) => {
    const raw = (end - start) / target;
    const power = 10 ** Math.floor(Math.log10(raw));
    const step = [1, 2, 5, 10].map((factor) => factor * power).find((candidate) => candidate >= raw) ?? power * 10;
    const values = [];
    for (let value = Math.ceil(start / step) * step; value <= end + step * 1e-9; value += step) values.push(Number(value.toFixed(9)));
    return values;
};

export const timelineFrames = (props = {}) => {
    const model = timelineModel(props);
    const spanIds = model.spans.map((span) => `s${span.index}`);
    const markerIds = model.markers.map((marker) => `m${marker.index}`);
    if (!model.steps.length) {
        return [{ message: model.caption === undefined ? '' : String(model.caption), at: null, visible: [...spanIds, ...markerIds], active: [], states: {}, labels: {}, send: [] }];
    }
    return model.steps.map((step) => {
        const frame = {
            message: step.say,
            at: step.at,
            visible: [...model.spans.filter((span) => span.from <= step.at).map((span) => `s${span.index}`), ...model.markers.filter((marker) => marker.at <= step.at).map((marker) => `m${marker.index}`)],
            active: model.spans.filter((span) => span.from <= step.at && step.at < span.to).map((span) => `s${span.index}`),
            states: {},
            labels: {},
            send: [],
        };
        if (step.line !== undefined) frame.line = step.line;
        return frame;
    });
};

export const timelineLayout = (model) => {
    const labelW = Math.min(132, Math.max(64, ...model.lanes.map((lane) => textWidth(lane.label, 11, false) + 18)));
    const plotX0 = labelW + 10;
    const plotX1 = WIDTH - RIGHT;
    const x = (time) => plotX0 + ((time - model.start) / (model.end - model.start)) * (plotX1 - plotX0);

    // Marker labels stack into rows so neighbours don't print over each other
    const rowEnds = [];
    const markers = [...model.markers].sort((a, b) => a.at - b.at).map((marker) => {
        const width = textWidth(marker.label, MARKER_FONT) + 8;
        const centre = x(marker.at);
        const left = Math.max(4, Math.min(centre - width / 2, WIDTH - 4 - width));
        let row = rowEnds.findIndex((end) => end <= left);
        if (row < 0) {
            row = rowEnds.length;
            rowEnds.push(0);
        }
        rowEnds[row] = left + width + 6;
        return { ...marker, x: centre, labelX: left + width / 2, row };
    });
    const top = 8 + Math.max(1, rowEnds.length) * MARKER_ROW + 4;
    const laneY = Object.fromEntries(model.lanes.map((lane, index) => [lane.id, top + index * LANE_H]));
    const lanesBottom = top + model.lanes.length * LANE_H;

    const spans = model.spans.map((span) => {
        const x0 = x(span.from);
        const x1 = Math.max(x(span.to), x0 + 3);
        const w = x1 - x0;
        const textW = textWidth(span.label, SPAN_FONT, false);
        // Room after the span, before the next span in its lane starts
        const nextStart = Math.min(plotX1 + RIGHT - 4, ...model.spans.filter((other) => other.lane === span.lane && other.from >= span.to && other !== span).map((other) => x(other.from)));
        let label;
        if (textW + 10 <= w) label = { text: span.label, x: x0 + w / 2, anchor: 'middle', inside: true };
        else if (textW + 8 <= nextStart - x1) label = { text: span.label, x: x1 + 5, anchor: 'start', inside: false };
        else label = { text: truncate(span.label, Math.floor((w - 8) / (SPAN_FONT * 0.56))), x: x0 + w / 2, anchor: 'middle', inside: true };
        return { ...span, x0, x1, y: laneY[span.lane] + (LANE_H - BAR_H) / 2, h: BAR_H, label };
    });

    return {
        width: WIDTH,
        height: lanesBottom + 46,
        labelW,
        plotX0,
        plotX1,
        top,
        laneHeight: LANE_H,
        lanes: model.lanes.map((lane) => ({ ...lane, y: laneY[lane.id] })),
        lanesBottom,
        axisY: lanesBottom + 6,
        spans,
        markers: markers.map((marker) => ({ ...marker, labelY: 8 + marker.row * MARKER_ROW + 9 })),
        ticks: ticks(model.start, model.end).map((value) => ({ value, x: x(value), text: formatTime(value, model.unit) })),
        x,
    };
};

export const timelineSummary = (model) => {
    const lane = Object.fromEntries(model.lanes.map((entry) => [entry.id, entry.label]));
    const spans = model.spans.slice(0, 16).map((span) => `${lane[span.lane]}: ${span.label || 'busy'} from ${formatTime(span.from, model.unit)} to ${formatTime(span.to, model.unit)}`);
    const markers = model.markers.map((marker) => `${marker.label} at ${formatTime(marker.at, model.unit)}`);
    return [`Timeline with lanes ${model.lanes.map((entry) => entry.label).join(', ')}.`, spans.length ? `${spans.join('; ')}${model.spans.length > 16 ? '; and more' : ''}.` : '', markers.length ? `Markers: ${markers.join('; ')}.` : '']
        .filter(Boolean).join(' ');
};

export const checkTimeline = schema((props) => {
    need(props.unit === undefined || UNITS.includes(props.unit), `unit ${quote(props.unit)} isn't one of ${UNITS.join(', ')}`);
    const lanes = checkEntries(props.lanes, 'lanes');
    const laneIds = lanes.map((lane) => lane.id);
    ['start', 'end'].forEach((field) => need(props[field] === undefined || isNumber(props[field]), `\`${field}\` must be a number`));
    need(props.start === undefined || props.end === undefined || props.start < props.end, '`start` must come before `end`');
    const inRange = (value, where) => {
        need(props.start === undefined || value >= props.start, `${where} is ${value}, before \`start\` (${props.start})`);
        need(props.end === undefined || value <= props.end, `${where} is ${value}, after \`end\` (${props.end})`);
    };

    need(props.spans === undefined || Array.isArray(props.spans), '`spans` must be a list of { lane, from, to, label }');
    need(props.markers === undefined || Array.isArray(props.markers), '`markers` must be a list of { at, label }');
    const spans = props.spans ?? [];
    const markers = props.markers ?? [];
    need(spans.length + markers.length > 0, 'needs `spans` (or `markers`): there is nothing to draw');
    spans.forEach((span, index) => {
        const where = `spans[${index}]`;
        need(isObject(span), `${where} must be a mapping like { lane: phone, from: 0, to: 120, label: Edit }`);
        need(laneIds.includes(span.lane), `${where} is in lane ${quote(span.lane)}, which isn't a lane (lanes: ${listOf(laneIds)})`);
        need(isNumber(span.from) && isNumber(span.to), `${where} needs numbers for \`from\` and \`to\``);
        need(span.to > span.from, `${where} runs from ${span.from} to ${span.to}; \`to\` must be later (use a marker for an instant)`);
        need(optionalText(span.label), `${where}: \`label\` must be text`);
        need(span.tone === undefined || TONE_NAMES.includes(span.tone), `${where}: tone ${quote(span.tone)} isn't one of ${TONE_NAMES.join(', ')}`);
        inRange(span.from, `${where}.from`);
        inRange(span.to, `${where}.to`);
    });
    spans.forEach((a, i) => spans.slice(i + 1).forEach((b, offset) => {
        need(a.lane !== b.lane || a.to <= b.from || b.to <= a.from, `spans[${i}] and spans[${i + 1 + offset}] overlap in lane ${quote(a.lane)}; put one in another lane or make them touch`);
    }));
    markers.forEach((marker, index) => {
        const where = `markers[${index}]`;
        need(isObject(marker), `${where} must be a mapping like { at: 300, label: sync }`);
        need(isNumber(marker.at), `${where} needs \`at\`: a time`);
        need(isText(marker.label), `${where} needs \`label\``);
        inRange(marker.at, `${where}.at`);
    });

    if (props.steps === undefined) return;
    need(Array.isArray(props.steps) && props.steps.length > 0, '`steps` must be a list of { at, say }');
    let previous = -Infinity;
    props.steps.forEach((step, index) => {
        const where = `steps[${index}]`;
        need(isObject(step), `${where} must be a mapping like { at: 120, say: … }`);
        need(isNumber(step.at), `${where} needs \`at\`: where the time cursor moves to`);
        need(isText(step.say), `${where} needs \`say\`: the sentence shown for this step`);
        need(step.at >= previous, `${where} is at ${step.at}, before the previous step (${previous}); the cursor only moves forward`);
        inRange(step.at, `${where}.at`);
        checkLine(step.line, where);
        previous = step.at;
    });
});
