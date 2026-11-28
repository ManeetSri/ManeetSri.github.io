// ```visual flow: components on a grid joined by edges, with optional boundary groups, horizontal layers
// and steps that reveal parts, highlight them and send a message along an edge. Pure: the model, the
// layout, the frames and the schema; views/FlowView.jsx draws it.
import { segmentBetweenRects, textWidth } from '../svg.js';
import { TONE_NAMES } from '../tones.js';
import { asList, buildFrames, edgeKey, splitEdgeKey } from './frames.js';
import { checkAt, checkEntries, checkLine, fail, isNumber, isObject, isText, listOf, need, optionalText, overlaps, quote, schema } from './check.js';

export const FLOW_KINDS = ['client', 'view', 'service', 'store', 'db', 'cache', 'queue', 'cdn', 'external', 'actor'];
export const EDGE_STYLES = ['sync', 'async', 'data'];

// Grid geometry: a node fills most of its cell, leaving room between cells for edges and their labels
export const CELL_W = 140;
export const CELL_H = 84;
export const BOX_W = 112;
export const BOX_H = 50;
const MARGIN = 12;
const GUTTER = 24;
const LAYER_PAD = 12;
const GROUP_PAD = { side: 10, top: 21, bottom: 13 };
const PAIR_OFFSET = 7;

// An edge is [from, to, label?, { style }?] (the options can come third), or { from, to, label, style }
export const normaliseEdge = (entry) => {
    if (isObject(entry)) {
        return { from: String(entry.from), to: String(entry.to), label: entry.label ?? '', style: entry.style ?? 'sync' };
    }
    const [from, to, third, fourth] = entry;
    const options = isObject(third) ? third : isObject(fourth) ? fourth : {};
    const label = isObject(third) ? '' : third ?? '';
    return { from: String(from), to: String(to), label: String(label), style: options.style ?? 'sync' };
};

const layerRows = (rows) => (Array.isArray(rows) ? [rows[0], rows[1] ?? rows[0]] : [rows, rows]);

export const flowModel = (props = {}) => {
    const nodes = (props.nodes ?? []).map((node) => ({
        id: node.id, label: String(node.label ?? node.id), kind: node.kind ?? 'service', col: node.at[0], row: node.at[1], w: node.w ?? 1,
    }));
    // Every text an edge's label shows at some step, so the layout leaves room for the widest
    const relabels = (props.steps ?? []).flatMap((step) => Object.entries(step?.label ?? {}));
    const edges = (props.edges ?? []).map(normaliseEdge).map((edge) => {
        const key = edgeKey(edge.from, edge.to);
        const texts = relabels.filter(([id]) => id === key || id === edgeKey(edge.to, edge.from)).map(([, text]) => text).filter((text) => text !== null && text !== undefined && text !== '');
        return { ...edge, key, texts: [...new Set([edge.label, ...texts.map(String)].filter(Boolean))] };
    });
    const groups = (props.groups ?? []).map((group) => ({ id: group.id, label: String(group.label ?? ''), nodes: asList(group.nodes) }));
    const layers = (props.layers ?? []).map((layer) => {
        const [from, to] = layerRows(layer.rows);
        return { label: String(layer.label ?? ''), from, to };
    });
    return { nodes, edges, groups, layers };
};

// The rectangle a node fills before the layout shifts everything into the margins
const nodeRect = (node) => ({ x: node.col * CELL_W, y: node.row * CELL_H, w: BOX_W + (node.w - 1) * CELL_W, h: BOX_H });

const union = (rects) => {
    const x = Math.min(...rects.map((rect) => rect.x));
    const y = Math.min(...rects.map((rect) => rect.y));
    return { x, y, w: Math.max(...rects.map((rect) => rect.x + rect.w)) - x, h: Math.max(...rects.map((rect) => rect.y + rect.h)) - y };
};

export const flowLayout = (model) => {
    const raw = Object.fromEntries(model.nodes.map((node) => [node.id, nodeRect(node)]));
    // Groups wrap their nodes, and any smaller group made only of their nodes, so nested boxes don't touch
    const boxes = new Map();
    [...model.groups].sort((a, b) => a.nodes.length - b.nodes.length).forEach((group) => {
        const inner = [...boxes.entries()]
            .filter(([id]) => {
                const other = model.groups.find((candidate) => candidate.id === id);
                return other.nodes.length < group.nodes.length && other.nodes.every((member) => group.nodes.includes(member));
            })
            .map(([, rect]) => rect);
        const members = union([...group.nodes.map((id) => raw[id]), ...inner]);
        boxes.set(group.id, { x: members.x - GROUP_PAD.side, y: members.y - GROUP_PAD.top, w: members.w + GROUP_PAD.side * 2, h: members.h + GROUP_PAD.top + GROUP_PAD.bottom });
    });
    const bands = model.layers.map((layer) => ({ ...layer, y: layer.from * CELL_H - LAYER_PAD, h: (layer.to - layer.from) * CELL_H + BOX_H + LAYER_PAD * 2 }));
    const declared = new Set(model.edges.map((edge) => edge.key));
    const edgesBetween = (rects) => model.edges.map((edge) => {
        const paired = declared.has(edgeKey(edge.to, edge.from));
        const segment = segmentBetweenRects(rects[edge.from], rects[edge.to], { offset: paired ? PAIR_OFFSET : 0, gapStart: 2, gapEnd: 3 });
        return { ...edge, ...segment, paired };
    });
    // Labels can sit beside short edges, so their plates count toward the picture's size too
    const plates = edgesBetween(raw).flatMap((edge) => edge.texts.map((text) => {
        const at = edgeLabelAt(edge, text);
        const w = labelWidth(text);
        return { x: at.x - w / 2, y: at.y - 9, w, h: 18 };
    }));
    // Layers stretch across whatever width the nodes and groups need, so only their rows count here
    const solid = [...Object.values(raw), ...boxes.values(), ...plates];
    const across = union(solid.length ? solid : [{ x: 0, y: 0, w: 0, h: 0 }]);
    const bounds = union([across, ...bands.map((band) => ({ x: across.x, y: band.y, w: 0, h: band.h }))]);
    const gutter = model.layers.length ? GUTTER : 0;
    const dx = MARGIN + gutter - bounds.x;
    const dy = MARGIN - bounds.y;
    const shift = (rect) => ({ x: rect.x + dx, y: rect.y + dy, w: rect.w, h: rect.h });
    const width = bounds.w + MARGIN * 2 + gutter;
    const height = bounds.h + MARGIN * 2;

    const rects = Object.fromEntries(Object.entries(raw).map(([id, rect]) => [id, shift(rect)]));
    const edges = edgesBetween(rects);
    return {
        width,
        height,
        rects,
        edges,
        groups: model.groups.map((group) => ({ ...group, rect: shift(boxes.get(group.id)) })),
        layers: bands.map((band) => ({ label: band.label, x: MARGIN / 2, y: band.y + dy, w: width - MARGIN, h: band.h })),
        gutter,
    };
};

// Edge labels sit on the line over a backing plate this wide
export const labelWidth = (text, fontSize = 10) => textWidth(text, fontSize) + 10;

// Where an edge's label goes: on the line, or beside it for one of a pair, so the two don't collide.
// When the line is too short for the label (nodes in neighbouring cells), the label moves off the line
// into the gap beside it, so it covers neither the arrowhead nor the nodes.
export const edgeLabelAt = (edge, text) => {
    const plate = labelWidth(text);
    const length = Math.hypot(edge.end.x - edge.start.x, edge.end.y - edge.start.y);
    const n = edge.normal;
    const aside = length >= plate + 12 ? 0 : Math.abs(n.y) * (BOX_H / 2 + 12) + Math.abs(n.x) * (plate / 2 + 6);
    const push = (edge.paired ? 11 : 0) + aside;
    return { x: edge.mid.x + n.x * push, y: edge.mid.y + n.y * push };
};

export const flowFrames = (props = {}) => {
    const model = flowModel(props);
    return buildFrames(props.steps, {
        items: model.nodes.map((node) => node.id),
        edges: model.edges.map((edge) => [edge.from, edge.to]),
        groups: model.groups,
        fallback: props.caption === undefined ? '' : String(props.caption),
    });
};

// What a screen reader hears for the whole diagram
export const flowSummary = (model) => {
    const name = Object.fromEntries(model.nodes.map((node) => [node.id, node.label]));
    const parts = model.nodes.map((node) => `${node.label} (${node.kind})`).join(', ');
    const links = model.edges.map((edge) => `${name[edge.from]} to ${name[edge.to]}${edge.label ? `: ${edge.label}` : ''}${edge.style === 'sync' ? '' : ` (${edge.style})`}`);
    const grouped = model.groups.map((group) => `${group.label || group.id} contains ${group.nodes.map((id) => name[id]).join(', ')}`);
    return [`Flow diagram of ${model.nodes.length} parts: ${parts}.`, links.length ? `Connections: ${links.join('; ')}.` : '', grouped.length ? `${grouped.join('. ')}.` : '']
        .filter(Boolean).join(' ');
};

export const checkFlow = schema((props) => {
    const taken = new Set();
    const nodes = checkEntries(props.nodes, 'nodes', { taken });
    nodes.forEach((node, index) => {
        const where = `nodes[${index}] (${quote(node.id)})`;
        need(node.kind === undefined || FLOW_KINDS.includes(node.kind), `${where}: kind ${quote(node.kind)} isn't one of ${FLOW_KINDS.join(', ')}`);
        checkAt(node.at, where);
        need(node.w === undefined || (isNumber(node.w) && node.w >= 1 && node.w <= 8), `${where}: \`w\` is its width in grid columns, a number from 1 to 8`);
    });
    const nodeIds = nodes.map((node) => node.id);

    const groups = checkEntries(props.groups, 'groups', { taken, required: false });
    groups.forEach((group, index) => {
        const where = `groups[${index}] (${quote(group.id)})`;
        const members = asList(group.nodes);
        need(members.length > 0, `${where} needs \`nodes\`: the ids of the nodes it surrounds`);
        members.forEach((id) => need(nodeIds.includes(id), `${where} lists ${quote(id)}, which isn't a node (nodes: ${listOf(nodeIds)})`));
    });
    const groupIds = groups.map((group) => group.id);

    if (props.layers !== undefined) {
        need(Array.isArray(props.layers), '`layers` must be a list of { label, rows: [from, to] }');
        props.layers.forEach((layer, index) => {
            need(isObject(layer), `layers[${index}] must be a mapping like { label: Backend, rows: [1, 2] }`);
            need(optionalText(layer.label), `layers[${index}]: \`label\` must be text`);
            const rows = layer.rows;
            const [from, to] = layerRows(rows);
            need(rows !== undefined && isNumber(from) && isNumber(to) && from >= 0 && (!Array.isArray(rows) || rows.length <= 2), `layers[${index}] needs \`rows: [from, to]\` (or one row number)`);
            need(from <= to, `layers[${index}]: \`rows\` runs from ${from} to ${to}; put the smaller row first`);
        });
    }

    need(props.edges === undefined || Array.isArray(props.edges), '`edges` must be a list of [from, to, label?, { style }?]');
    const declared = new Map();
    (props.edges ?? []).forEach((entry, index) => {
        const where = `edges[${index}]`;
        need(Array.isArray(entry) ? entry.length >= 2 && entry.length <= 4 : isObject(entry), `${where} must be [from, to], [from, to, label] or [from, to, label, { style: async }]`);
        const edge = normaliseEdge(entry);
        const raw = Array.isArray(entry) ? entry : [entry.from, entry.to];
        [raw[0], raw[1]].forEach((id) => need(nodeIds.includes(id), `${where} (${quote(`${raw[0]}->${raw[1]}`)}) names ${quote(id)}, which isn't a node (nodes: ${listOf(nodeIds)})`));
        need(edge.from !== edge.to, `${where} goes from ${quote(edge.from)} to itself; flow edges join two different nodes`);
        const rawLabel = Array.isArray(entry) ? (isObject(entry[2]) ? undefined : entry[2]) : entry.label;
        need(optionalText(rawLabel), `${where}: the label must be text`);
        need(EDGE_STYLES.includes(edge.style), `${where}: style ${quote(edge.style)} isn't one of ${EDGE_STYLES.join(', ')}`);
        const key = edgeKey(edge.from, edge.to);
        need(!declared.has(key), `${where} repeats the edge ${quote(key)}; join two nodes once in each direction`);
        declared.set(key, edge);
    });
    const edgeKeys = [...declared.keys()];

    // Nodes that would draw on top of each other
    const placed = nodes.map((node) => ({ id: node.id, rect: nodeRect({ col: node.at[0], row: node.at[1], w: node.w ?? 1 }) }));
    placed.forEach((a, i) => placed.slice(i + 1).forEach((b) => {
        need(!overlaps(a.rect, b.rect), `nodes ${quote(a.id)} and ${quote(b.id)} overlap: move one (\`at\`) or narrow it (\`w\`)`);
    }));

    const edgeFor = (key) => {
        const ends = splitEdgeKey(String(key).replace(/\s+/g, ''));
        if (!ends) return null;
        if (declared.has(edgeKey(ends[0], ends[1]))) return edgeKey(ends[0], ends[1]);
        if (declared.has(edgeKey(ends[1], ends[0]))) return edgeKey(ends[1], ends[0]);
        return undefined;
    };
    const knownRef = (id, { groupsAllowed = true, edgesAllowed = true } = {}, where) => {
        const text = String(id);
        const edge = edgeFor(text);
        if (edge === undefined) fail(`${where} names ${quote(text)}, but there's no edge between those nodes (edges: ${listOf(edgeKeys)})`);
        if (edge !== null) {
            need(edgesAllowed, `${where} names the edge ${quote(text)}; only node ids go here`);
            return;
        }
        if (nodeIds.includes(text)) return;
        if (groupIds.includes(text)) {
            need(groupsAllowed, `${where} names the group ${quote(text)}; only nodes and edges go here`);
            return;
        }
        fail(`${where} names ${quote(text)}, which isn't a node${groupsAllowed ? ', group' : ''} or edge (nodes: ${listOf(nodeIds)}${groupIds.length ? `; groups: ${listOf(groupIds)}` : ''})`);
    };

    if (props.steps === undefined) return;
    need(Array.isArray(props.steps), '`steps` must be a list of { say, show?, hide?, active?, state?, send?, label?, reset? }');
    props.steps.forEach((step, index) => {
        const where = `steps[${index}]`;
        need(isObject(step), `${where} must be a mapping with at least \`say\``);
        need(isText(step.say), `${where} needs \`say\`: the sentence shown for this step`);
        ['show', 'hide', 'active'].forEach((field) => asList(step[field]).forEach((id) => knownRef(id, {}, `${where}.${field}`)));
        asList(step.send).forEach((key) => {
            const edge = edgeFor(key);
            need(edge !== null, `${where}.send is ${quote(key)}: write an edge as from->to, like ${quote(edgeKeys[0] ?? 'app->api')}`);
            need(edge !== undefined, `${where}.send names ${quote(key)}, but there's no edge between those nodes (edges: ${listOf(edgeKeys)})`);
        });
        if (step.state !== undefined) {
            need(isObject(step.state), `${where}.state must be a mapping of id: tone, like { api: error }`);
            Object.entries(step.state).forEach(([id, tone]) => {
                knownRef(id, {}, `${where}.state`);
                need(tone === null || TONE_NAMES.includes(tone), `${where}.state gives ${quote(id)} the tone ${quote(tone)}; use one of ${TONE_NAMES.join(', ')}`);
            });
        }
        if (step.label !== undefined) {
            need(isObject(step.label), `${where}.label must be a mapping of id: text, like { api: "v2" }`);
            Object.entries(step.label).forEach(([id, text]) => {
                knownRef(id, { groupsAllowed: false }, `${where}.label`);
                need(optionalText(text), `${where}.label for ${quote(id)} must be text (or null to clear it)`);
            });
        }
        need(step.reset === undefined || typeof step.reset === 'boolean', `${where}.reset must be true or false`);
        checkLine(step.line, where);
    });
});
