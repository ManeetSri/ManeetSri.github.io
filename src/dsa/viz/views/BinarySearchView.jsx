import { useMemo, useState } from 'react';
import Player from '../Player.jsx';
import { BINARY_SEARCH_SWIFT, binarySearchFrames } from '../algorithms/binarySearch.js';

const DEFAULT_ITEMS = [3, 8, 12, 17, 21, 26, 30, 34, 41, 45, 52];

const cellTone = (index, frame) => {
    if (frame.found === index) return 'border-[#30D158] bg-[#30D158]/20 text-[#30D158]';
    if (frame.mid === index) return 'border-amber bg-amber/20 text-amber';
    const inRange = frame.low !== null && index >= frame.low && index <= frame.high;
    return inRange ? 'border-white/25 bg-white/[0.06]' : 'border-line opacity-35';
};

// ```visual binarySearch with optional { items, target }
const BinarySearchView = ({ items = DEFAULT_ITEMS, target: initialTarget = 34 }) => {
    const [target, setTarget] = useState(initialTarget);
    const frames = useMemo(() => binarySearchFrames(items, target), [items, target]);

    return (
        <div>
            <label className="mb-3 flex flex-wrap items-center gap-2 text-sm text-muted">
                Look for
                <select value={target} onChange={(event) => setTarget(Number(event.target.value))} className="h-9 rounded-lg border border-line bg-raised px-2 font-mono text-paper">
                    {[...items, 0, 25, 60].sort((a, b) => a - b).map((value) => <option key={value} value={value}>{value}{items.includes(value) ? '' : ' (missing)'}</option>)}
                </select>
            </label>
            <Player key={target} frames={frames} code={BINARY_SEARCH_SWIFT} title="Binary search on a sorted array">
                {(frame) => (
                    <div className="overflow-x-auto pb-1">
                        <ol className="flex min-w-max gap-1.5" aria-label="Array">
                            {items.map((value, index) => (
                                <li key={index} className="flex w-11 flex-col items-center gap-1">
                                    <span className={`flex h-11 w-11 items-center justify-center rounded-lg border font-mono text-sm transition-colors ${cellTone(index, frame)}`}>{value}</span>
                                    <span className="font-mono text-[10px] text-muted">{index}</span>
                                    <span className="flex h-4 gap-0.5 font-mono text-[10px] font-semibold">
                                        {frame.low === index && <span className="text-sky-300">lo</span>}
                                        {frame.mid === index && <span className="text-amber">mid</span>}
                                        {frame.high === index && <span className="text-violet-300">hi</span>}
                                    </span>
                                </li>
                            ))}
                        </ol>
                    </div>
                )}
            </Player>
        </div>
    );
};

export default BinarySearchView;
