import { useMemo } from 'react';
import Player from '../Player.jsx';
import { hashTableFrames } from '../algorithms/hashTable.js';

// ```visual hashTable with { mode: chaining | probing, keys: […], size: 7 }
const HashTableView = ({ mode = 'chaining', keys = [10, 3, 17, 24, 5, 12], size = 7 }) => {
    const keysKey = JSON.stringify(keys);
    const frames = useMemo(() => hashTableFrames(mode, JSON.parse(keysKey), size), [mode, keysKey, size]);
    return (
        <Player frames={frames} title={mode === 'chaining' ? 'Hash table with separate chaining' : 'Hash table with linear probing'}>
            {(frame) => (
                <div className="overflow-x-auto">
                    {frame.key !== undefined && <p className="mb-3 font-mono text-sm">Inserting <span className="text-amber">{String(frame.key)}</span></p>}
                    {mode === 'chaining' ? (
                        <ol className="space-y-1.5" aria-label="Buckets">
                            {frame.buckets.map((bucket, index) => (
                                <li key={index} className="flex items-center gap-2">
                                    <span className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border font-mono text-xs ${index === frame.active ? 'border-amber bg-amber/20 text-amber' : 'border-line text-muted'}`}>{index}</span>
                                    {bucket.map((key, at) => (
                                        <span key={at} className="flex items-center gap-2">
                                            <span aria-hidden="true" className="text-muted">→</span>
                                            <span className={`rounded-lg border px-2.5 py-1.5 font-mono text-sm ${index === frame.active && at === bucket.length - 1 ? 'border-amber text-amber' : 'border-line'}`}>{String(key)}</span>
                                        </span>
                                    ))}
                                </li>
                            ))}
                        </ol>
                    ) : (
                        <ol className="flex min-w-max gap-1.5" aria-label="Slots">
                            {frame.slots.map((key, index) => {
                                const tone = index === frame.active ? 'border-amber bg-amber/20 text-amber' : frame.probed?.includes(index) ? 'border-[#FF9D96]/70 bg-[#FF9D96]/10' : key === null ? 'border-dashed border-line' : 'border-line';
                                return (
                                    <li key={index} className="flex w-12 flex-col items-center gap-1">
                                        <span className={`flex h-12 w-12 items-center justify-center rounded-lg border font-mono text-sm ${tone}`}>{key === null ? '' : String(key)}</span>
                                        <span className="font-mono text-[10px] text-muted">{index}</span>
                                    </li>
                                );
                            })}
                        </ol>
                    )}
                </div>
            )}
        </Player>
    );
};

export default HashTableView;
