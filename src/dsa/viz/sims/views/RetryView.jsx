import { useMemo } from 'react';
import Player from '../../Player.jsx';
import { AMBER, BAD, OK, SKY, num, secs, ticks } from '../common.js';
import { retryFrames } from '../retry.js';

const WIDTH = 640;
const PAD = { left: 66, right: 18 };
const CALLS = 40;
const BREAKER = 84;
const STATE_FILLS = { closed: 'rgba(48,209,88,0.22)', open: 'rgba(255,157,150,0.3)', 'half-open': 'rgba(253,176,58,0.35)' };
const STATE_TEXT = { closed: '#9FE6B0', open: BAD, 'half-open': AMBER };
const OUTCOMES = { success: 'succeeded', failure: 'failed', rejected: 'short-circuited' };
const OUTCOME_COLOURS = { success: OK, failure: BAD, rejected: 'var(--color-muted)' };

const describe = (frame) => {
    const shown = frame.attempts.slice(0, frame.shown);
    if (shown.length === 0) return 'Retry timeline, before the first attempt';
    return `Retry timeline: ${shown.map((attempt) => `attempt ${attempt.n} at ${secs(attempt.time)} ${OUTCOMES[attempt.outcome]}${attempt.wait ? `, then waits ${secs(attempt.wait.delay)}` : ''}`).join('; ')}.`;
};

// ```visual retry with { base, factor, cap, attempts, jitter, seed, failUntil, breaker?: { threshold, cooldown } }
const RetryView = (props) => {
    const inputKey = JSON.stringify(props);
    const frames = useMemo(() => retryFrames(JSON.parse(inputKey)), [inputKey]);
    const { end, breaker } = frames[0];
    // One axis for every frame, so nothing jumps while stepping
    const span = Math.max(end, 1) * 1.04;
    const x = (time) => PAD.left + (time / span) * (WIDTH - PAD.left - PAD.right);
    const axis = breaker ? BREAKER + 30 : CALLS + 38;
    const height = axis + 22;
    const jitter = props.jitter ?? 'none';
    const title = props.title ?? `Exponential backoff${jitter === 'none' ? '' : ` with ${jitter} jitter`}${breaker ? ' and a circuit breaker' : ''}`;

    return (
        <Player frames={frames} title={title}>
            {(frame) => {
                const shown = frame.attempts.slice(0, frame.shown);
                return (
                    <div className="space-y-4">
                        <div className="overflow-x-auto pb-1">
                            <svg viewBox={`0 0 ${WIDTH} ${height}`} className="block w-full min-w-[520px]" role="img" aria-label={describe(frame)}>
                                <text x={8} y={CALLS + 4} fontSize="11" fontFamily="var(--font-mono)" fill="var(--color-muted)">calls</text>
                                <line x1={PAD.left} y1={CALLS} x2={WIDTH - PAD.right} y2={CALLS} stroke="rgba(242,240,235,0.15)" />
                                {breaker && <text x={8} y={BREAKER + 4} fontSize="11" fontFamily="var(--font-mono)" fill="var(--color-muted)">breaker</text>}
                                {breaker && frame.segments.map((segment, index) => {
                                    const to = Math.min(segment.to, frame.until);
                                    if (to <= segment.from) return null;
                                    const left = x(segment.from);
                                    const width = Math.max(2, x(to) - left);
                                    return (
                                        <g key={index}>
                                            <rect x={left} y={BREAKER - 9} width={width} height={18} rx="4" fill={STATE_FILLS[segment.state]} />
                                            {width > 56 && <text x={left + width / 2} y={BREAKER + 4} textAnchor="middle" fontSize="10" fontFamily="var(--font-mono)" fill={STATE_TEXT[segment.state]}>{segment.state}</text>}
                                        </g>
                                    );
                                })}
                                {shown.map((attempt) => attempt.wait && (
                                    <g key={`wait-${attempt.n}`}>
                                        {attempt.wait.low !== attempt.wait.high && (
                                            // The range a jittered wait was drawn from, cut off at the edge of the axis
                                            <rect x={x(attempt.time + attempt.wait.low)} y={CALLS - 7} width={Math.max(1, Math.min(WIDTH - PAD.right, x(attempt.time + attempt.wait.ceiling)) - x(attempt.time + attempt.wait.low))} height={14} rx="3" fill="none" stroke="rgba(93,216,255,0.55)" strokeDasharray="3 3" />
                                        )}
                                        <rect x={x(attempt.time)} y={CALLS - 4} width={Math.max(1, x(attempt.time + attempt.wait.delay) - x(attempt.time))} height={8} rx="2" fill="rgba(93,216,255,0.35)" />
                                        {x(attempt.time + attempt.wait.delay) - x(attempt.time) > 34 && (
                                            <text x={(x(attempt.time) + x(attempt.time + attempt.wait.delay)) / 2} y={CALLS - 12} textAnchor="middle" fontSize="10" fontFamily="var(--font-mono)" fill={SKY}>{secs(attempt.wait.delay)}</text>
                                        )}
                                    </g>
                                ))}
                                {shown.map((attempt, index) => {
                                    const cx = x(attempt.time);
                                    const crowded = index > 0 && cx - x(shown[index - 1].time) < 16;
                                    return (
                                        <g key={attempt.n}>
                                            {index === frame.current && <circle cx={cx} cy={CALLS} r={11} fill="none" stroke={AMBER} strokeWidth="2" />}
                                            {attempt.outcome === 'rejected' ? (
                                                <g stroke="var(--color-muted)" strokeWidth="1.5">
                                                    <circle cx={cx} cy={CALLS} r={6} fill="var(--color-surface)" />
                                                    <line x1={cx - 3} y1={CALLS - 3} x2={cx + 3} y2={CALLS + 3} />
                                                    <line x1={cx - 3} y1={CALLS + 3} x2={cx + 3} y2={CALLS - 3} />
                                                </g>
                                            ) : (
                                                <circle cx={cx} cy={CALLS} r={6} fill={OUTCOME_COLOURS[attempt.outcome]} stroke="var(--color-surface)" strokeWidth="1.5" />
                                            )}
                                            {!crowded && <text x={cx} y={CALLS + 22} textAnchor="middle" fontSize="10" fontFamily="var(--font-mono)" fill="var(--color-muted)">#{attempt.n}</text>}
                                        </g>
                                    );
                                })}
                                {frame.shown > 0 && <line x1={x(frame.until)} y1={CALLS - 22} x2={x(frame.until)} y2={axis} stroke={AMBER} strokeOpacity="0.5" strokeDasharray="2 3" />}
                                <line x1={PAD.left} y1={axis} x2={WIDTH - PAD.right} y2={axis} stroke="rgba(242,240,235,0.25)" />
                                {ticks(span * 0.98).map((tick) => (
                                    <g key={tick}>
                                        <line x1={x(tick)} y1={axis} x2={x(tick)} y2={axis + 4} stroke="rgba(242,240,235,0.25)" />
                                        <text x={x(tick)} y={axis + 16} textAnchor="middle" fontSize="10" fontFamily="var(--font-mono)" fill="var(--color-muted)">{num(tick)}s</text>
                                    </g>
                                ))}
                            </svg>
                        </div>
                        <ul className="flex flex-wrap gap-x-4 gap-y-1 font-mono text-[10px] text-muted" aria-hidden="true">
                            <li className="flex items-center gap-1.5"><span className="h-2 w-2 rounded-full" style={{ backgroundColor: OK }} />success</li>
                            <li className="flex items-center gap-1.5"><span className="h-2 w-2 rounded-full" style={{ backgroundColor: BAD }} />failure</li>
                            <li className="flex items-center gap-1.5"><span className="h-2 w-2 rounded-full border border-muted" />short-circuited</li>
                            <li className="flex items-center gap-1.5"><span className="h-2 w-4 rounded-sm" style={{ backgroundColor: 'rgba(93,216,255,0.35)' }} />wait</li>
                            {jitter !== 'none' && <li className="flex items-center gap-1.5"><span className="h-2 w-4 rounded-sm border border-dashed" style={{ borderColor: 'rgba(93,216,255,0.55)' }} />jitter range</li>}
                        </ul>
                        {shown.length > 0 && (
                            <div className="overflow-x-auto rounded-xl border border-line">
                                <table className="w-full text-left font-mono text-xs">
                                    <thead className="bg-white/[0.04] text-muted">
                                        <tr>
                                            <th className="px-3 py-2 font-medium">#</th>
                                            <th className="px-3 py-2 font-medium">at</th>
                                            <th className="px-3 py-2 font-medium">result</th>
                                            {breaker && <th className="px-3 py-2 font-medium">breaker</th>}
                                            <th className="px-3 py-2 font-medium">then wait</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {shown.map((attempt, index) => (
                                            <tr key={attempt.n} className={`border-t border-line ${index === frame.current ? 'bg-amber/10' : ''}`}>
                                                <td className="px-3 py-1.5">{attempt.n}</td>
                                                <td className="px-3 py-1.5">{secs(attempt.time)}</td>
                                                <td className="px-3 py-1.5" style={{ color: OUTCOME_COLOURS[attempt.outcome] }}>{OUTCOMES[attempt.outcome]}</td>
                                                {breaker && <td className="px-3 py-1.5 text-muted">{attempt.breaker}{attempt.change ? ` → ${attempt.change === 'opened' ? 'open' : 'closed'}` : ''}</td>}
                                                <td className="px-3 py-1.5 text-muted">{attempt.wait ? secs(attempt.wait.delay) : '—'}</td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}
                    </div>
                );
            }}
        </Player>
    );
};

export default RetryView;
