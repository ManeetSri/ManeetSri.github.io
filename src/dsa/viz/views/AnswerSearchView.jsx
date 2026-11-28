import { useMemo } from 'react';
import Player from '../Player.jsx';
import { answerSearchFrames, answerSearchProgram } from '../algorithms/answerSearch.js';

const FAILS = 'border-[#FF9D96]/60 bg-[#FF9D96]/15 text-[#FF9D96]';
const WORKS = 'border-[#30D158]/60 bg-[#30D158]/15 text-[#30D158]';
const UNKNOWN = 'border-line text-paper';
const POINTERS = { low: 'text-sky-300', mid: 'text-amber', high: 'text-violet-300' };
// Ranges up to this size draw one cell per candidate; bigger ones draw a proportional bar
const MAX_CELLS = 24;

const toneOf = (value, frame) => (value < frame.low ? FAILS : value >= frame.high ? WORKS : UNKNOWN);
const pointersAt = (value, frame) => ['low', 'mid', 'high'].filter((name) => frame[name] === value && !(name === 'mid' && frame.answer !== undefined));

const Cells = ({ frame }) => {
    const values = Array.from({ length: frame.range.max - frame.range.min + 1 }, (_, index) => frame.range.min + index);
    return (
        <ol className="flex min-w-max gap-1" aria-label="Candidate answers">
            {values.map((value) => (
                <li key={value} className="flex w-8 flex-col items-center gap-1">
                    <span className={`flex h-9 w-8 items-center justify-center rounded-md border font-mono text-xs transition-colors ${value === frame.mid && frame.answer === undefined ? 'ring-2 ring-amber' : ''} ${value === frame.answer ? 'ring-2 ring-[#30D158]' : ''} ${toneOf(value, frame)}`}>{value}</span>
                    <span className="flex min-h-4 flex-col items-center font-mono text-[10px] font-semibold leading-tight">
                        {pointersAt(value, frame).map((name) => <span key={name} className={POINTERS[name]}>{name}</span>)}
                    </span>
                </li>
            ))}
        </ol>
    );
};

const Bar = ({ frame }) => {
    const { min, max } = frame.range;
    const count = max - min + 1;
    const left = (value) => ((value - min) / count) * 100;
    const centre = (value) => ((value - min + 0.5) / count) * 100;
    const markers = ['low', 'mid', 'high'].filter((name) => frame[name] !== undefined && !(name === 'mid' && frame.answer !== undefined));
    return (
        <div className="min-w-[420px] px-2" aria-label={`Candidates ${min} to ${max}: below ${frame.low} fail, from ${frame.high} up work`}>
            <div className="relative h-9 overflow-hidden rounded-md border border-line">
                <span className={`absolute inset-y-0 left-0 border-r ${FAILS}`} style={{ width: `${left(frame.low)}%` }} />
                <span className={`absolute inset-y-0 right-0 border-l ${WORKS}`} style={{ left: `${left(frame.high)}%` }} />
                {frame.mid !== undefined && frame.answer === undefined && <span className="absolute inset-y-0 w-0.5 -translate-x-1/2 bg-amber" style={{ left: `${centre(frame.mid)}%` }} />}
            </div>
            <div className="relative mt-1 h-9 font-mono text-[10px]">
                <span className="absolute left-0 text-muted">{min}</span>
                <span className="absolute right-0 text-muted">{max}</span>
                {markers.map((name, index) => (
                    <span key={name} className={`absolute -translate-x-1/2 whitespace-nowrap font-semibold ${POINTERS[name]}`} style={{ left: `${centre(frame[name])}%`, top: `${(index % 2) * 14 + 12}px` }}>{name} {frame[name]}</span>
                ))}
            </div>
        </div>
    );
};

// ```visual answerSearch with { program: speed | capacity, input: { … } }
const AnswerSearchView = ({ program = 'speed', input = {} }) => {
    const { title, code } = answerSearchProgram(program);
    const inputKey = JSON.stringify(input);
    const frames = useMemo(() => answerSearchFrames(program, JSON.parse(inputKey)), [program, inputKey]);
    const small = frames[0].range.max - frames[0].range.min + 1 <= MAX_CELLS;

    return (
        <Player frames={frames} code={code} title={title}>
            {(frame) => (
                <div className="space-y-4">
                    <div className="overflow-x-auto pb-1">{small ? <Cells frame={frame} /> : <Bar frame={frame} />}</div>
                    <p className="flex flex-wrap gap-x-4 gap-y-1 text-xs text-muted">
                        <span><span className="mr-1 inline-block h-2.5 w-2.5 rounded-sm bg-[#FF9D96]/60 align-middle" />known to fail</span>
                        <span><span className="mr-1 inline-block h-2.5 w-2.5 rounded-sm bg-[#30D158]/60 align-middle" />known to work</span>
                    </p>
                    {frame.check && (
                        <div>
                            <p className="mb-1.5 font-mono text-[11px] uppercase tracking-wider text-muted">Check for {frame.mid}</p>
                            <ul className="flex flex-wrap gap-1.5">
                                {frame.check.groups.map((group, index) => (
                                    <li key={index} className="rounded-lg border border-line bg-white/[0.04] px-2.5 py-1.5 font-mono text-xs">
                                        <span className="text-muted">{group.label}</span> <span>{group.detail}</span> <span className="text-muted">=</span> <span className="text-amber">{group.value}</span>
                                    </li>
                                ))}
                            </ul>
                            <p className={`mt-2 font-mono text-xs ${frame.check.ok ? 'text-[#30D158]' : 'text-[#FF9D96]'}`}>
                                {frame.check.kind}: {frame.check.total} {frame.check.ok ? '≤' : '>'} {frame.check.limit}
                            </p>
                        </div>
                    )}
                    <div className="flex flex-wrap gap-2" aria-label="Variables">
                        {Object.entries(frame.vars).map(([name, value]) => (
                            <span key={name} className="rounded-lg border border-line bg-white/[0.04] px-3 py-1.5 font-mono text-xs">
                                <span className="text-muted">{name}</span> <span className="text-amber">{String(value)}</span>
                            </span>
                        ))}
                    </div>
                </div>
            )}
        </Player>
    );
};

export default AnswerSearchView;
