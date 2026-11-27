import { useId, useMemo } from 'react';
import Player from '../Player.jsx';
import { edgeKey, graphFrames, graphProgram, GRID_CODE, gridFrames } from '../algorithms/graphs.js';

const WIDTH = 560;
const HEIGHT = 250;
const RADIUS = 20;
const NODE_TONES = {
    idle: { fill: 'rgba(242,240,235,0.06)', stroke: 'rgba(242,240,235,0.35)', text: 'var(--color-paper)' },
    frontier: { fill: 'rgba(93,216,255,0.15)', stroke: '#5DD8FF', text: '#5DD8FF' },
    current: { fill: 'rgba(253,176,58,0.25)', stroke: 'var(--color-amber)', text: 'var(--color-amber)' },
    done: { fill: 'rgba(48,209,88,0.18)', stroke: '#30D158', text: '#9FE6B0' },
};
const EDGE_TONES = { tree: '#30D158', used: 'var(--color-amber)', rejected: 'rgba(255,157,150,0.5)' };

const useStable = (value) => {
    const key = JSON.stringify(value ?? null);
    return useMemo(() => JSON.parse(key), [key]);
};

const GraphDiagram = ({ graph, frame }) => {
    const marker = `graph-arrow-${useId().replace(/:/g, '')}`;
    const position = Object.fromEntries(graph.nodes.map((node) => [node.id, { x: 30 + (node.x / 100) * (WIDTH - 60), y: 26 + (node.y / 100) * (HEIGHT - 52) }]));
    return (
        <div className="overflow-x-auto">
            <svg viewBox={`0 0 ${WIDTH} ${HEIGHT}`} className="block w-full min-w-[420px]" role="img" aria-label={`Graph with ${graph.nodes.length} nodes and ${graph.edges.length} edges`}>
                <defs>
                    <marker id={marker} viewBox="0 0 10 10" refX="10" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
                        <path d="M0,0 L10,5 L0,10 z" fill="rgba(242,240,235,0.55)" />
                    </marker>
                </defs>
                {graph.edges.map(([a, b, weight]) => {
                    const from = position[a];
                    const to = position[b];
                    const length = Math.hypot(to.x - from.x, to.y - from.y);
                    const ux = (to.x - from.x) / length;
                    const uy = (to.y - from.y) / length;
                    const tone = frame.edges[edgeKey(a, b, graph.directed)];
                    return (
                        <g key={`${a}-${b}`}>
                            <line
                                x1={from.x + ux * RADIUS} y1={from.y + uy * RADIUS} x2={to.x - ux * (RADIUS + 2)} y2={to.y - uy * (RADIUS + 2)}
                                stroke={EDGE_TONES[tone] ?? 'rgba(242,240,235,0.25)'} strokeWidth={tone === 'tree' ? 3 : 1.5} strokeDasharray={tone === 'rejected' ? '4 4' : undefined}
                                markerEnd={graph.directed ? `url(#${marker})` : undefined}
                            />
                            {(frame.edgeLabels?.[edgeKey(a, b, graph.directed)] ?? weight) !== undefined && (
                                <text x={(from.x + to.x) / 2 + uy * 10} y={(from.y + to.y) / 2 - ux * 10 + 4} textAnchor="middle" fontSize="11" fontFamily="var(--font-mono)" fill="var(--color-muted)">{frame.edgeLabels?.[edgeKey(a, b, graph.directed)] ?? weight}</text>
                            )}
                        </g>
                    );
                })}
                {graph.nodes.map((node) => {
                    const { x, y } = position[node.id];
                    const tone = NODE_TONES[frame.states[node.id]] ?? NODE_TONES.idle;
                    const short = node.id.length > 3;
                    return (
                        <g key={node.id}>
                            <circle cx={x} cy={y} r={short ? RADIUS + 6 : RADIUS} fill={tone.fill} stroke={tone.stroke} strokeWidth="1.5" />
                            <text x={x} y={y + 1} textAnchor="middle" dominantBaseline="middle" fontSize={short ? 10 : 13} fontFamily="var(--font-mono)" fill={tone.text}>{node.id}</text>
                            {frame.labels?.[node.id] !== undefined && (
                                <text x={x} y={y - RADIUS - 8} textAnchor="middle" fontSize="10" fontFamily="var(--font-mono)" fill="var(--color-amber)">{frame.labels[node.id]}</text>
                            )}
                        </g>
                    );
                })}
            </svg>
        </div>
    );
};

const SidePanels = ({ side }) => (
    <div className="mt-3 flex flex-wrap gap-x-6 gap-y-2">
        {side?.map((panel) => (
            <div key={panel.title}>
                <p className="font-mono text-[11px] uppercase tracking-wider text-muted">{panel.title}</p>
                <p className="mt-0.5 font-mono text-sm">{panel.items.length ? panel.items.join('  ') : '—'}</p>
            </div>
        ))}
    </div>
);

// ```visual graph with { program, graph: a built-in name or { directed, nodes, edges }, start, end (maxFlow's sink) }
export const GraphView = ({ program = 'bfs', graph, start, end }) => {
    const stableGraph = useStable(graph);
    const { title, code } = graphProgram(program);
    const { graph: resolved, frames } = useMemo(() => graphFrames(program, { graph: stableGraph ?? undefined, start, end }), [program, stableGraph, start, end]);
    return (
        <Player frames={frames} code={code} title={title}>
            {(frame) => (
                <div>
                    <GraphDiagram graph={resolved} frame={frame} />
                    <SidePanels side={frame.side} />
                </div>
            )}
        </Player>
    );
};

// ```visual grid with { rows: ["S..#", ".#..", "...G"] } where S is the start, G the goal and # a wall
export const GridView = ({ rows }) => {
    const stableRows = useStable(rows);
    const frames = useMemo(() => gridFrames(stableRows ? { rows: stableRows } : {}), [stableRows]);
    return (
        <Player frames={frames} code={GRID_CODE} title="Breadth-first search on a grid">
            {(frame) => (
                <div className="overflow-x-auto">
                    <div className="inline-grid gap-1" style={{ gridTemplateColumns: `repeat(${frame.grid[0].length}, 2.5rem)` }} role="img" aria-label="Grid; numbers are distances from S">
                        {frame.grid.flatMap((row, r) => row.map((cell, c) => {
                            const key = `${r},${c}`;
                            const isCurrent = frame.current && frame.current[0] === r && frame.current[1] === c;
                            const onPath = frame.path.includes(key);
                            const queued = frame.queue.includes(key);
                            const distance = frame.distance[r][c];
                            const tone = cell === '#' ? 'bg-white/25 border-transparent'
                                : isCurrent ? 'border-amber bg-amber/25 text-amber'
                                    : onPath ? 'border-[#30D158] bg-[#30D158]/25 text-[#30D158]'
                                        : queued ? 'border-sky-400 bg-sky-400/15 text-sky-300'
                                            : distance !== null ? 'border-[#30D158]/40 bg-[#30D158]/[0.07]' : 'border-line';
                            return (
                                <span key={key} className={`flex h-10 w-10 items-center justify-center rounded-md border font-mono text-xs ${tone}`}>
                                    {cell === 'S' || cell === 'G' ? cell : cell === '#' ? '' : distance ?? ''}
                                </span>
                            );
                        }))}
                    </div>
                    <p className="mt-3 font-mono text-xs text-muted">queue: <span className="text-sky-300">{frame.queue.join('  ') || '—'}</span></p>
                </div>
            )}
        </Player>
    );
};
