import { useMemo } from 'react';
import Player from '../Player.jsx';
import { intervalFrames, intervalProgram } from '../algorithms/intervals.js';

const TONES = {
    current: 'border-amber bg-amber/25 text-amber',
    kept: 'border-[#30D158]/70 bg-[#30D158]/15 text-[#30D158]',
    removed: 'border-dashed border-[#FF9D96]/70 bg-[#FF9D96]/10 text-[#FF9D96]',
    active: 'border-sky-400/80 bg-sky-400/15 text-sky-300',
    done: 'border-line bg-white/[0.03] text-muted',
};
const TONE_WORDS = { current: 'current', kept: 'kept', removed: 'removed', active: 'running', done: 'finished' };
const PLAIN = 'border-white/25 bg-white/[0.08]';

// Lanes without `each` share rows: each interval goes in the first row it doesn't overlap (touching is fine)
const packRows = (lane) => {
    if (lane.each) return lane.intervals.map((interval) => [interval]);
    const rows = [];
    lane.intervals.forEach((interval) => {
        const free = rows.find((row) => row.every((other) => interval.end <= other.start || other.end <= interval.start));
        if (free) free.push(interval); else rows.push([interval]);
    });
    return rows;
};

const tickStep = (range) => (range <= 12 ? 1 : range <= 24 ? 2 : range <= 60 ? 5 : Math.ceil(range / 100) * 10);

// ```visual intervals with { program, input: { … } }
const IntervalsView = ({ program = 'merge', input = {} }) => {
    const { title, code } = intervalProgram(program);
    const inputKey = JSON.stringify(input);
    const frames = useMemo(() => intervalFrames(program, JSON.parse(inputKey)), [program, inputKey]);

    // One axis for every frame, so nothing jumps while stepping
    const { min, max } = useMemo(() => {
        const points = frames.flatMap((frame) => frame.lanes.flatMap((lane) => lane.intervals.flatMap((interval) => [interval.start, interval.end])));
        const low = points.length ? Math.min(...points) : 0;
        const high = points.length ? Math.max(...points) : 10;
        return { min: low, max: high > low ? high : low + 1 };
    }, [frames]);
    const at = (value) => ((value - min) / (max - min)) * 100;
    const step = tickStep(max - min);
    const ticks = [];
    for (let value = Math.ceil(min / step) * step; value <= max; value += step) ticks.push(value);

    return (
        <Player frames={frames} code={code} title={title}>
            {(frame) => (
                <div className="space-y-4">
                    <div className="overflow-x-auto pb-1">
                        <div className="relative min-w-[420px]">
                            {frame.lanes.map((lane) => {
                                const rows = packRows(lane);
                                return (
                                    <div key={lane.label} className="flex gap-3 border-b border-line/60 py-1.5">
                                        <p className="w-20 shrink-0 pt-1.5 font-mono text-[11px] text-muted">{lane.label}</p>
                                        <ol className="relative flex-1" aria-label={lane.label}>
                                            {rows.length === 0 && <li className="flex h-7 items-center font-mono text-xs text-muted">empty</li>}
                                            {rows.map((row, index) => (
                                                <li key={index} className="relative h-7">
                                                    {row.map((interval, position) => (
                                                        <span
                                                            key={position}
                                                            aria-label={`[${interval.start}, ${interval.end}]${interval.tone ? ` ${TONE_WORDS[interval.tone]}` : ''}`}
                                                            className={`absolute top-0.5 flex h-6 min-w-1.5 items-center justify-center overflow-hidden whitespace-nowrap rounded-md border font-mono text-[10px] transition-colors ${TONES[interval.tone] ?? PLAIN}`}
                                                            style={{ left: `calc(${at(interval.start)}% + 1px)`, width: `calc(${at(interval.end) - at(interval.start)}% - 2px)` }}
                                                        >
                                                            {interval.start}–{interval.end}
                                                        </span>
                                                    ))}
                                                </li>
                                            ))}
                                        </ol>
                                    </div>
                                );
                            })}
                            <div className="flex gap-3" aria-hidden="true">
                                <span className="w-20 shrink-0" />
                                <div className="relative h-5 flex-1">
                                    {ticks.map((value) => (
                                        <span key={value} className={`absolute top-1 -translate-x-1/2 font-mono text-[10px] ${value === frame.cursor ? 'text-amber' : 'text-muted'}`} style={{ left: `${at(value)}%` }}>{value}</span>
                                    ))}
                                </div>
                            </div>
                            {frame.cursor !== undefined && (
                                <div className="pointer-events-none absolute inset-y-0 left-[5.75rem] right-0" aria-hidden="true">
                                    <span className="absolute inset-y-0 w-0.5 -translate-x-1/2 bg-amber/80" style={{ left: `${at(frame.cursor)}%` }} />
                                </div>
                            )}
                        </div>
                    </div>
                    {Object.keys(frame.vars ?? {}).length > 0 && (
                        <div className="flex flex-wrap gap-2" aria-label="Variables">
                            {Object.entries(frame.vars).map(([name, value]) => (
                                <span key={name} className="rounded-lg border border-line bg-white/[0.04] px-3 py-1.5 font-mono text-xs">
                                    <span className="text-muted">{name}</span> <span className="text-amber">{String(value)}</span>
                                </span>
                            ))}
                        </div>
                    )}
                </div>
            )}
        </Player>
    );
};

export default IntervalsView;
