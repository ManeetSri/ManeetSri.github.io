import { useMemo } from 'react';
import Player from '../Player.jsx';
import { arrayFrames, arrayProgram } from '../algorithms/arrayPrograms.js';

const MARK_TONES = {
    swap: 'border-amber bg-amber/20 text-amber',
    found: 'border-[#30D158] bg-[#30D158]/20 text-[#30D158]',
    out: 'border-[#FF9D96]/70 bg-[#FF9D96]/10 text-[#FF9D96]',
};
const RANGE_TONES = {
    window: 'border-sky-400/70 bg-sky-400/10',
    kept: 'border-[#30D158]/50 bg-[#30D158]/[0.07]',
};
const POINTER_COLOURS = ['text-sky-300', 'text-amber', 'text-violet-300', 'text-[#FF9D96]'];

const ArrayRow = ({ row }) => {
    const pointerNames = Object.keys(row.pointers);
    return (
        <div>
            <p className="mb-1.5 font-mono text-[11px] text-muted">{row.label}</p>
            <ol className="flex min-w-max gap-1.5">
                {row.values.map((value, index) => {
                    const inRange = row.range && index >= row.range.from && index <= row.range.to;
                    const tone = row.marks[index] ? MARK_TONES[row.marks[index]] : inRange ? RANGE_TONES[row.range.tone] ?? RANGE_TONES.window : value === null ? 'border-dashed border-line' : 'border-line';
                    const here = pointerNames.filter((name) => row.pointers[name] === index);
                    return (
                        <li key={index} className="flex w-11 flex-col items-center gap-1">
                            <span className={`flex h-11 w-11 items-center justify-center rounded-lg border font-mono text-sm transition-colors ${tone}`}>{value === null ? '' : String(value)}</span>
                            <span className="font-mono text-[10px] text-muted">{index}</span>
                            <span className="flex min-h-4 flex-col items-center font-mono text-[10px] font-semibold leading-tight">
                                {here.map((name) => <span key={name} className={POINTER_COLOURS[pointerNames.indexOf(name) % POINTER_COLOURS.length]}>{name}</span>)}
                            </span>
                        </li>
                    );
                })}
            </ol>
        </div>
    );
};

// ```visual arrayTrace with { program, input: { … } }
const ArrayTraceView = ({ program = 'reverse', input = {} }) => {
    const { title, code } = arrayProgram(program);
    const inputKey = JSON.stringify(input);
    const frames = useMemo(() => arrayFrames(program, JSON.parse(inputKey)), [program, inputKey]);

    return (
        <Player frames={frames} code={code} title={title}>
            {(frame) => (
                <div className="space-y-4">
                    <div className="space-y-4 overflow-x-auto pb-1">
                        {frame.rows.map((row) => <ArrayRow key={row.label} row={row} />)}
                    </div>
                    {frame.stack && (
                        <div>
                            <p className="mb-1.5 font-mono text-[11px] uppercase tracking-wider text-muted">Stack (top first)</p>
                            <ol className="flex flex-col-reverse gap-1" aria-label="Stack">
                                {frame.stack.length === 0 && <li className="font-mono text-xs text-muted">empty</li>}
                                {frame.stack.map((label, index) => (
                                    <li key={`${label}-${index}`} className={`w-fit rounded-md border px-2.5 py-1 font-mono text-xs ${index === frame.stack.length - 1 ? 'border-amber bg-amber/15 text-amber' : 'border-line'}`}>{label}</li>
                                ))}
                            </ol>
                        </div>
                    )}
                    {frame.list && (
                        <div>
                            <p className="mb-1.5 font-mono text-[11px] uppercase tracking-wider text-muted">{frame.list.title}</p>
                            <ol className="flex flex-wrap gap-1" aria-label={frame.list.title}>
                                {frame.list.items.length === 0 && <li className="font-mono text-xs text-muted">empty</li>}
                                {frame.list.items.map((label, index) => (
                                    <li key={`${label}-${index}`} className={`rounded-md border px-2.5 py-1 font-mono text-xs ${index === 0 ? 'border-[#30D158] bg-[#30D158]/15 text-[#30D158]' : 'border-line'}`}>{label}</li>
                                ))}
                            </ol>
                        </div>
                    )}
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

export default ArrayTraceView;
