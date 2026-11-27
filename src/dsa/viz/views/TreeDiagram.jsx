import { useMemo } from 'react';

const NODE = 38;
const GAP_X = 14;
const GAP_Y = 44;
const TONES = {
    found: { fill: 'rgba(48,209,88,0.2)', stroke: '#30D158', text: '#9FE6B0' },
    path: { fill: 'rgba(253,176,58,0.16)', stroke: 'var(--color-amber)', text: 'var(--color-amber)' },
    out: { fill: 'rgba(255,157,150,0.16)', stroke: '#FF9D96', text: '#FF9D96' },
    swap: { fill: 'rgba(253,176,58,0.22)', stroke: 'var(--color-amber)', text: 'var(--color-amber)' },
    plain: { fill: 'rgba(242,240,235,0.06)', stroke: 'rgba(242,240,235,0.35)', text: 'var(--color-paper)' },
};

// Lays out a tree of { id: { value, children: [ids] } }: leaves left to right, parents centred over children
const layout = (rootId, childrenOf) => {
    const position = new Map();
    let nextLeaf = 0;
    let depth = 0;
    const place = (id, level) => {
        depth = Math.max(depth, level + 1);
        const kids = childrenOf(id);
        if (!kids.length) {
            position.set(id, { x: nextLeaf, level });
            nextLeaf += 1;
            return;
        }
        kids.forEach((kid) => place(kid, level + 1));
        const xs = kids.map((kid) => position.get(kid).x);
        position.set(id, { x: (Math.min(...xs) + Math.max(...xs)) / 2, level });
    };
    if (rootId !== null && rootId !== undefined) place(rootId, 0);
    return { position, width: Math.max(1, nextLeaf), depth: Math.max(1, depth) };
};

// A binary tree ({ root, nodes: { id: { value, left, right, note } } }) or any tree, given childrenOf.
// Binary children keep their side: a lone right child sits to the right of its parent.
// Notes are AVL balance factors by default, shown in red beyond ±1; `plainNotes` shows any note in grey.
const TreeDiagram = ({ tree, marks = {}, label, childrenOf: customChildren, nodeLabel = (node) => String(node.value), badge, plainNotes = false }) => {
    const binary = !customChildren;
    const childrenOf = useMemo(() => customChildren ?? ((id) => {
        const node = tree.nodes[id];
        if (node.left === null && node.right === null) return [];
        return [node.left ?? `${id}-l`, node.right ?? `${id}-r`];
    }), [customChildren, tree]);
    const { position, width, depth } = useMemo(() => layout(tree.root, (id) => (tree.nodes[id] ? childrenOf(id) : [])), [tree, childrenOf]);
    const svgWidth = width * (NODE + GAP_X) + GAP_X;
    const svgHeight = depth * (NODE + GAP_Y);
    const centre = (id) => {
        const { x, level } = position.get(id);
        return { cx: GAP_X + x * (NODE + GAP_X) + NODE / 2, cy: level * (NODE + GAP_Y) + NODE / 2 + 6 };
    };
    const ids = [...position.keys()].filter((id) => tree.nodes[id]);

    if (tree.root === null || tree.root === undefined) {
        return <p className="py-6 text-center font-mono text-xs text-muted">empty tree</p>;
    }
    return (
        <div className="overflow-x-auto">
            <svg width={svgWidth} height={svgHeight + 12} viewBox={`0 0 ${svgWidth} ${svgHeight + 12}`} role="img" aria-label={label ?? 'Tree'} className="mx-auto block">
                {ids.flatMap((id) => childrenOf(id).filter((child) => tree.nodes[child]).map((child) => {
                    const from = centre(id);
                    const to = centre(child);
                    return <line key={`${id}-${child}`} x1={from.cx} y1={from.cy + NODE / 2} x2={to.cx} y2={to.cy - NODE / 2} stroke="rgba(242,240,235,0.22)" strokeWidth="1.5" />;
                }))}
                {ids.map((id) => {
                    const { cx, cy } = centre(id);
                    const tone = TONES[marks[id]] ?? TONES.plain;
                    const node = tree.nodes[id];
                    return (
                        <g key={id}>
                            <circle cx={cx} cy={cy} r={NODE / 2} fill={tone.fill} stroke={tone.stroke} strokeWidth={marks[id] ? 2 : 1} />
                            <text x={cx} y={cy + 1} textAnchor="middle" dominantBaseline="middle" fontFamily="var(--font-mono)" fontSize="12" fill={tone.text}>{nodeLabel(node)}</text>
                            {(binary || plainNotes) && node.note !== undefined && (
                                <text x={cx + NODE / 2 + 2} y={cy - NODE / 2 + 4} fontFamily="var(--font-mono)" fontSize="9" fill={!plainNotes && Math.abs(Number(node.note)) > 1 ? '#FF9D96' : 'var(--color-muted)'}>{node.note}</text>
                            )}
                            {badge?.(node) && <circle cx={cx + NODE / 2 - 4} cy={cy + NODE / 2 - 4} r="4" fill="#30D158" />}
                        </g>
                    );
                })}
            </svg>
        </div>
    );
};

export default TreeDiagram;
