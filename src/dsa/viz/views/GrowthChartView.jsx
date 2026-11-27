import { useState } from 'react';

// How fast each complexity class grows. Pick n, switch between a linear and a logarithmic scale.
const CLASSES = {
    'O(1)': { color: '#9FE6B0', f: () => 1 },
    'O(log n)': { color: '#78C2B3', f: (n) => Math.max(1, Math.log2(n)) },
    'O(n)': { color: '#5DD8FF', f: (n) => n },
    'O(n log n)': { color: '#DABAFF', f: (n) => n * Math.max(1, Math.log2(n)) },
    'O(n²)': { color: '#FDB03A', f: (n) => n * n },
    'O(2ⁿ)': { color: '#FF8170', f: (n) => 2 ** n },
    'O(n!)': { color: '#FF7AB2', f: (n) => { let total = 1; for (let i = 2; i <= n; i += 1) total *= i; return total; } },
};

const WIDTH = 640;
const HEIGHT = 300;
const PAD = { left: 56, right: 16, top: 14, bottom: 36 };

const formatCount = (value) => {
    if (value < 1000) return Number.isInteger(value) ? String(value) : value.toFixed(1);
    if (value < 1e15) return Math.round(value).toLocaleString('en-GB');
    return value.toExponential(2).replace('e+', ' × 10^');
};

// ```visual growthChart with { classes: ['O(1)', 'O(n)', …], n: 16, max: 64 }
const GrowthChartView = ({ classes = ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)', 'O(n²)', 'O(2ⁿ)'], n: initialN = 16, max = 64 }) => {
    const [n, setN] = useState(initialN);
    const [logScale, setLogScale] = useState(false);
    const shown = classes.filter((name) => CLASSES[name]);
    const xs = Array.from({ length: n }, (_, index) => index + 1);
    const top = logScale
        ? Math.max(...shown.map((name) => Math.log10(CLASSES[name].f(n)) + 0.1))
        : Math.max(...shown.filter((name) => name !== 'O(2ⁿ)' && name !== 'O(n!)').map((name) => CLASSES[name].f(n)), n);
    const toY = (value) => {
        const scaled = logScale ? Math.log10(Math.max(1, value)) : value;
        return PAD.top + (HEIGHT - PAD.top - PAD.bottom) * (1 - Math.min(scaled, top * 1.05) / (top * 1.05));
    };
    const toX = (x) => PAD.left + ((WIDTH - PAD.left - PAD.right) * (x - 1)) / Math.max(1, n - 1);

    return (
        <figure className="my-8 overflow-hidden rounded-2xl border border-line bg-surface">
            <figcaption className="border-b border-line px-4 py-2.5 font-mono text-xs text-muted">Operations needed as n grows</figcaption>
            <div className="p-4 sm:p-5">
                <div className="mb-3 flex flex-wrap items-center gap-4 text-sm text-muted">
                    <label className="flex flex-1 items-center gap-3">
                        <span className="shrink-0">n = <span className="font-mono text-paper">{n}</span></span>
                        <input type="range" min={2} max={max} value={n} onChange={(event) => setN(Number(event.target.value))} className="min-w-24 flex-1 accent-[var(--color-amber)]" aria-label="n" />
                    </label>
                    <div role="group" aria-label="Scale" className="flex rounded-full bg-white/8 p-0.5">
                        {[['Linear', false], ['Log', true]].map(([label, value]) => (
                            <button key={label} type="button" aria-pressed={logScale === value} onClick={() => setLogScale(value)} className={`h-8 rounded-full px-3 text-xs ${logScale === value ? 'bg-white/15 text-paper' : 'text-muted'}`}>{label}</button>
                        ))}
                    </div>
                </div>
                <div className="overflow-x-auto">
                    <svg viewBox={`0 0 ${WIDTH} ${HEIGHT}`} className="block w-full min-w-[480px]" role="img" aria-label="Growth of each complexity class; the table below has the numbers">
                        <line x1={PAD.left} y1={HEIGHT - PAD.bottom} x2={WIDTH - PAD.right} y2={HEIGHT - PAD.bottom} stroke="rgba(242,240,235,0.25)" />
                        <line x1={PAD.left} y1={PAD.top} x2={PAD.left} y2={HEIGHT - PAD.bottom} stroke="rgba(242,240,235,0.25)" />
                        <text x={(WIDTH + PAD.left) / 2} y={HEIGHT - 8} textAnchor="middle" fontSize="11" fill="var(--color-muted)">n (input size)</text>
                        <text x={14} y={HEIGHT / 2} textAnchor="middle" fontSize="11" fill="var(--color-muted)" transform={`rotate(-90 14 ${HEIGHT / 2})`}>{logScale ? 'operations (log scale)' : 'operations'}</text>
                        {[1, Math.ceil(n / 2), n].map((tick) => (
                            <text key={tick} x={toX(tick)} y={HEIGHT - PAD.bottom + 14} textAnchor="middle" fontSize="10" fill="var(--color-muted)">{tick}</text>
                        ))}
                        {shown.map((name) => {
                            // A curve stops where it leaves the top of the chart, instead of running flat along it
                            const limit = top * 1.05;
                            const scaled = (x) => (logScale ? Math.log10(Math.max(1, CLASSES[name].f(x))) : CLASSES[name].f(x));
                            const exit = xs.findIndex((x) => scaled(x) > limit);
                            const visible = exit === -1 ? xs : xs.slice(0, exit + 1);
                            const points = visible.map((x) => `${toX(x).toFixed(1)},${toY(CLASSES[name].f(x)).toFixed(1)}`).join(' ');
                            return <polyline key={name} points={points} fill="none" stroke={CLASSES[name].color} strokeWidth="2" strokeLinejoin="round" />;
                        })}
                    </svg>
                </div>
                <div className="mt-4 overflow-x-auto rounded-xl border border-line">
                    <table className="w-full text-left text-sm">
                        <thead className="bg-white/[0.04] font-mono text-xs text-muted">
                            <tr><th className="px-3 py-2 font-medium">Class</th><th className="px-3 py-2 font-medium">Operations at n = {n}</th></tr>
                        </thead>
                        <tbody>
                            {shown.map((name) => (
                                <tr key={name} className="border-t border-line">
                                    <td className="px-3 py-2 font-mono"><span aria-hidden="true" className="mr-2 inline-block h-2.5 w-2.5 rounded-full" style={{ background: CLASSES[name].color }} />{name}</td>
                                    <td className="px-3 py-2 font-mono">{formatCount(CLASSES[name].f(n))}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
                {!logScale && shown.some((name) => name === 'O(2ⁿ)' || name === 'O(n!)') && (
                    <p className="mt-3 text-xs text-muted">On the linear scale, O(2ⁿ) and O(n!) shoot off the top almost at once. Switch to Log to see their shape.</p>
                )}
            </div>
        </figure>
    );
};

export default GrowthChartView;
