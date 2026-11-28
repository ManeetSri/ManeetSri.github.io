import { useMemo } from 'react';
import Player from '../../Player.jsx';
import { BAD, SKY, AMBER, pct, secs } from '../common.js';
import { ORDER_ENDS, POLICY_NAMES, cacheSimFrames, ttlLeft } from '../cacheSim.js';

// Where a request was served from: a colour per layer, and the origin's
const LAYER_COLOURS = ['#30D158', '#DABAFF', '#78C2B3', '#FFD60A'];
const ENTRY_TONES = {
    hit: { borderColor: AMBER, backgroundColor: 'rgba(253,176,58,0.2)', color: AMBER },
    new: { borderColor: SKY, backgroundColor: 'rgba(93,216,255,0.14)', color: SKY },
};
const STATUS = {
    hit: { label: 'hit', style: { color: '#30D158', backgroundColor: 'rgba(48,209,88,0.15)' } },
    miss: { label: 'miss', style: { color: BAD, backgroundColor: 'rgba(255,157,150,0.12)' } },
};

const describe = (frame) => {
    const layers = frame.layers.map((layer) => `${layer.name} holds ${layer.entries.length} of ${layer.capacity}${layer.entries.length ? `: ${layer.entries.map((entry) => entry.key).join(', ')}` : ''}${layer.status ? ` (${layer.status})` : ''}`);
    return `${layers.join('. ')}. ${frame.origin.name} has served ${frame.origin.fetches}.`;
};

const servedName = (frame, served) => (served === -1 ? frame.origin.name : frame.layers[served]?.name);

// ```visual cacheSim with { layers: [{ name, capacity }], origin, policy: lru | lfu | fifo, ttl?, requests }
const CacheSimView = (props) => {
    const inputKey = JSON.stringify(props);
    const frames = useMemo(() => cacheSimFrames(JSON.parse(inputKey)), [inputKey]);
    const policy = props.policy ?? 'lru';
    const [first, last] = ORDER_ENDS[policy];
    const title = props.title ?? `${POLICY_NAMES[policy]} cache: ${props.layers.map((layer) => layer.name).join(' → ')} → ${props.origin ?? 'Origin'}`;

    return (
        <Player frames={frames} title={title}>
            {(frame) => (
                <div className="space-y-4">
                    <div role="img" aria-label={describe(frame)} className="space-y-2">
                        <p className="flex justify-between gap-3 font-mono text-[10px] text-muted" aria-hidden="true">
                            <span>← {first}</span><span>{last}, evicted next →</span>
                        </p>
                        {frame.layers.map((layer, index) => (
                            <div key={layer.name} className="rounded-xl border border-line bg-white/[0.02] px-3 py-2.5">
                                <div className="flex flex-wrap items-center justify-between gap-x-3 gap-y-1">
                                    <span className="flex items-center gap-2 font-mono text-xs">
                                        <span className="h-2.5 w-2.5 rounded-full" style={{ backgroundColor: LAYER_COLOURS[index] }} />
                                        <span className="text-paper">{layer.name}</span>
                                        <span className="text-muted">{layer.entries.length}/{layer.capacity}</span>
                                        {layer.status && <span className="rounded-full px-2 py-0.5 text-[10px]" style={STATUS[layer.status].style}>{STATUS[layer.status].label}</span>}
                                    </span>
                                    <span className="font-mono text-[11px] text-muted">hit {layer.hits}/{layer.lookups}{layer.lookups ? ` · ${pct(layer.hits, layer.lookups)}` : ''}</span>
                                </div>
                                <ol className="mt-2 flex flex-wrap items-center gap-1.5">
                                    {layer.entries.map((entry) => {
                                        const left = ttlLeft(entry.left);
                                        return (
                                            <li key={entry.key} className="flex h-8 min-w-9 items-center justify-center gap-1 rounded-lg border border-white/25 bg-white/[0.06] px-2 font-mono text-sm motion-safe:transition-colors" style={ENTRY_TONES[entry.tone]}>
                                                {entry.key}
                                                {policy === 'lfu' && <span className="text-[10px] opacity-70">×{entry.count}</span>}
                                                {left && <span className="text-[10px] opacity-70">{left}</span>}
                                            </li>
                                        );
                                    })}
                                    {Array.from({ length: Math.max(0, layer.capacity - layer.entries.length) }, (_, slot) => (
                                        <li key={`free-${slot}`} className="h-8 w-9 rounded-lg border border-dashed border-line" />
                                    ))}
                                    {layer.gone.map((entry) => (
                                        <li key={`gone-${entry.key}`} className="flex h-8 items-center gap-1 rounded-lg border border-dashed px-2 font-mono text-sm" style={entry.reason === 'evicted' ? { borderColor: BAD, color: BAD } : { borderColor: 'rgba(242,240,235,0.3)', color: 'var(--color-muted)' }}>
                                            <span className="line-through">{entry.key}</span><span className="text-[10px]">{entry.reason}</span>
                                        </li>
                                    ))}
                                </ol>
                            </div>
                        ))}
                        <div className="flex items-center gap-2 rounded-xl border px-3 py-2 font-mono text-xs motion-safe:transition-colors" style={frame.origin.active ? { borderColor: SKY, backgroundColor: 'rgba(93,216,255,0.1)', color: SKY } : { borderColor: 'var(--color-line)' }}>
                            <span className="h-2.5 w-2.5 rounded-full" style={{ backgroundColor: BAD }} />
                            <span className={frame.origin.active ? '' : 'text-paper'}>{frame.origin.name}</span>
                            <span className="text-muted">origin · {frame.origin.fetches} fetched{frame.origin.active ? ' · fetching…' : ''}</span>
                        </div>
                    </div>
                    <div>
                        <p className="mb-1.5 font-mono text-[10px] text-muted">Requests (colour shows where each was served)</p>
                        {/* relative: keeps the sr-only text inside the scroller, so it can't widen the page */}
                        <div className="relative overflow-x-auto pb-1">
                            <ol className="flex min-w-max gap-1" aria-label="Requests">
                                {frame.timeline.map((request, index) => {
                                    const done = request.served !== null;
                                    const colour = request.served === -1 ? BAD : LAYER_COLOURS[request.served];
                                    const current = index === frame.current;
                                    return (
                                        <li key={index} className="flex min-w-11 flex-col items-center gap-0.5">
                                            <span
                                                className={`flex h-8 w-full items-center justify-center whitespace-nowrap rounded-md border px-1.5 font-mono text-xs ${done ? '' : 'border-dashed border-line text-muted'} ${current ? 'ring-2 ring-amber' : ''}`}
                                                style={done ? { borderColor: colour, color: colour, backgroundColor: `${colour}1f` } : undefined}
                                            >
                                                {request.key}
                                                <span className="sr-only">{done ? `, from ${servedName(frame, request.served)}` : ', still to come'}</span>
                                            </span>
                                            <span className="font-mono text-[10px] text-muted">{secs(request.time, 1)}</span>
                                        </li>
                                    );
                                })}
                            </ol>
                        </div>
                        <ul className="mt-2 flex flex-wrap gap-x-4 gap-y-1 font-mono text-[10px] text-muted" aria-hidden="true">
                            {frame.layers.map((layer, index) => (
                                <li key={layer.name} className="flex items-center gap-1.5"><span className="h-2 w-2 rounded-full" style={{ backgroundColor: LAYER_COLOURS[index] }} />{layer.name}</li>
                            ))}
                            <li className="flex items-center gap-1.5"><span className="h-2 w-2 rounded-full" style={{ backgroundColor: BAD }} />{frame.origin.name}</li>
                        </ul>
                    </div>
                </div>
            )}
        </Player>
    );
};

export default CacheSimView;
