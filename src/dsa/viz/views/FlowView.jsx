import { useId, useMemo } from 'react';
import { useReducedMotion } from 'framer-motion';
import { ArrowMarker, truncate, wrapText } from '../svg.js';
import { LINE, LINE_ACTIVE, TONES } from '../tones.js';
import { useStable } from '../useStable.js';
import { edgeKey } from '../script/frames.js';
import { edgeLabelAt, flowFrames, flowLayout, flowModel, flowSummary } from '../script/flow.js';
import { ArrivalDot, DiagramSvg, LabelPlate, ScriptPlayer, Token } from './ScriptParts.jsx';

// Each kind of part has its own accent and a small change of shape, so a diagram reads at a glance
const KINDS = {
    client: { accent: '#5DD8FF', radius: 13 },
    view: { accent: '#C9A8FF', radius: 5 },
    service: { accent: '#FDB03A', radius: 8 },
    store: { accent: '#9FE6B0', radius: 3, shelf: true },
    db: { accent: '#30D158', cylinder: true },
    cache: { accent: '#F05138', radius: 8, stripe: 'left', nudge: 3 },
    queue: { accent: '#F7A1C4', radius: 6, slots: true, nudge: -10 },
    cdn: { accent: '#7FD1C7', radius: 8, stripe: 'top' },
    external: { accent: '#A3A5AE', radius: 8, dash: '5 4' },
    actor: { accent: '#F2F0EB', pill: true },
};
const DASH = { sync: undefined, async: '6 4', data: '1.5 4' };
// Parts a step hasn't shown yet stay as faint outlines, so the layout never jumps
const GHOST = 0.13;
const TONE_COLOURS = { neutral: LINE, active: LINE_ACTIVE, ok: TONES.ok.stroke, error: TONES.error.stroke, wait: TONES.wait.stroke };

const NodeShape = ({ rect, style, paint }) => {
    const { x, y, w, h } = rect;
    if (style.cylinder) {
        const ry = 6;
        return (
            <g>
                <path d={`M ${x} ${y + ry} A ${w / 2} ${ry} 0 0 1 ${x + w} ${y + ry} V ${y + h - ry} A ${w / 2} ${ry} 0 0 1 ${x} ${y + h - ry} Z`} {...paint} />
                <path d={`M ${x} ${y + ry} A ${w / 2} ${ry} 0 0 0 ${x + w} ${y + ry}`} fill="none" stroke={paint.stroke} strokeOpacity={paint.strokeOpacity} strokeWidth={paint.strokeWidth} />
            </g>
        );
    }
    const marks = { stroke: style.accent, strokeOpacity: 0.65, strokeLinecap: 'round' };
    return (
        <g>
            <rect x={x} y={y} width={w} height={h} rx={style.pill ? h / 2 : style.radius} strokeDasharray={style.dash} {...paint} />
            {style.stripe === 'left' && <path d={`M ${x + 4} ${y + 9} V ${y + h - 9}`} strokeWidth="2.5" {...marks} />}
            {style.stripe === 'top' && <path d={`M ${x + 10} ${y + 4} H ${x + w - 10}`} strokeWidth="2.5" {...marks} />}
            {style.shelf && <path d={`M ${x + 6} ${y + h - 5} H ${x + w - 6}`} strokeWidth="1.2" {...marks} />}
            {style.slots && [8, 13, 18].map((inset) => <path key={inset} d={`M ${x + w - inset} ${y + 14} V ${y + h - 10}`} strokeWidth="1.4" {...marks} />)}
        </g>
    );
};

const FlowNode = ({ node, rect, tone, active, visible, label, fade }) => {
    const style = KINDS[node.kind] ?? KINDS.service;
    const toned = active ? TONES.active : tone ? TONES[tone] : null;
    const paint = toned
        ? { fill: toned.fill, fillOpacity: 1, stroke: toned.stroke, strokeOpacity: 1, strokeWidth: active ? 2 : 1.6 }
        : { fill: style.accent, fillOpacity: 0.07, stroke: style.accent, strokeOpacity: 0.42, strokeWidth: 1.3 };
    const cx = rect.x + rect.w / 2;
    // The label moves aside from a stripe or the queue's slots, and down below a cylinder's lid
    const textX = cx + (style.nudge ?? 0);
    const lift = style.cylinder ? 4 : 0;
    // Up to two lines of label; a longer one ends in an ellipsis
    const limit = Math.max(6, Math.floor((rect.w - 14 - Math.abs(style.nudge ?? 0)) / 6.7));
    const wrapped = wrapText(node.label, limit);
    const lines = wrapped.length > 2 ? [wrapped[0], truncate(`${wrapped[1]} ${wrapped[2]}`, limit)] : wrapped;
    return (
        <g opacity={visible ? 1 : GHOST} className={fade}>
            <NodeShape rect={rect} style={style} paint={paint} />
            <text x={rect.x + (style.stripe === 'left' ? 12 : 9)} y={rect.y + 13 + lift} fontSize="8.5" fontFamily="var(--font-mono)" letterSpacing="0.6" fill={style.accent} fillOpacity="0.85">{node.kind.toUpperCase()}</text>
            {lines.map((line, index) => (
                <text
                    key={index}
                    x={textX}
                    y={rect.y + lift + (lines.length === 1 ? 33 : 28 + index * 13)}
                    textAnchor="middle"
                    fontSize={lines.length === 1 ? 12 : 11.5}
                    fill={toned ? toned.text : 'var(--color-paper)'}
                >
                    {line}
                </text>
            ))}
            {label !== undefined && (
                <g>
                    <rect x={cx - (label.length * 5.7 + 14) / 2} y={rect.y + rect.h - 8} width={label.length * 5.7 + 14} height="16" rx="8" fill="var(--color-raised)" stroke="var(--color-amber)" strokeOpacity="0.7" />
                    <text x={cx} y={rect.y + rect.h} textAnchor="middle" dominantBaseline="central" fontSize="9.5" fontFamily="var(--font-mono)" fill="var(--color-amber)">{label}</text>
                </g>
            )}
        </g>
    );
};

const FlowDiagram = ({ model, layout, frame }) => {
    const id = useId().replace(/:/g, '');
    const reduceMotion = useReducedMotion();
    const fade = reduceMotion ? undefined : 'transition-opacity duration-300';
    const visible = new Set(frame.visible);
    const active = new Set(frame.active);
    const sending = new Map();
    frame.send.forEach((key) => {
        const [from, to] = key.split('->');
        const forward = layout.edges.find((edge) => edge.key === edgeKey(from, to));
        const backward = layout.edges.find((edge) => edge.key === edgeKey(to, from));
        const edge = forward ?? backward;
        if (edge) sending.set(key, { edge, forward: Boolean(forward) });
    });
    const sendingEdges = new Set([...sending.values()].map(({ edge }) => edge.key));

    return (
        <DiagramSvg width={layout.width} height={layout.height} label={flowSummary(model)}>
            <defs>
                {Object.entries(TONE_COLOURS).map(([name, colour]) => <ArrowMarker key={name} id={`${id}-${name}`} fill={colour} size={6.5} />)}
            </defs>
            {layout.layers.map((layer, index) => (
                <g key={`layer-${index}`}>
                    <rect x={layer.x} y={layer.y} width={layer.w} height={layer.h} rx="10" fill="rgba(242,240,235,1)" fillOpacity={index % 2 ? 0.018 : 0.035} />
                    <text
                        x={layer.x + 12}
                        y={layer.y + layer.h / 2}
                        transform={`rotate(-90 ${layer.x + 12} ${layer.y + layer.h / 2})`}
                        textAnchor="middle"
                        dominantBaseline="central"
                        fontSize="9"
                        fontFamily="var(--font-mono)"
                        letterSpacing="1"
                        fill="var(--color-muted)"
                    >
                        {truncate(layer.label.toUpperCase(), Math.floor((layer.h - 8) / 6))}
                    </text>
                </g>
            ))}
            {layout.groups.map((group) => {
                const tone = active.has(group.id) ? TONES.active : frame.states[group.id] ? TONES[frame.states[group.id]] : null;
                return (
                    <g key={group.id} opacity={visible.has(group.id) ? 1 : GHOST} className={fade}>
                        <rect x={group.rect.x} y={group.rect.y} width={group.rect.w} height={group.rect.h} rx="12" fill={tone ? tone.fill : 'rgba(242,240,235,0.02)'} stroke={tone ? tone.stroke : 'rgba(242,240,235,0.24)'} strokeDasharray="4 3" />
                        <text x={group.rect.x + 10} y={group.rect.y + 14} fontSize="9" fontFamily="var(--font-mono)" letterSpacing="0.8" fill={tone ? tone.text : 'var(--color-muted)'}>{(group.label || group.id).toUpperCase()}</text>
                    </g>
                );
            })}
            {layout.edges.map((edge) => {
                const lit = active.has(edge.key) || sendingEdges.has(edge.key);
                const tone = lit ? 'active' : frame.states[edge.key] ?? 'neutral';
                return (
                    <path
                        key={edge.key}
                        d={edge.d}
                        fill="none"
                        stroke={TONE_COLOURS[tone]}
                        strokeWidth={lit ? 2 : 1.4}
                        strokeDasharray={DASH[edge.style]}
                        strokeLinecap={edge.style === 'data' ? 'round' : undefined}
                        markerEnd={`url(#${id}-${tone})`}
                        opacity={visible.has(edge.key) ? 1 : GHOST}
                        className={fade}
                    />
                );
            })}
            {model.nodes.map((node) => (
                <FlowNode
                    key={node.id}
                    node={node}
                    rect={layout.rects[node.id]}
                    tone={frame.states[node.id]}
                    active={active.has(node.id)}
                    visible={visible.has(node.id)}
                    label={frame.labels[node.id]}
                    fade={fade}
                />
            ))}
            {layout.edges.map((edge) => {
                const text = frame.labels[edge.key] ?? edge.label;
                if (!text) return null;
                const lit = active.has(edge.key) || sendingEdges.has(edge.key);
                return (
                    <g key={`label-${edge.key}`} opacity={visible.has(edge.key) ? 1 : GHOST} className={fade}>
                        <LabelPlate {...edgeLabelAt(edge, text)} text={text} color={lit ? 'var(--color-amber)' : 'var(--color-muted)'} />
                    </g>
                );
            })}
            {[...sending.entries()].map(([key, { edge, forward }]) => {
                const [from, to] = forward ? [edge.start, edge.end] : [edge.end, edge.start];
                if (reduceMotion) return <ArrivalDot key={key} at={{ x: from.x + (to.x - from.x) * 0.82, y: from.y + (to.y - from.y) * 0.82 }} />;
                return <Token key={key} path={`M ${from.x} ${from.y} L ${to.x} ${to.y}`} />;
            })}
        </DiagramSvg>
    );
};

// ```visual flow with { nodes, edges, groups?, layers?, steps?, caption?, title? }; see AUTHORING.diagrams.md
const FlowView = ({ nodes, edges, groups, layers, steps, caption, title, code }) => {
    const props = useStable({ nodes, edges, groups, layers, steps, caption });
    const model = useMemo(() => flowModel(props), [props]);
    const layout = useMemo(() => flowLayout(model), [model]);
    const frames = useMemo(() => flowFrames(props), [props]);
    return (
        <ScriptPlayer frames={frames} title={title} code={code}>
            {(frame) => <FlowDiagram model={model} layout={layout} frame={frame} />}
        </ScriptPlayer>
    );
};

export default FlowView;
