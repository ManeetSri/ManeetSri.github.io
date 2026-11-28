import { useId, useMemo } from 'react';
import Player from '../Player.jsx';
import { ASTAR_CODE, astarFrames, edgeKey, graphFrames, graphProgram, GRID_CODE, gridFrames } from '../algorithms/graphs.js';
import { ArrowMarker, clipCircle } from '../svg.js';
import { EDGE_TONES, NODE_TONES } from '../tones.js';
import { useStable } from '../useStable.js';

const WIDTH = 560;
const HEIGHT = 250;
const RADIUS = 20;

const GraphDiagram = ({ graph, frame }) => {
    const marker = `graph-arrow-${useId().replace(/:/g, '')}`;
    const position = Object.fromEntries(graph.nodes.map((node) => [node.id, { x: 30 + (node.x / 100) * (WIDTH - 60), y: 26 + (node.y / 100) * (HEIGHT - 52) }]));
    return (
        <div className="overflow-x-auto">
            <svg viewBox={`0 0 ${WIDTH} ${HEIGHT}`} className="block w-full min-w-[420px]" role="img" aria-label={`Graph with ${graph.nodes.length} nodes and ${graph.edges.length} edges`}>
                <defs>
                    <ArrowMarker id={marker} />
                </defs>
                {graph.edges.map(([a, b, weight]) => {
                    const from = position[a];
                    const to = position[b];
                    const length = Math.hypot(to.x - from.x, to.y - from.y);
                    const ux = (to.x - from.x) / length;
                    const uy = (to.y - from.y) / length;
                    const start = clipCircle(from, to, RADIUS);
                    const end = clipCircle(to, from, RADIUS + 2);
                    const tone = frame.edges[edgeKey(a, b, graph.directed)];
                    return (
                        <g key={`${a}-${b}`}>
                            <line
                                x1={start.x} y1={start.y} x2={end.x} y2={end.y}
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
// A* (or Dijkstra, with h = 0) on a grid: each reached cell shows g and h in its top corners and f = g + h in the middle
const HeapSearchGrid = ({ rows, algorithm }) => {
    const stableRows = useStable(rows);
    const frames = useMemo(() => astarFrames({ ...(stableRows ? { rows: stableRows } : {}), algorithm }), [stableRows, algorithm]);
    const isAStar = algorithm === 'astar';
    return (
        <Player frames={frames} code={ASTAR_CODE[algorithm]} title={isAStar ? 'A* on a grid: f = g + h' : 'Dijkstra on a grid: A* with h = 0'}>
            {(frame) => (
                <div className="overflow-x-auto">
                    <div className="inline-grid gap-1" style={{ gridTemplateColumns: `repeat(${frame.grid[0].length}, 2.75rem)` }} role="img" aria-label={isAStar ? 'Grid; each reached cell shows g, h and f' : 'Grid; numbers are distances from S'}>
                        {frame.grid.flatMap((row, r) => row.map((cell, c) => {
                            const key = `${r},${c}`;
                            const g = frame.g[r][c];
                            const isCurrent = frame.current && frame.current[0] === r && frame.current[1] === c;
                            const queued = frame.open.some((entry) => entry.key === key);
                            const tone = cell === '#' ? 'bg-white/25 border-transparent'
                                : isCurrent ? 'border-amber bg-amber/25 text-amber'
                                    : frame.path.includes(key) ? 'border-[#30D158] bg-[#30D158]/25 text-[#30D158]'
                                        : frame.expanded[r][c] ? 'border-[#30D158]/40 bg-[#30D158]/[0.07]'
                                            : queued ? 'border-sky-400 bg-sky-400/15 text-sky-300' : 'border-line text-muted';
                            return (
                                <span key={key} className={`relative flex h-11 w-11 items-center justify-center rounded-md border font-mono text-xs ${tone}`}>
                                    {isAStar && g !== null && cell !== '#' && (
                                        <span className="absolute inset-x-1 top-0.5 flex justify-between text-[9px] leading-none opacity-75"><span>{g}</span><span>{frame.h[r][c]}</span></span>
                                    )}
                                    <span className={isAStar ? 'mt-2' : ''}>{cell === 'S' || cell === 'G' ? (g === null || !isAStar ? cell : `${cell}${g + frame.h[r][c]}`) : cell === '#' || g === null ? '' : g + frame.h[r][c]}</span>
                                </span>
                            );
                        }))}
                    </div>
                    {isAStar && <p className="mt-2 font-mono text-[11px] text-muted">top left g · top right h · middle f = g + h</p>}
                    <p className="mt-2 font-mono text-xs text-muted">heap, smallest {isAStar ? 'f' : 'g'} first: <span className="text-sky-300">{frame.open.slice(0, 8).map((entry) => `${entry.key} ${isAStar ? 'f' : 'g'}${entry.f}`).join('  ') || '—'}{frame.open.length > 8 ? `  +${frame.open.length - 8} more` : ''}</span></p>
                    <p className="mt-1 font-mono text-xs text-muted">expanded: <span className="text-[#30D158]">{frame.count}</span></p>
                </div>
            )}
        </Player>
    );
};

const BfsGrid = ({ rows }) => {
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

// `algorithm`: 'bfs' (the default), 'astar', or 'dijkstra'
export const GridView = ({ rows, algorithm = 'bfs' }) => (algorithm === 'bfs' ? <BfsGrid rows={rows} /> : <HeapSearchGrid rows={rows} algorithm={algorithm} />);
