import { useId, useMemo, useState } from 'react';
import { RotateCcw } from 'lucide-react';
import { compileEstimator, logSteps, positionOf, valueAt } from '../estimator.js';
import { formatValue, withUnit } from '../format.js';

// Input values: grouped digits, or 3.2M once they get long
const showInput = (value, unit) => withUnit(formatValue(value, Math.abs(value) >= 1e6 ? 'si' : 'number'), unit);

// ```visual estimator with { inputs: [{ id, label, min, max, step?, value, unit?, scale? }], outputs: [{ id, label, formula, unit?, format? }] }
const EstimatorView = ({ title = 'Back-of-the-envelope estimate', inputs, outputs }) => {
    const id = useId();
    const inputKey = JSON.stringify({ inputs, outputs });
    const spec = useMemo(() => JSON.parse(inputKey), [inputKey]);
    const initial = useMemo(() => Object.fromEntries(spec.inputs.map((input) => [input.id, input.value])), [spec]);
    // Log sliders also remember their position, since several positions can round to one value
    const [{ values, positions }, setState] = useState({ values: initial, positions: {} });
    const work = useMemo(() => compileEstimator(spec.outputs), [spec]);
    const results = work(values);
    const changed = spec.inputs.some((input) => values[input.id] !== initial[input.id]);

    return (
        <section aria-labelledby={`${id}-title`} className="my-8 overflow-hidden rounded-2xl border border-line bg-surface">
            <div className="flex items-center justify-between gap-3 border-b border-line px-4 py-2">
                <h3 id={`${id}-title`} className="font-mono text-xs font-normal text-muted">{title}</h3>
                <button type="button" onClick={() => setState({ values: initial, positions: {} })} disabled={!changed} className="flex h-8 items-center gap-1.5 rounded-full bg-white/8 px-3 font-mono text-xs text-muted hover:text-paper disabled:opacity-30">
                    <RotateCcw size={13} aria-hidden="true" /> Reset
                </button>
            </div>
            <div className="space-y-5 p-4 sm:p-5">
                <div className="grid gap-x-6 gap-y-4 sm:grid-cols-2">
                    {spec.inputs.map((input) => {
                        const value = values[input.id];
                        const shown = showInput(value, input.unit);
                        const log = input.scale === 'log';
                        return (
                            <div key={input.id}>
                                <div className="mb-1 flex items-baseline justify-between gap-3">
                                    <label htmlFor={`${id}-${input.id}`} className="text-sm text-paper">{input.label}</label>
                                    <span className="shrink-0 font-mono text-sm text-amber" aria-hidden="true">{shown}</span>
                                </div>
                                <input
                                    id={`${id}-${input.id}`}
                                    type="range"
                                    min={log ? 0 : input.min}
                                    max={log ? logSteps(input) : input.max}
                                    step={log ? 1 : (input.step ?? 'any')}
                                    value={positions[input.id] ?? positionOf(input, value)}
                                    aria-valuetext={shown}
                                    onChange={(event) => {
                                        const position = Number(event.target.value);
                                        setState((current) => ({
                                            values: { ...current.values, [input.id]: valueAt(input, position) },
                                            positions: log ? { ...current.positions, [input.id]: position } : current.positions,
                                        }));
                                    }}
                                    className="w-full accent-[var(--color-amber)]"
                                />
                                <div className="flex justify-between font-mono text-[10px] text-muted" aria-hidden="true">
                                    <span>{showInput(input.min, input.unit)}</span>
                                    <span>{log ? 'log scale' : ''}</span>
                                    <span>{showInput(input.max, input.unit)}</span>
                                </div>
                            </div>
                        );
                    })}
                </div>
                <dl className="grid gap-2 sm:grid-cols-2">
                    {spec.outputs.map((output, index) => (
                        <div key={output.id} className="min-w-0 rounded-xl border border-line bg-white/[0.03] px-3 py-2.5">
                            <dt className="text-xs text-muted">{output.label}</dt>
                            <dd className="mt-0.5 font-mono text-lg text-paper">
                                <output htmlFor={spec.inputs.map((input) => `${id}-${input.id}`).join(' ')}>{withUnit(formatValue(results[index].value, output.format), output.unit)}</output>
                            </dd>
                            <dd className="mt-1 break-words font-mono text-[11px] leading-snug text-muted">= {String(output.formula)}</dd>
                        </div>
                    ))}
                </dl>
            </div>
        </section>
    );
};

export default EstimatorView;
