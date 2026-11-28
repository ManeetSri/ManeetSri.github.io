import { useMemo } from 'react';
import Player from '../../Player.jsx';
import { BAD, OWNER_COLOURS } from '../common.js';
import { hashRingFrames } from '../hashRing.js';

const SIZE = 340;
const CENTRE = SIZE / 2;
const RING = 122;
const KEYS = 100;
const LABELS = 146;

const polar = (at, radius) => {
    const angle = at * 2 * Math.PI;
    return { x: CENTRE + radius * Math.sin(angle), y: CENTRE - radius * Math.cos(angle) };
};

// The clockwise arc of the ring from `from` to `to` (fractions of a turn)
const arc = (from, to, radius) => {
    const sweep = ((to - from) % 1 + 1) % 1;
    const start = polar(from, radius);
    const end = polar(to, radius);
    return `M ${start.x.toFixed(2)} ${start.y.toFixed(2)} A ${radius} ${radius} 0 ${sweep > 0.5 ? 1 : 0} 1 ${end.x.toFixed(2)} ${end.y.toFixed(2)}`;
};

const describe = (frame) => {
    const loads = frame.nodes.map((node) => `${node} owns ${Math.round(frame.shares[node] * 100)}% of the ring${frame.showKeys ? ` and ${frame.loads[node]} keys` : ''}`);
    return `Hash ring with ${frame.nodes.length} nodes and ${frame.vnodes} point${frame.vnodes === 1 ? '' : 's'} each: ${loads.join('; ')}.${frame.moved !== null ? ` ${frame.moved} keys moved.` : ''}`;
};

// ```visual hashRing with { nodes, vnodes, keys, steps: [{ add } | { remove }], hash: mixed | fnv1a }
const HashRingView = (props) => {
    const inputKey = JSON.stringify(props);
    const frames = useMemo(() => hashRingFrames(JSON.parse(inputKey)), [inputKey]);
    const colourOf = (node) => OWNER_COLOURS[frames[0].order.indexOf(node) % OWNER_COLOURS.length];
    const title = props.title ?? `Consistent hashing: ${props.nodes.length} nodes${(props.vnodes ?? 1) > 1 ? `, ${props.vnodes} virtual nodes each` : ''}`;

    return (
        <Player frames={frames} title={title}>
            {(frame) => {
                const live = frame.points.filter((point) => !point.gone);
                const labelled = frame.points.length <= 24;
                const moved = frame.keys.filter((key) => key.from !== null);
                return (
                    <div className="grid items-start gap-4 sm:grid-cols-[minmax(0,1fr)_minmax(0,14rem)]">
                        <svg viewBox={`0 0 ${SIZE} ${SIZE}`} className="mx-auto block w-full max-w-[22rem]" role="img" aria-label={describe(frame)}>
                            <circle cx={CENTRE} cy={CENTRE} r={RING} fill="none" stroke="rgba(242,240,235,0.12)" strokeWidth="10" />
                            {live.length === 1 ? (
                                <circle cx={CENTRE} cy={CENTRE} r={RING} fill="none" stroke={colourOf(live[0].node)} strokeOpacity="0.5" strokeWidth="10" />
                            ) : live.map((point, index) => (
                                <path key={`arc-${point.node}-${point.vnode}`} d={arc(live[(index - 1 + live.length) % live.length].at, point.at, RING)} fill="none" stroke={colourOf(point.node)} strokeOpacity={point.fresh ? 0.8 : 0.45} strokeWidth="10" />
                            ))}
                            <text x={CENTRE} y={CENTRE - 6} textAnchor="middle" fontSize="12" fontFamily="var(--font-mono)" fill="var(--color-paper)">{frame.showKeys ? `${frame.keys.length} keys` : 'ring'}</text>
                            <text x={CENTRE} y={CENTRE + 12} textAnchor="middle" fontSize="10" fontFamily="var(--font-mono)" fill="var(--color-muted)">0 at the top, clockwise</text>
                            {frame.showKeys && frame.keys.map((key) => {
                                const { x, y } = polar(key.at, KEYS);
                                return (
                                    <g key={key.key}>
                                        {key.from !== null && <circle cx={x} cy={y} r={6.5} fill="none" stroke="var(--color-paper)" strokeWidth="1.5" />}
                                        <circle cx={x} cy={y} r={3.5} fill={colourOf(key.owner)}>
                                            <title>{`${key.key} → ${key.owner}${key.from !== null ? ` (was ${key.from})` : ''}`}</title>
                                        </circle>
                                    </g>
                                );
                            })}
                            {frame.points.map((point) => {
                                const { x, y } = polar(point.at, RING);
                                const label = polar(point.at, LABELS);
                                const name = frame.vnodes === 1 ? point.node : `${point.node}${point.vnode}`;
                                return (
                                    <g key={`${point.node}-${point.vnode}-${point.gone}`}>
                                        {point.gone ? (
                                            <circle cx={x} cy={y} r={6} fill="var(--color-surface)" stroke={BAD} strokeWidth="1.5" strokeDasharray="2 2" />
                                        ) : (
                                            <circle cx={x} cy={y} r={point.fresh ? 8 : 6} fill={colourOf(point.node)} stroke={point.fresh ? 'var(--color-paper)' : 'var(--color-surface)'} strokeWidth="2" />
                                        )}
                                        {labelled && (
                                            <text x={label.x} y={label.y + 4} textAnchor="middle" fontSize="11" fontFamily="var(--font-mono)" fill={point.gone ? BAD : colourOf(point.node)} textDecoration={point.gone ? 'line-through' : undefined}>{name}</text>
                                        )}
                                    </g>
                                );
                            })}
                        </svg>
                        <div className="space-y-3">
                            <table className="w-full text-left font-mono text-xs">
                                <thead className="text-muted">
                                    <tr><th className="py-1 pr-2 font-medium">node</th><th className="py-1 pr-2 text-right font-medium">ring</th>{frame.showKeys && <th className="py-1 text-right font-medium">keys</th>}</tr>
                                </thead>
                                <tbody>
                                    {frame.nodes.map((node) => (
                                        <tr key={node} className="border-t border-line">
                                            <td className="py-1.5 pr-2"><span className="mr-2 inline-block h-2.5 w-2.5 rounded-full align-middle" style={{ backgroundColor: colourOf(node) }} />{node}</td>
                                            <td className="py-1.5 pr-2 text-right text-muted">{Math.round(frame.shares[node] * 100)}%</td>
                                            {frame.showKeys && <td className="py-1.5 text-right">{frame.loads[node]}</td>}
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                            {frame.moved !== null && (
                                <div className="rounded-xl bg-white/[0.04] px-3 py-2.5 font-mono text-xs">
                                    <p><span className="text-paper">{frame.moved}</span> <span className="text-muted">moved on the ring</span></p>
                                    <p><span style={{ color: BAD }}>{frame.naiveMoved}</span> <span className="text-muted">would move with hash % N</span></p>
                                    {moved.length > 0 && (
                                        <ul className="mt-2 flex flex-wrap gap-1" aria-label="Keys that moved">
                                            {moved.map((key) => (
                                                <li key={key.key} className="rounded-md border border-line px-1.5 py-0.5 text-[10px]">
                                                    {key.key} <span style={{ color: colourOf(key.from) }}>{key.from}</span>→<span style={{ color: colourOf(key.owner) }}>{key.owner}</span>
                                                </li>
                                            ))}
                                        </ul>
                                    )}
                                </div>
                            )}
                        </div>
                    </div>
                );
            }}
        </Player>
    );
};

export default HashRingView;
