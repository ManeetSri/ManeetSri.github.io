import { useMemo } from 'react';
import Player from '../Player.jsx';
import { stackQueueFrames, stackQueueTitle } from '../algorithms/stackQueue.js';

const Cell = ({ value, highlight }) => (
    <span className={`flex h-11 min-w-11 items-center justify-center rounded-lg border px-2 font-mono text-sm ${highlight ? 'border-amber bg-amber/20 text-amber' : 'border-line bg-white/[0.04]'}`}>{value}</span>
);

// ```visual stackQueue with { kind: stack | queue | deque, operations: ["push 3", "pop", …] }
const StackQueueView = ({ kind = 'stack', operations }) => {
    const opsKey = JSON.stringify(operations ?? null);
    const frames = useMemo(() => stackQueueFrames(kind, JSON.parse(opsKey) ?? undefined), [kind, opsKey]);
    return (
        <Player frames={frames} title={stackQueueTitle(kind)}>
            {(frame) => (
                <div className="flex min-h-48 flex-wrap items-end gap-8">
                    <div>
                        <p className="mb-2 font-mono text-[11px] uppercase tracking-wider text-muted">{frame.operation ? `after ${frame.operation}` : 'start'}</p>
                        {kind === 'stack' ? (
                            <ol className="flex w-24 flex-col-reverse gap-1.5 border-x-2 border-b-2 border-white/20 p-1.5" aria-label="Stack, bottom first">
                                {frame.items.length === 0 && <li className="py-3 text-center font-mono text-xs text-muted">empty</li>}
                                {frame.items.map((value, index) => <li key={index}><Cell value={value} highlight={index === frame.touched} /></li>)}
                            </ol>
                        ) : (
                            <div>
                                <div className="mb-1 flex justify-between font-mono text-[10px] text-muted"><span>front</span><span>back</span></div>
                                <ol className="flex min-h-14 min-w-40 gap-1.5 border-y-2 border-white/20 px-1 py-1.5" aria-label={`${kind}, front first`}>
                                    {frame.items.length === 0 && <li className="m-auto font-mono text-xs text-muted">empty</li>}
                                    {frame.items.map((value, index) => <li key={index}><Cell value={value} highlight={index === frame.touched} /></li>)}
                                </ol>
                            </div>
                        )}
                    </div>
                    {frame.removed !== undefined && (
                        <div>
                            <p className="mb-2 font-mono text-[11px] uppercase tracking-wider text-muted">returned</p>
                            <span className="flex h-11 min-w-11 items-center justify-center rounded-lg border border-[#30D158] bg-[#30D158]/15 px-2 font-mono text-sm text-[#30D158]">{frame.removed}</span>
                        </div>
                    )}
                </div>
            )}
        </Player>
    );
};

export default StackQueueView;
