import { useMemo } from 'react';
import Player from '../Player.jsx';
import TreeDiagram from './TreeDiagram.jsx';
import { FENWICK_CODE, fenwickFrames, SEGMENT_CODE, segmentFrames } from '../algorithms/rangeTrees.js';
import { useStable } from '../useStable.js';

const ItemsRow = ({ items, range, label = 'items', offset = 0 }) => (
    <div className="overflow-x-auto">
        <p className="mb-1 font-mono text-[11px] text-muted">{label}</p>
        <ol className="flex min-w-max gap-1">
            {items.map((value, index) => {
                const inRange = range && index >= range[0] && index <= range[1];
                return (
                    <li key={index} className="flex w-10 flex-col items-center gap-0.5">
                        <span className={`flex h-9 w-10 items-center justify-center rounded-md border font-mono text-sm ${inRange ? 'border-sky-400 bg-sky-400/10' : 'border-line'}`}>{value}</span>
                        <span className="font-mono text-[10px] text-muted">{index + offset}</span>
                    </li>
                );
            })}
        </ol>
    </div>
);

// ```visual segmentTree with { items: [...], operations: [["query", 2, 6], ["update", 3, 1]] }
export const SegmentTreeView = ({ items, operations }) => {
    const stableItems = useStable(items);
    const stableOps = useStable(operations);
    const frames = useMemo(() => segmentFrames({ ...(stableItems ? { items: stableItems } : {}), ...(stableOps ? { operations: stableOps } : {}) }), [stableItems, stableOps]);
    return (
        <Player frames={frames} code={SEGMENT_CODE} title="A segment tree of range sums">
            {(frame) => (
                <div className="space-y-4">
                    <TreeDiagram tree={frame.tree} marks={frame.marks} label="Segment tree; each node sums the range shown beside it" />
                    <ItemsRow items={frame.items} range={frame.range} />
                </div>
            )}
        </Player>
    );
};

// ```visual fenwick with { items: [...], query: 7, update: [3, 2] }
export const FenwickView = ({ items, query, update }) => {
    const stableItems = useStable(items);
    const stableUpdate = useStable(update);
    const frames = useMemo(() => fenwickFrames({ ...(stableItems ? { items: stableItems } : {}), ...(query ? { query } : {}), ...(stableUpdate ? { update: stableUpdate } : {}) }), [stableItems, query, stableUpdate]);
    return (
        <Player frames={frames} code={FENWICK_CODE} title="A Fenwick tree (binary indexed tree)">
            {(frame) => (
                <div className="overflow-x-auto">
                    <ol className="flex min-w-max gap-1" aria-label="Fenwick tree entries">
                        {frame.tree.slice(1).map((value, index) => {
                            const i = index + 1;
                            const tone = frame.marks[i] === 'found' ? 'border-[#30D158] bg-[#30D158]/20 text-[#30D158]' : frame.marks[i] === 'path' ? 'border-amber bg-amber/20 text-amber' : frame.marks[i] === 'swap' ? 'border-sky-400 bg-sky-400/15 text-sky-300' : 'border-line';
                            const [from, to] = frame.ranges[i];
                            return (
                                <li key={i} className="flex w-12 flex-col items-center gap-0.5">
                                    <span className={`flex h-10 w-12 items-center justify-center rounded-md border font-mono text-sm ${tone}`}>{value}</span>
                                    <span className="font-mono text-[10px] text-muted">{i}</span>
                                    <span className="font-mono text-[9px] text-muted">{from === to ? from : `${from}–${to}`}</span>
                                    <span className="mt-0.5 h-1 rounded-full bg-white/15" style={{ width: `${(to - from + 1) * 6}px` }} aria-hidden="true" />
                                </li>
                            );
                        })}
                    </ol>
                    <p className="mt-2 text-xs text-muted">Under each entry: its index, and the items it’s responsible for.</p>
                </div>
            )}
        </Player>
    );
};
