import { useId, useMemo } from 'react';
import Player from '../Player.jsx';
import { linkedListFrames, linkedListProgram } from '../algorithms/linkedList.js';

const NODE = 46;
const GAP = 34;
const TOP = 34;
const POINTER_COLOURS = { previous: '#C9A8FF', current: 'var(--color-amber)', next: '#5DD8FF', slow: '#5DD8FF', fast: 'var(--color-amber)', head: '#30D158', tail: 'var(--color-amber)', a: '#5DD8FF', b: '#C9A8FF', dummy: '#30D158' };
const ROW_GAP = NODE + 50;

// Straight arrow between two node boxes, leaving and entering at their edges
const edgePoints = (from, to) => {
    const [fx, fy, tx, ty] = [from.x + NODE / 2, from.y + NODE / 2, to.x + NODE / 2, to.y + NODE / 2];
    const [dx, dy] = [tx - fx, ty - fy];
    const scale = (NODE / 2) / Math.max(Math.abs(dx), Math.abs(dy));
    return { x1: fx + dx * scale, y1: fy + dy * scale, x2: tx - dx * scale * 1.08, y2: ty - dy * scale * 1.08 };
};

// Nodes stay in a row; arrows show each node's `next`. Forward arrows run straight, others curve below.
// With `positions` ({ id: { col, row } }) nodes sit on a grid instead, and every arrow is straight.
const ListDiagram = ({ frame }) => {
    const { nodes, next, pointers, marks, positions } = frame;
    const arrow = `arrow-${useId().replace(/:/g, '')}`;
    const columns = positions ? Math.max(...Object.values(positions).map((spot) => spot.col)) + 1 : nodes.length;
    const rows = positions ? Math.max(...Object.values(positions).map((spot) => spot.row)) + 1 : 1;
    const width = columns * (NODE + GAP) + 40;
    const height = positions ? TOP + (rows - 1) * ROW_GAP + NODE + 50 : TOP + NODE + 86;
    const spot = (id) => (positions ? { x: 10 + positions[id].col * (NODE + GAP), y: TOP + positions[id].row * ROW_GAP } : { x: 10 + id * (NODE + GAP), y: TOP });
    const x = (id) => spot(id).x;
    // On a lower row, arrows arrive from above, so pointer names go underneath the node instead
    const labelBelow = (id) => Boolean(positions && positions[id].row >= 1);
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
                        return <text key={`nil-${node.id}`} x={x(node.id) + NODE + 6} y={spot(node.id).y + NODE / 2 + 4} fontSize="10" fontFamily="var(--font-mono)" fill="var(--color-muted)">nil</text>;
                    }
                    if (positions) {
                        return <line key={`edge-${node.id}`} {...edgePoints(spot(node.id), spot(target))} stroke="rgba(242,240,235,0.6)" strokeWidth="1.5" markerEnd={`url(#${arrow})`} />;
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
                        <rect x={x(node.id)} y={spot(node.id).y} width={NODE} height={NODE} rx="10" fill={marks[node.id] === 'found' ? 'rgba(48,209,88,0.2)' : 'rgba(242,240,235,0.06)'} stroke={marks[node.id] === 'found' ? '#30D158' : 'rgba(242,240,235,0.3)'} />
                        <text x={x(node.id) + NODE / 2} y={spot(node.id).y + NODE / 2 + 5} textAnchor="middle" fontSize="14" fontFamily="var(--font-mono)" fill="var(--color-paper)">{node.value}</text>
                    </g>
                ))}
                {nodes.map((node) => {
                    const names = labelled.filter(([, id]) => id === node.id).map(([name]) => name);
                    return names.map((name, index) => (
                        <text key={`${name}-${node.id}`} x={x(node.id) + NODE / 2} y={labelBelow(node.id) ? spot(node.id).y + NODE + 14 + index * 12 : spot(node.id).y - 8 - index * 12} textAnchor="middle" fontSize="10" fontWeight="600" fontFamily="var(--font-mono)" fill={POINTER_COLOURS[name] ?? 'var(--color-paper)'}>{name}</text>
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

// ```visual linkedList with { program: reverse | middle | cycle, input: { values: […], loopTo } },
// or { program: merge, input: { first: […], second: […] } }
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
