import { useMemo } from 'react';
import Player from '../Player.jsx';
import TreeDiagram from './TreeDiagram.jsx';
import { dpFrames, dpProgram } from '../algorithms/dp.js';
import { HUFFMAN_CODE, huffmanFrames } from '../algorithms/huffman.js';
import { COMBINATION_SUM_CODE, combinationSumFrames, PERMUTATIONS_CODE, permutationsFrames, QUEENS_CODE, queensFrames, SUBSETS_CODE, subsetsFrames } from '../algorithms/backtracking.js';

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
const DECISION_TREES = {
    subsets: { code: SUBSETS_CODE, title: 'The decision tree behind subsets: in or out, item by item', frames: (props) => subsetsFrames(props.items ? { items: props.items } : {}) },
    permutations: { code: PERMUTATIONS_CODE, title: 'The decision tree behind permutations: choose, explore, unchoose', frames: (props) => permutationsFrames(props.items ? { items: props.items } : {}) },
    combinationSum: { code: COMBINATION_SUM_CODE, title: 'Combination sum: reuse allowed, with pruning', frames: (props) => combinationSumFrames({ ...(props.items ? { candidates: props.items } : {}), ...(props.target !== undefined ? { target: props.target } : {}) }) },
};

export const SubsetsTreeView = ({ program = 'subsets', items, target }) => {
    const props = useStable({ items, target });
    const spec = DECISION_TREES[program] ?? DECISION_TREES.subsets;
    const frames = useMemo(() => spec.frames(props), [spec, props]);
    return (
        <Player frames={frames} code={spec.code} title={spec.title}>
            {(frame) => (
                <div>
                    <TreeDiagram
                        tree={{ root: frame.root, nodes: frame.nodes }}
                        marks={{ ...Object.fromEntries(Object.entries(frame.nodes).filter(([, node]) => node.pruned).map(([id]) => [id, 'out'])), ...Object.fromEntries(frame.path.map((id) => [id, 'path'])) }}
                        childrenOf={(id) => frame.nodes[id].children}
                        nodeLabel={(node) => node.value}
                        badge={(node) => node.leaf}
                        label="Decision tree; green dots mark recorded answers, red nodes were pruned"
                    />
                    <p className="mt-3 font-mono text-xs text-muted">recorded: <span className="text-amber">{frame.results.map((answer) => `[${answer.join(',')}]`).join(' ') || '—'}</span></p>
                </div>
            )}
        </Player>
    );
};

// ```visual huffman with { frequencies: { a: 5, b: 9, … } }
export const HuffmanView = ({ frequencies }) => {
    const stable = useStable(frequencies);
    const frames = useMemo(() => huffmanFrames(stable ? { frequencies: stable } : {}), [stable]);
    return (
        <Player frames={frames} code={HUFFMAN_CODE} title="Huffman coding: always merge the two lightest trees">
            {(frame) => (
                <div className="space-y-3">
                    <div className="flex flex-wrap items-end gap-x-3 gap-y-2">
                        {frame.forest.map((tree) => (
                            <div key={tree.root} className="rounded-xl border border-line/60 px-1 pt-1">
                                <TreeDiagram tree={tree} marks={frame.marks} label={`Tree weighing ${tree.nodes[tree.root].weight}`} />
                            </div>
                        ))}
                    </div>
                    {frame.codes && (
                        <table className="font-mono text-xs">
                            <thead><tr className="text-muted"><th className="pr-4 text-left font-medium">symbol</th><th className="pr-4 text-left font-medium">count</th><th className="text-left font-medium">code</th></tr></thead>
                            <tbody>
                                {frame.codes.map(({ symbol, weight, code }) => (
                                    <tr key={symbol}><td className="pr-4">{symbol}</td><td className="pr-4">{weight}</td><td className="text-amber">{code}</td></tr>
                                ))}
                            </tbody>
                        </table>
                    )}
                </div>
            )}
        </Player>
    );
};
