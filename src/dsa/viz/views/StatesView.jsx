import { useId, useMemo } from 'react';
import { useReducedMotion } from 'framer-motion';
import { ArrowMarker, truncate } from '../svg.js';
import { LINE, LINE_ACTIVE, TONES } from '../tones.js';
import { useStable } from '../useStable.js';
import { LABEL_FONT, statesFrames, statesLayout, statesModel, statesSummary } from '../script/states.js';
import { DiagramSvg, ScriptPlayer, Token } from './ScriptParts.jsx';

const StatesDiagram = ({ model, layout, frame }) => {
    const id = useId().replace(/:/g, '');
    const reduceMotion = useReducedMotion();
    const finals = new Set(model.final);
    const takenEdge = layout.edges.find((edge) => edge.transitions.some((transition) => transition.index === frame.transition));

    return (
        <DiagramSvg width={layout.width} height={layout.height} label={statesSummary(model)}>
            <defs>
                <ArrowMarker id={`${id}-rest`} fill={LINE} size={6.5} />
                <ArrowMarker id={`${id}-active`} fill={LINE_ACTIVE} size={6.5} />
            </defs>
            {layout.start && (
                <g>
                    <circle cx={layout.start.dot.x} cy={layout.start.dot.y} r="6" fill="var(--color-paper)" />
                    <path d={layout.start.d} stroke={LINE} strokeWidth="1.4" markerEnd={`url(#${id}-rest)`} />
                </g>
            )}
            {layout.edges.map((edge) => {
                const lit = edge === takenEdge;
                return (
                    <path key={edge.key} d={edge.d} fill="none" stroke={lit ? LINE_ACTIVE : LINE} strokeWidth={lit ? 2 : 1.4} markerEnd={`url(#${id}-${lit ? 'active' : 'rest'})`} />
                );
            })}
            {model.states.map((state) => {
                const rect = layout.rects[state.id];
                const isCurrent = frame.current === state.id;
                const tone = isCurrent ? TONES.active : TONES.neutral;
                return (
                    <g key={state.id}>
                        <rect x={rect.x} y={rect.y} width={rect.w} height={rect.h} rx="14" fill={tone.fill} stroke={tone.stroke} strokeWidth={isCurrent ? 2 : 1.3} />
                        {finals.has(state.id) && <rect x={rect.x + 4} y={rect.y + 4} width={rect.w - 8} height={rect.h - 8} rx="10" fill="none" stroke={tone.stroke} strokeWidth="1" />}
                        <text x={rect.x + rect.w / 2} y={rect.y + rect.h / 2} textAnchor="middle" dominantBaseline="central" fontSize="12" fill={tone.text}>{truncate(state.label, 16)}</text>
                    </g>
                );
            })}
            {layout.edges.map((edge) => {
                const { x, y, w, h } = edge.label;
                return (
                    <g key={`label-${edge.key}`}>
                        <rect x={x - w / 2} y={y - h / 2} width={w} height={h} rx="4" fill="var(--color-surface)" fillOpacity="0.94" />
                        {edge.lines.map((line, index) => {
                            const lit = line.transition === frame.transition;
                            return (
                                <text
                                    key={index}
                                    x={x}
                                    y={y - h / 2 + 2.5 + layout.lineHeight * (index + 0.5)}
                                    textAnchor="middle"
                                    dominantBaseline="central"
                                    fontSize={line.guard ? LABEL_FONT - 0.5 : LABEL_FONT}
                                    fontFamily="var(--font-mono)"
                                    fontWeight={lit && !line.guard ? 600 : undefined}
                                    fill={lit ? 'var(--color-amber)' : line.guard ? 'var(--color-muted)' : 'var(--color-paper)'}
                                    fillOpacity={lit || line.guard ? 1 : 0.8}
                                >
                                    {line.text}
                                </text>
                            );
                        })}
                    </g>
                );
            })}
            {!reduceMotion && takenEdge && <Token key={`${takenEdge.key}-${frame.transition}`} path={takenEdge.d} seconds={1.4} />}
        </DiagramSvg>
    );
};

// ```visual states with { states, initial, final?, transitions, events?, intro?, title? }; see AUTHORING.diagrams.md
const StatesView = ({ states, initial, final, transitions, events, intro, title, code }) => {
    const props = useStable({ states, initial, final, transitions, events, intro });
    const model = useMemo(() => statesModel(props), [props]);
    const layout = useMemo(() => statesLayout(model), [model]);
    const frames = useMemo(() => statesFrames(props), [props]);
    return (
        <ScriptPlayer frames={frames} title={title} code={code}>
            {(frame) => <StatesDiagram model={model} layout={layout} frame={frame} />}
        </ScriptPlayer>
    );
};

export default StatesView;
