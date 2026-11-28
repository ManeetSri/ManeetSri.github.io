import { useMemo } from 'react';
import Player from '../../Player.jsx';
import { AMBER, BAD, OK, SKY, num, secs, ticks } from '../common.js';
import { ALGORITHM_NAMES, rateLimiterFrames } from '../rateLimiter.js';

const WIDTH = 640;
const PAD = { left: 70, right: 18, top: 26 };
const DOT = 3.5;
const STACK = 8;
const LANE = 46;
const WINDOWED = ['fixed-window', 'sliding-log', 'sliding-counter'];

const Meter = ({ label, value, max, text, tone = AMBER }) => (
    <div className="min-w-40 flex-1">
        <p className="mb-1 flex justify-between gap-3 font-mono text-[11px] text-muted"><span>{label}</span><span className="text-paper">{text}</span></p>
        <div className="h-2.5 overflow-hidden rounded-full bg-white/[0.08]" aria-hidden="true">
            <div className="h-full rounded-full motion-safe:transition-all" style={{ width: `${Math.max(0, Math.min(1, value / max)) * 100}%`, backgroundColor: tone }} />
        </div>
    </div>
);

// Requests at the same moment stack upwards
const stackOf = (results) => {
    const seen = new Map();
    return results.map((result) => {
        const key = result.time.toFixed(6);
        const height = seen.get(key) ?? 0;
        seen.set(key, height + 1);
        return height;
    });
};

const StatePanel = ({ frame }) => {
    const { algorithm, state } = frame;
    if (algorithm === 'token-bucket') {
        return <Meter label="tokens" value={state.tokens} max={state.capacity} text={`${num(state.tokens)} / ${state.capacity} · +1 every ${secs(1 / state.rate)}`} tone={state.tokens >= 1 - 1e-9 ? OK : BAD} />;
    }
    if (algorithm === 'leaky-bucket') {
        return (
            <div className="min-w-40 flex-1">
                <p className="mb-1 font-mono text-[11px] text-muted">queue {state.queue.length}/{state.capacity} · leaks 1 every {secs(1 / state.rate)}</p>
                <ol className="flex flex-wrap gap-1" aria-label="Queue">
                    {state.queue.map((entry) => (
                        <li key={entry.id} className="flex h-8 items-center rounded-md border px-1.5 font-mono text-[10px]" style={{ borderColor: SKY, color: SKY, backgroundColor: 'rgba(93,216,255,0.1)' }}>#{entry.id} → {secs(entry.leaves, 1)}</li>
                    ))}
                    {state.capacity <= 24 && Array.from({ length: state.capacity - state.queue.length }, (_, slot) => <li key={`free-${slot}`} className="h-8 w-8 rounded-md border border-dashed border-line" />)}
                </ol>
            </div>
        );
    }
    if (algorithm === 'fixed-window') {
        return <Meter label={`window ${num(state.index * state.window)}–${num((state.index + 1) * state.window)}s`} value={state.count} max={state.limit} text={`${state.count} / ${state.limit}`} tone={state.count < state.limit ? OK : BAD} />;
    }
    if (algorithm === 'sliding-log') {
        return (
            <div className="min-w-40 flex-1">
                <p className="mb-1 font-mono text-[11px] text-muted">log: {state.log.length}/{state.limit} in the last {secs(state.window)}</p>
                <ol className="flex flex-wrap gap-1" aria-label="Timestamps in the log">
                    {state.log.map((stamp, index) => <li key={index} className="rounded-md border border-line bg-white/[0.05] px-1.5 py-1 font-mono text-[10px]">{secs(stamp)}</li>)}
                    {state.log.length === 0 && <li className="font-mono text-[10px] text-muted">empty</li>}
                </ol>
            </div>
        );
    }
    return <Meter label={`estimate = ${state.previous} × ${num(state.weight)} + ${state.current}`} value={state.estimate} max={state.limit} text={`${num(state.estimate)} / ${state.limit}`} tone={state.estimate < state.limit ? OK : BAD} />;
};

const describe = (frame) => {
    const decided = frame.results.filter((result) => result.allowed !== null);
    return `${ALGORITHM_NAMES[frame.algorithm]} timeline: ${decided.length} of ${frame.results.length} requests decided, ${frame.allowed} allowed and ${frame.rejected} rejected${frame.time !== null && frame.current !== null ? `; now at ${secs(frame.time)}` : ''}.`;
};

// ```visual rateLimiter with { algorithm, capacity + refillPerSecond | capacity + leakPerSecond | window + limit, requests }
const RateLimiterView = (props) => {
    const inputKey = JSON.stringify(props);
    const frames = useMemo(() => rateLimiterFrames(JSON.parse(inputKey)), [inputKey]);
    const { algorithm } = props;
    const results = frames.at(-1).results;
    const stacks = useMemo(() => stackOf(results), [results]);
    const tallest = Math.max(1, ...stacks.map((height) => height + 1));
    const lastTime = Math.max(...results.map((result) => result.leaves ?? result.time));
    const span = Math.max(lastTime, WINDOWED.includes(algorithm) ? props.window : 1) * 1.05 || 1;
    const x = (time) => PAD.left + (time / span) * (WIDTH - PAD.left - PAD.right);
    const requestsY = PAD.top + tallest * STACK;
    const secondY = requestsY + 22;
    const hasSecond = algorithm === 'token-bucket' || algorithm === 'leaky-bucket';
    const axis = hasSecond ? secondY + LANE + 12 : requestsY + 18;
    const height = axis + 22;
    const windows = WINDOWED.includes(algorithm) ? Math.ceil(span / props.window) : 0;
    const title = props.title ?? `${ALGORITHM_NAMES[algorithm]} rate limiter`;

    return (
        <Player frames={frames} title={title}>
            {(frame) => {
                const now = frame.current === null ? (frame === frames[0] ? -1 : Infinity) : frame.time;
                return (
                    <div className="space-y-4">
                        <div className="overflow-x-auto pb-1">
                            <svg viewBox={`0 0 ${WIDTH} ${height}`} className="block w-full min-w-[520px]" role="img" aria-label={describe(frame)}>
                                {/* Windows: boundaries, the sliding window and the previous window's weight */}
                                {windows > 0 && Array.from({ length: windows + 1 }, (_, index) => (
                                    <line key={index} x1={x(index * props.window)} y1={PAD.top - 14} x2={x(index * props.window)} y2={requestsY + 8} stroke="rgba(242,240,235,0.2)" strokeDasharray={algorithm === 'sliding-log' ? '2 4' : undefined} />
                                ))}
                                {algorithm === 'fixed-window' && Object.entries(frame.state.counts ?? {}).map(([index, count]) => (
                                    <text key={index} x={x((Number(index) + 0.5) * props.window)} y={PAD.top - 16} textAnchor="middle" fontSize="10" fontFamily="var(--font-mono)" fill={count >= props.limit ? BAD : 'var(--color-muted)'}>{count}/{props.limit}</text>
                                ))}
                                {algorithm === 'sliding-counter' && frame.current !== null && (
                                    <rect x={x(Math.max(0, (frame.state.index - 1) * props.window))} y={PAD.top - 10} width={x(frame.state.index * props.window) - x(Math.max(0, (frame.state.index - 1) * props.window))} height={requestsY - PAD.top + 16} fill={SKY} fillOpacity={frame.state.index > 0 ? 0.04 + 0.16 * frame.state.weight : 0} />
                                )}
                                {(algorithm === 'sliding-log' || algorithm === 'sliding-counter') && frame.current !== null && (
                                    <rect x={x(Math.max(0, frame.time - props.window))} y={PAD.top - 10} width={x(frame.time) - x(Math.max(0, frame.time - props.window))} height={requestsY - PAD.top + 16} fill={AMBER} fillOpacity="0.1" stroke={AMBER} strokeOpacity="0.4" />
                                )}
                                <text x={8} y={requestsY + 4} fontSize="11" fontFamily="var(--font-mono)" fill="var(--color-muted)">requests</text>
                                <line x1={PAD.left} y1={requestsY + 6} x2={WIDTH - PAD.right} y2={requestsY + 6} stroke="rgba(242,240,235,0.12)" />

                                {/* Token level over time, or the leaky bucket's output */}
                                {algorithm === 'token-bucket' && (
                                    <g>
                                        <text x={8} y={secondY + LANE / 2 + 4} fontSize="11" fontFamily="var(--font-mono)" fill="var(--color-muted)">tokens</text>
                                        <line x1={PAD.left} y1={secondY} x2={WIDTH - PAD.right} y2={secondY} stroke="rgba(242,240,235,0.1)" strokeDasharray="2 4" />
                                        <line x1={PAD.left} y1={secondY + LANE} x2={WIDTH - PAD.right} y2={secondY + LANE} stroke="rgba(242,240,235,0.2)" />
                                        <text x={PAD.left - 6} y={secondY + 4} textAnchor="end" fontSize="9" fontFamily="var(--font-mono)" fill="var(--color-muted)">{props.capacity}</text>
                                        <text x={PAD.left - 6} y={secondY + LANE + 3} textAnchor="end" fontSize="9" fontFamily="var(--font-mono)" fill="var(--color-muted)">0</text>
                                        <polyline
                                            points={frame.state.level.map((point) => `${x(point.time).toFixed(1)},${(secondY + LANE * (1 - point.tokens / props.capacity)).toFixed(1)}`).join(' ')}
                                            fill="none" stroke={AMBER} strokeWidth="2" strokeLinejoin="round"
                                        />
                                    </g>
                                )}
                                {algorithm === 'leaky-bucket' && (
                                    <g>
                                        <text x={8} y={secondY + LANE / 2 + 4} fontSize="11" fontFamily="var(--font-mono)" fill="var(--color-muted)">leaves</text>
                                        <line x1={PAD.left} y1={secondY + LANE / 2} x2={WIDTH - PAD.right} y2={secondY + LANE / 2} stroke="rgba(242,240,235,0.12)" />
                                        {frame.results.map((result, index) => result.allowed && result.leaves !== undefined && (
                                            <g key={index}>
                                                <line x1={x(result.time)} y1={requestsY - stacks[index] * STACK} x2={x(result.leaves)} y2={secondY + LANE / 2} stroke={SKY} strokeOpacity="0.3" />
                                                <circle cx={x(result.leaves)} cy={secondY + LANE / 2} r={DOT} fill={result.leaves <= now + 1e-9 ? SKY : 'var(--color-surface)'} stroke={SKY} strokeWidth="1.2" />
                                            </g>
                                        ))}
                                    </g>
                                )}

                                {frame.results.map((result, index) => {
                                    const cx = x(result.time);
                                    const cy = requestsY - stacks[index] * STACK;
                                    const colour = result.allowed === null ? null : result.allowed ? OK : BAD;
                                    return (
                                        <g key={index}>
                                            {index === frame.current && <circle cx={cx} cy={cy} r={DOT + 3} fill="none" stroke={AMBER} strokeWidth="1.8" />}
                                            <circle cx={cx} cy={cy} r={DOT} fill={colour ?? 'none'} stroke={colour ?? 'rgba(242,240,235,0.3)'} strokeWidth="1.2" />
                                        </g>
                                    );
                                })}
                                <line x1={PAD.left} y1={axis} x2={WIDTH - PAD.right} y2={axis} stroke="rgba(242,240,235,0.25)" />
                                {ticks(span * 0.98).map((tick) => (
                                    <g key={tick}>
                                        <line x1={x(tick)} y1={axis} x2={x(tick)} y2={axis + 4} stroke="rgba(242,240,235,0.25)" />
                                        <text x={x(tick)} y={axis + 16} textAnchor="middle" fontSize="10" fontFamily="var(--font-mono)" fill="var(--color-muted)">{num(tick)}s</text>
                                    </g>
                                ))}
                            </svg>
                        </div>
                        <div className="flex flex-wrap items-end gap-4">
                            <StatePanel frame={frame} />
                            <p className="font-mono text-xs">
                                <span style={{ color: OK }}>{frame.allowed} allowed</span>
                                <span className="text-muted"> · </span>
                                <span style={{ color: BAD }}>{frame.rejected} rejected</span>
                            </p>
                        </div>
                    </div>
                );
            }}
        </Player>
    );
};

export default RateLimiterView;
