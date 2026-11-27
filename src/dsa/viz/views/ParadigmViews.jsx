import { useMemo } from 'react';
import Player from '../Player.jsx';
import TreeDiagram from './TreeDiagram.jsx';
import { dpFrames, dpProgram } from '../algorithms/dp.js';
import { QUEENS_CODE, queensFrames, SUBSETS_CODE, subsetsFrames } from '../algorithms/backtracking.js';

const useStable = (value) => {
    const key = JSON.stringify(value ?? null);
    return useMemo(() => JSON.parse(key), [key]);
};

const hasCell = (cells, r, c) => cells.some(([row, col]) => row === r && col === c);

// ```visual dpTable with { program: lcs | editDistance | knapsack | coinChange | uniquePaths | lis, input: { … } }
export const DpTableView = ({ program = 'lcs', input }) => {
    const stableInput = useStable(input);
    const { title, code } = dpProgram(program);
    const frames = useMemo(() => dpFrames(program, stableInput ?? {}), [program, stableInput]);
    return (
        <Player frames={frames} code={code} title={title}>
            {(frame) => (
                <div className="overflow-x-auto">
                    <table className="border-separate border-spacing-1 font-mono text-xs">
                        <thead>
                            <tr>
                                <th />
                                {frame.colLabels.map((label, index) => <th key={index} className="h-6 min-w-9 px-1 text-center font-medium text-muted">{label}</th>)}
                            </tr>
                        </thead>
                        <tbody>
                            {frame.table.map((row, r) => (
                                <tr key={r}>
                                    <th className="whitespace-nowrap pr-2 text-right font-medium text-muted">{frame.rowLabels[r]}</th>
                                    {row.map((value, c) => {
                                        const current = frame.current && frame.current[0] === r && frame.current[1] === c;
                                        const tone = current ? 'border-amber bg-amber/25 text-amber'
                                            : hasCell(frame.path, r, c) ? 'border-[#30D158] bg-[#30D158]/20 text-[#30D158]'
                                                : hasCell(frame.deps, r, c) ? 'border-sky-400 bg-sky-400/15 text-sky-300'
                                                    : value === null ? 'border-dashed border-line text-transparent' : 'border-line';
                                        return <td key={c} className={`h-9 min-w-9 rounded-md border px-1 text-center ${tone}`}>{value ?? '·'}</td>;
                                    })}
                                </tr>
                            ))}
                        </tbody>
                    </table>
                    <p className="mt-2 text-xs text-muted"><span className="text-amber">■</span> the cell being filled · <span className="text-sky-300">■</span> the cells it depends on</p>
                </div>
            )}
        </Player>
    );
};

// ```visual nQueens with { n: 4, all: false }
export const QueensView = ({ n = 4, all = false }) => {
    const frames = useMemo(() => queensFrames({ n, all }), [n, all]);
    return (
        <Player frames={frames} code={QUEENS_CODE} title={`${n} queens by backtracking`}>
            {(frame) => (
                <div className="flex flex-wrap items-start gap-6">
                    <div className="inline-grid gap-0.5 rounded-lg border border-line p-1" style={{ gridTemplateColumns: `repeat(${frame.n}, 2.5rem)` }} role="img" aria-label={`Board with queens in columns ${frame.queens.join(', ') || 'none'}`}>
                        {Array.from({ length: frame.n * frame.n }, (_, index) => {
                            const r = Math.floor(index / frame.n);
                            const c = index % frame.n;
                            const queen = frame.queens[r] === c;
                            const trying = frame.trying && frame.trying[0] === r && frame.trying[1] === c;
                            const attacker = hasCell(frame.attackers, r, c);
                            const tone = trying ? 'bg-[#FF9D96]/25 text-[#FF9D96]' : attacker ? 'bg-amber/25 text-amber' : queen ? 'bg-[#30D158]/20 text-[#30D158]' : (r + c) % 2 ? 'bg-white/[0.07]' : 'bg-white/[0.02]';
                            return <span key={index} className={`flex h-10 w-10 items-center justify-center rounded text-lg ${tone}`}>{queen ? '♛' : trying ? '×' : ''}</span>;
                        })}
                    </div>
                    <p className="font-mono text-xs text-muted">solutions found: <span className="text-paper">{frame.solutions}</span></p>
                </div>
            )}
        </Player>
    );
};

// ```visual subsetsTree with { items: [1, 2, 3] }
export const SubsetsTreeView = ({ items }) => {
    const stableItems = useStable(items);
    const frames = useMemo(() => subsetsFrames(stableItems ? { items: stableItems } : {}), [stableItems]);
    return (
        <Player frames={frames} code={SUBSETS_CODE} title="The decision tree behind subsets: in or out, item by item">
            {(frame) => (
                <div>
                    <TreeDiagram
                        tree={{ root: frame.root, nodes: frame.nodes }}
                        marks={Object.fromEntries(frame.path.map((id) => [id, 'path']))}
                        childrenOf={(id) => frame.nodes[id].children}
                        nodeLabel={(node) => node.value}
                        badge={(node) => node.leaf}
                        label="Decision tree; green dots mark recorded subsets"
                    />
                    <p className="mt-3 font-mono text-xs text-muted">recorded: <span className="text-amber">{frame.results.map((subset) => `[${subset.join(',')}]`).join(' ') || '—'}</span></p>
                </div>
            )}
        </Player>
    );
};
