// Turns a lesson's YAML steps into Player frames. A step lists only what changes; the frame it makes is
// the whole picture at that moment:
//   { message, visible, active, states, labels, send, line? }
// - `message` is the step's `say` (inline markdown).
// - `visible` lists every node and edge on show. `show` adds to it and `hide` takes away; `reset: true`
//   starts again from nothing (clearing states and labels too). A step that sends along an edge shows the
//   edge and both its ends. Scripts that never use show, hide or reset show everything throughout.
//   An edge appears once both ends are visible, unless a step names the edge in show or hide, in which
//   case it follows those steps. Hiding a node hides its edges.
// - `active` is what this step highlights (nodes, groups or edges); it doesn't carry over.
// - `states` ({ id: tone }) and `labels` ({ id: text }) carry over until changed; `neutral` or null
//   clears a state, and null or '' clears a label.
// - `send` lists the edges a message travels along in this step, in the direction written (`b->a` on an
//   edge declared a → b travels backwards along it).
// Edge keys are `from->to`.

export const edgeKey = (from, to) => `${from}->${to}`;

// ['a', 'b'] for 'a->b', or null when the text isn't an edge key
export const splitEdgeKey = (key) => {
    const text = String(key);
    const at = text.indexOf('->');
    if (at <= 0 || at + 2 >= text.length) return null;
    return [text.slice(0, at).trim(), text.slice(at + 2).trim()];
};

export const asList = (value) => (value === undefined || value === null ? [] : Array.isArray(value) ? value : [value]);

// `items` are node ids in drawing order, `edges` [from, to] pairs as declared, `groups` { id, nodes }.
// A group id in show or hide stands for all its nodes.
export const buildFrames = (steps, { items = [], edges = [], groups = [], fallback = '' } = {}) => {
    const declared = edges.map(([from, to]) => edgeKey(from, to));
    const declaredSet = new Set(declared);
    const members = new Map(groups.map((group) => [group.id, group.nodes ?? []]));
    const groupIds = groups.map((group) => group.id);
    // An edge named either way round means the declared edge
    const canonical = (id) => {
        const text = String(id).trim();
        const ends = splitEdgeKey(text);
        if (!ends) return text;
        const forward = edgeKey(ends[0], ends[1]);
        const backward = edgeKey(ends[1], ends[0]);
        return declaredSet.has(forward) || !declaredSet.has(backward) ? forward : backward;
    };
    const expand = (id) => (members.has(id) ? members.get(id) : [canonical(id)]);
    const everything = [...items, ...declared, ...groupIds];

    if (!steps?.length) {
        return [{ message: fallback, visible: everything, active: [], states: {}, labels: {}, send: [] }];
    }

    const scripted = steps.some((step) => step?.show !== undefined || step?.hide !== undefined || step?.reset);
    // Edges a step names in show or hide follow the script; the rest follow their ends
    const named = new Set(steps.flatMap((step) => [...asList(step?.show), ...asList(step?.hide)].map(canonical).filter((id) => declaredSet.has(id))));
    let shown = new Set(scripted ? [] : [...items, ...declared]);
    let states = {};
    let labels = {};

    return steps.map((step = {}) => {
        if (step.reset) {
            shown = new Set();
            states = {};
            labels = {};
        }
        asList(step.show).flatMap(expand).forEach((id) => shown.add(id));
        asList(step.hide).flatMap(expand).forEach((id) => shown.delete(id));
        const send = asList(step.send).map((key) => String(key).replace(/\s+/g, ''));
        send.forEach((key) => {
            const ends = splitEdgeKey(key);
            if (!ends) return;
            shown.add(ends[0]);
            shown.add(ends[1]);
            shown.add(canonical(key));
        });
        Object.entries(step.state ?? {}).forEach(([id, tone]) => {
            const key = canonical(id);
            if (tone === null || tone === undefined || tone === 'neutral') delete states[key];
            else states[key] = tone;
        });
        Object.entries(step.label ?? {}).forEach(([id, text]) => {
            const key = canonical(id);
            if (text === null || text === undefined || text === '') delete labels[key];
            else labels[key] = String(text);
        });

        const nodeVisible = (id) => shown.has(id);
        const visibleNodes = items.filter(nodeVisible);
        const visibleEdges = edges.filter(([from, to]) => {
            const key = edgeKey(from, to);
            if (!nodeVisible(from) || !nodeVisible(to)) return false;
            return named.has(key) ? shown.has(key) : true;
        }).map(([from, to]) => edgeKey(from, to));
        const visibleGroups = groups.filter((group) => (group.nodes ?? []).some(nodeVisible)).map((group) => group.id);

        const frame = {
            message: step.say === undefined || step.say === null ? '' : String(step.say),
            visible: [...visibleNodes, ...visibleEdges, ...visibleGroups],
            active: asList(step.active).map(canonical),
            states: { ...states },
            labels: { ...labels },
            send,
        };
        if (step.line !== undefined) frame.line = step.line;
        return frame;
    });
};
