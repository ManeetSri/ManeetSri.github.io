import { useMemo } from 'react';
import Player from '../Player.jsx';
import TreeDiagram from './TreeDiagram.jsx';
import { UNION_FIND_CODE, unionFindFrames } from '../algorithms/unionFind.js';

const CELL_TONES = {
    found: 'border-[#30D158] bg-[#30D158]/20 text-[#30D158]',
    path: 'border-amber/70 bg-amber/10 text-amber',
    swap: 'border-amber bg-amber/25 text-amber',
};

// ```visual unionFind with { count: 7, operations: ["union 0 1", "find 1", "connected 0 1"] }
const UnionFindView = ({ count, operations }) => {
    const inputKey = JSON.stringify({ count, operations });
    const frames = useMemo(() => {
        const input = JSON.parse(inputKey);
        return unionFindFrames({ ...(input.count ? { count: input.count } : {}), ...(input.operations ? { operations: input.operations } : {}) });
    }, [inputKey]);

    return (
        <Player frames={frames} code={UNION_FIND_CODE} title="Union-find with path compression and union by size">
            {(frame) => {
                const nodes = Object.fromEntries(frame.parent.map((_, index) => [index, { value: index }]));
                const roots = frame.parent.flatMap((parent, index) => (parent === index ? [index] : []));
                const childrenOf = (id) => frame.parent.flatMap((parent, index) => (parent === Number(id) && index !== Number(id) ? [index] : []));
                return (
                    <div className="space-y-4">
                        <div className="overflow-x-auto pb-1">
                            <p className="mb-1.5 font-mono text-[11px] text-muted">parent</p>
                            <ol className="flex min-w-max gap-1.5" aria-label="Parent array">
                                {frame.parent.map((parent, index) => (
                                    <li key={index} className="flex w-10 flex-col items-center gap-1">
                                        <span className={`flex h-10 w-10 items-center justify-center rounded-lg border font-mono text-sm transition-colors ${CELL_TONES[frame.marks[index]] ?? (parent === index ? 'border-line bg-white/[0.06]' : 'border-line')}`}>{parent}</span>
                                        <span className="font-mono text-[10px] text-muted">{index}</span>
                                    </li>
                                ))}
                            </ol>
                        </div>
                        <div>
                            <p className="mb-1.5 font-mono text-[11px] text-muted">sets as trees (each root is its own parent) · size beside each root</p>
                            <div className="flex flex-wrap items-start gap-x-2 gap-y-3">
                                {roots.map((root) => (
                                    <div key={root} className="rounded-xl border border-line/60 px-1 pt-1">
                                        <TreeDiagram tree={{ root, nodes: { ...nodes, [root]: { value: root, note: frame.size[root] } } }} marks={frame.marks} childrenOf={childrenOf} label={`Set rooted at ${root}`} plainNotes />
                                    </div>
                                ))}
                            </div>
                        </div>
                        <div className="flex flex-wrap gap-2 font-mono text-xs" aria-label="Variables">
                            <span className="rounded-lg border border-line bg-white/[0.04] px-3 py-1.5"><span className="text-muted">sets</span> <span className="text-amber">{frame.components}</span></span>
                            {frame.result && <span className="rounded-lg border border-line bg-white/[0.04] px-3 py-1.5 text-amber">{frame.result}</span>}
                        </div>
                    </div>
                );
            }}
        </Player>
    );
};

export default UnionFindView;
