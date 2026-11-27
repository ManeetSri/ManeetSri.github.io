import { useMemo, useState } from 'react';
import Player from '../Player.jsx';
import { layoutTree, recursionCode, recursionFrames, recursionLimits } from '../algorithms/recursion.js';

const NODE_W = 92;
const NODE_H = 34;
const GAP_X = 10;
const GAP_Y = 30;

const NODE_STYLES = {
    active: { fill: 'rgba(253,176,58,0.22)', stroke: 'var(--color-amber)', text: 'var(--color-amber)' },
    waiting: { fill: 'rgba(242,240,235,0.06)', stroke: 'rgba(242,240,235,0.35)', text: 'var(--color-paper)' },
    done: { fill: 'rgba(48,209,88,0.14)', stroke: '#30D158', text: '#9FE6B0' },
    cached: { fill: 'rgba(93,216,255,0.14)', stroke: '#5DD8FF', text: '#5DD8FF' },
};

const CallTree = ({ nodes }) => {
    const { position, width, depth } = useMemo(() => layoutTree(nodes), [nodes]);
    const svgWidth = width * (NODE_W + GAP_X);
    const svgHeight = depth * (NODE_H + GAP_Y);
    const center = (id) => {
        const { x, depth: level } = position.get(id);
        return { cx: x * (NODE_W + GAP_X) + NODE_W / 2 + GAP_X / 2, cy: level * (NODE_H + GAP_Y) + NODE_H / 2 };
    };
    return (
        <div className="overflow-x-auto">
            <svg width={svgWidth} height={svgHeight} viewBox={`0 0 ${svgWidth} ${svgHeight}`} role="img" aria-label={`Call tree with ${nodes.length} calls`} className="mx-auto block">
                {nodes.filter((node) => node.parent !== null).map((node) => {
                    const from = center(node.parent);
                    const to = center(node.id);
                    return <line key={`edge-${node.id}`} x1={from.cx} y1={from.cy + NODE_H / 2} x2={to.cx} y2={to.cy - NODE_H / 2} stroke="rgba(242,240,235,0.2)" strokeWidth="1.5" />;
                })}
                {nodes.map((node) => {
                    const { cx, cy } = center(node.id);
                    const style = NODE_STYLES[node.cached && node.state === 'done' ? 'cached' : node.state];
                    return (
                        <g key={node.id}>
                            <rect x={cx - NODE_W / 2} y={cy - NODE_H / 2} width={NODE_W} height={NODE_H} rx="9" fill={style.fill} stroke={style.stroke} strokeWidth={node.state === 'active' ? 2 : 1} />
                            <text x={cx} y={cy + 1} textAnchor="middle" dominantBaseline="middle" fontFamily="var(--font-mono)" fontSize="11" fill={style.text}>
                                {node.label}{node.state === 'done' ? ` → ${node.value}` : ''}
                            </text>
                        </g>
                    );
                })}
            </svg>
        </div>
    );
};

// ```visual recursionTree with { fn: factorial | fibonacci | fibonacciMemo | power | sumDigits, n, base }
const RecursionTreeView = ({ fn = 'factorial', n: initialN = 4, base = 2 }) => {
    const limits = recursionLimits(fn);
    const [n, setN] = useState(Math.min(limits.max, Math.max(limits.min, initialN)));
    const args = fn === 'power' ? [base, n] : [n];
    const frames = useMemo(() => recursionFrames(fn, fn === 'power' ? [base, n] : [n]), [fn, base, n]);
    const choices = fn === 'sumDigits' ? [7, 42, 905, 4096, 98765] : Array.from({ length: limits.max - limits.min + 1 }, (_, index) => limits.min + index);

    return (
        <div>
            <label className="mb-3 flex flex-wrap items-center gap-2 text-sm text-muted">
                {fn === 'power' ? `Exponent (base ${base})` : 'n'}
                <select value={n} onChange={(event) => setN(Number(event.target.value))} className="h-9 rounded-lg border border-line bg-raised px-2 font-mono text-paper">
                    {choices.map((value) => <option key={value} value={value}>{value}</option>)}
                </select>
            </label>
            <Player key={args.join(',')} frames={frames} code={recursionCode(fn)} title="Each call waits on the stack until the calls it makes return">
                {(frame) => (
                    <div className="space-y-4">
                        <CallTree nodes={frame.nodes} />
                        <div>
                            <p className="mb-1.5 font-mono text-[11px] uppercase tracking-wider text-muted">Call stack (top first)</p>
                            <ol className="flex flex-col-reverse gap-1" aria-label="Call stack">
                                {frame.stack.length === 0 && <li className="font-mono text-xs text-muted">empty</li>}
                                {frame.stack.map((label, index) => (
                                    <li key={`${label}-${index}`} className={`rounded-md border px-2.5 py-1 font-mono text-xs ${index === frame.stack.length - 1 ? 'border-amber bg-amber/15 text-amber' : 'border-line text-paper/80'}`}>{label}</li>
                                ))}
                            </ol>
                        </div>
                    </div>
                )}
            </Player>
        </div>
    );
};

export default RecursionTreeView;
