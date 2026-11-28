import { useMemo } from 'react';
import Player from '../Player.jsx';
import { matrixFrames, matrixProgram } from '../algorithms/matrix.js';

const TONES = {
    current: 'border-amber bg-amber/20 text-amber',
    swap: 'border-amber bg-amber/20 text-amber',
    done: 'border-line bg-white/[0.03] text-muted',
    kept: 'border-[#30D158]/60 bg-[#30D158]/10 text-[#30D158]',
    near: 'border-sky-400/80',
    pending: 'border-line opacity-30',
};
const ALIVE = 'bg-[#30D158]/70';

const Grid = ({ grid }) => {
    const { bounds } = grid;
    const inside = (r, c) => bounds && r >= bounds.top && r <= bounds.bottom && c >= bounds.left && c <= bounds.right;
    const life = grid.cellsAre === 'life';
    const size = life ? 'h-8 w-8' : 'h-10 w-10';
    return (
        <div>
            <p className="mb-1.5 font-mono text-[11px] text-muted">{grid.label}</p>
            <table className="border-separate border-spacing-1" aria-label={grid.label}>
                <tbody>
                    {grid.cells.map((row, r) => (
                        <tr key={r}>
                            {row.map((value, c) => {
                                const mark = grid.marks[`${r},${c}`];
                                const shaded = !mark && inside(r, c) ? 'border-sky-400/50 bg-sky-400/10' : '';
                                const tone = TONES[mark] ?? (shaded || 'border-line');
                                const step = grid.order?.[`${r},${c}`];
                                return (
                                    <td key={c} className="p-0">
                                        <span
                                            aria-label={life ? `(${r}, ${c}) ${value ? 'alive' : 'dead'}` : undefined}
                                            className={`relative flex ${size} items-center justify-center rounded-md border font-mono text-sm transition-colors ${tone} ${life && value ? ALIVE : ''}`}
                                        >
                                            {!life && value}
                                            {step !== undefined && <span className="absolute right-0.5 top-0 text-[9px] leading-tight text-muted">{step}</span>}
                                        </span>
                                    </td>
                                );
                            })}
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
};

// ```visual matrix with { program, input: { … } }
const MatrixView = ({ program = 'spiral', input = {} }) => {
    const { title, code } = matrixProgram(program);
    const inputKey = JSON.stringify(input);
    const frames = useMemo(() => matrixFrames(program, JSON.parse(inputKey)), [program, inputKey]);

    return (
        <Player frames={frames} code={code} title={title}>
            {(frame) => (
                <div className="space-y-4">
                    <div className="flex flex-wrap gap-6 overflow-x-auto pb-1">
                        {frame.grids.map((grid) => <Grid key={grid.label} grid={grid} />)}
                    </div>
                    {frame.output && (
                        <div>
                            <p className="mb-1.5 font-mono text-[11px] uppercase tracking-wider text-muted">Result</p>
                            <p className="min-h-5 break-words font-mono text-sm">{frame.output.length ? frame.output.join(' ') : <span className="text-muted">empty</span>}</p>
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

export default MatrixView;
