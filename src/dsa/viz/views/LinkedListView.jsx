import { useId, useMemo } from 'react';
import Player from '../Player.jsx';
import { linkedListFrames, linkedListProgram } from '../algorithms/linkedList.js';

const NODE = 46;
const GAP = 34;
const TOP = 34;
const POINTER_COLOURS = { previous: '#C9A8FF', current: 'var(--color-amber)', next: '#5DD8FF', slow: '#5DD8FF', fast: 'var(--color-amber)', head: '#30D158' };

// Nodes stay in a row; arrows show each node's `next`. Forward arrows run straight, others curve below.
const ListDiagram = ({ frame }) => {
    const { nodes, next, pointers, marks } = frame;
    const arrow = `arrow-${useId().replace(/:/g, '')}`;
    const width = nodes.length * (NODE + GAP) + 40;
    const height = TOP + NODE + 86;
    const x = (id) => 10 + id * (NODE + GAP);
    const cy = TOP + NODE / 2;
    const labelled = Object.entries(pointers).filter(([, id]) => id !== null && id !== undefined);

    return (
        <div className="overflow-x-auto">
            <svg width={width} height={height} viewBox={`0 0 ${width} ${height}`} role="img" aria-label={`Linked list: ${nodes.map((node) => node.value).join(', ')}`}>
                <defs>
                    <marker id={arrow} viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
                        <path d="M0,0 L10,5 L0,10 z" fill="rgba(242,240,235,0.6)" />
                    </marker>
                </defs>
                {nodes.map((node) => {
                    const target = next[node.id];
                    if (target === null || target === undefined) {
                        return <text key={`nil-${node.id}`} x={x(node.id) + NODE + 6} y={cy + 4} fontSize="10" fontFamily="var(--font-mono)" fill="var(--color-muted)">nil</text>;
                    }
                    if (target === node.id + 1) {
                        return <line key={`edge-${node.id}`} x1={x(node.id) + NODE} y1={cy} x2={x(target) - 2} y2={cy} stroke="rgba(242,240,235,0.6)" strokeWidth="1.5" markerEnd={`url(#${arrow})`} />;
                    }
                    const from = x(node.id) + NODE / 2;
                    const to = x(target) + NODE / 2;
                    const depth = 26 + Math.abs(node.id - target) * 6;
                    return <path key={`edge-${node.id}`} d={`M ${from} ${TOP + NODE} C ${from} ${TOP + NODE + depth}, ${to} ${TOP + NODE + depth}, ${to} ${TOP + NODE + 2}`} fill="none" stroke="rgba(242,240,235,0.6)" strokeWidth="1.5" markerEnd={`url(#${arrow})`} />;
                })}
                {nodes.map((node) => (
                    <g key={node.id}>
                        <rect x={x(node.id)} y={TOP} width={NODE} height={NODE} rx="10" fill={marks[node.id] === 'found' ? 'rgba(48,209,88,0.2)' : 'rgba(242,240,235,0.06)'} stroke={marks[node.id] === 'found' ? '#30D158' : 'rgba(242,240,235,0.3)'} />
                        <text x={x(node.id) + NODE / 2} y={cy + 5} textAnchor="middle" fontSize="14" fontFamily="var(--font-mono)" fill="var(--color-paper)">{node.value}</text>
                    </g>
                ))}
                {nodes.map((node) => {
                    const names = labelled.filter(([, id]) => id === node.id).map(([name]) => name);
                    return names.map((name, index) => (
                        <text key={`${name}-${node.id}`} x={x(node.id) + NODE / 2} y={TOP - 8 - index * 12} textAnchor="middle" fontSize="10" fontWeight="600" fontFamily="var(--font-mono)" fill={POINTER_COLOURS[name] ?? 'var(--color-paper)'}>{name}</text>
                    ));
                })}
            </svg>
            <p className="font-mono text-[11px] text-muted">
                {labelled.length ? labelled.map(([name, id]) => `${name} → ${nodes[id].value}`).join(' · ') : ''}
                {Object.entries(pointers).filter(([, id]) => id === null).map(([name]) => ` · ${name} → nil`).join('')}
            </p>
        </div>
    );
};

// ```visual linkedList with { program: reverse | middle | cycle, input: { values: […], loopTo } }
const LinkedListView = ({ program = 'reverse', input = {} }) => {
    const { title, code } = linkedListProgram(program);
    const inputKey = JSON.stringify(input);
    const frames = useMemo(() => linkedListFrames(program, JSON.parse(inputKey)), [program, inputKey]);
    return (
        <Player frames={frames} code={code} title={title}>
            {(frame) => <ListDiagram frame={frame} />}
        </Player>
    );
};

export default LinkedListView;
