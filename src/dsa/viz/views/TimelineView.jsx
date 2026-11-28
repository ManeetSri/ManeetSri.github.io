import { useMemo } from 'react';
import { useReducedMotion } from 'framer-motion';
import { TONES } from '../tones.js';
import { useStable } from '../useStable.js';
import { formatTime, MARKER_FONT, SPAN_FONT, timelineFrames, timelineLayout, timelineModel, timelineSummary } from '../script/timeline.js';
import { DiagramSvg, ScriptPlayer } from './ScriptParts.jsx';

const MARKER = '#5DD8FF';

const TimelineDiagram = ({ model, layout, frame }) => {
    const reduceMotion = useReducedMotion();
    const fade = reduceMotion ? undefined : 'transition-opacity duration-300';
    const visible = new Set(frame.visible);
    const active = new Set(frame.active);
    const cursor = frame.at === null ? null : layout.x(frame.at);
    const pill = cursor === null ? null : formatTime(frame.at, model.unit);
    const pillW = pill ? pill.length * 6 + 14 : 0;

    return (
        <DiagramSvg width={layout.width} height={layout.height} label={timelineSummary(model)}>
            {layout.lanes.map((lane, index) => (
                <g key={lane.id}>
                    <rect x={layout.plotX0 - 6} y={lane.y} width={layout.plotX1 - layout.plotX0 + 12} height={layout.laneHeight} fill="rgba(242,240,235,1)" fillOpacity={index % 2 ? 0.015 : 0.035} />
                    <text x={layout.labelW} y={lane.y + layout.laneHeight / 2} textAnchor="end" dominantBaseline="central" fontSize="11" fill="var(--color-paper)">{lane.label}</text>
                </g>
            ))}
            {layout.ticks.map((tick) => (
                <g key={tick.value}>
                    <line x1={tick.x} y1={layout.top} x2={tick.x} y2={layout.axisY} stroke="rgba(242,240,235,0.07)" />
                    <text x={tick.x} y={layout.axisY + 14} textAnchor="middle" fontSize="9.5" fontFamily="var(--font-mono)" fill="var(--color-muted)">{tick.text}</text>
                </g>
            ))}
            <line x1={layout.plotX0 - 6} y1={layout.axisY} x2={layout.plotX1 + 6} y2={layout.axisY} stroke="rgba(242,240,235,0.3)" />
            {layout.spans.map((span) => {
                const key = `s${span.index}`;
                const tone = TONES[span.tone] ?? TONES.neutral;
                const running = active.has(key);
                const elapsed = cursor === null ? span.x1 - span.x0 : Math.max(0, Math.min(span.x1, cursor) - span.x0);
                return (
                    <g key={key} opacity={visible.has(key) ? 1 : 0} className={fade}>
                        <rect x={span.x0} y={span.y} width={span.x1 - span.x0} height={span.h} rx="4" fill={tone.fill} stroke={tone.stroke} strokeOpacity={running ? 1 : 0.55} strokeWidth={running ? 1.6 : 1} />
                        {elapsed > 0 && <rect x={span.x0} y={span.y} width={elapsed} height={span.h} rx="4" fill={tone.bar} />}
                        {span.label.text && (
                            <text x={span.label.x} y={span.y + span.h / 2} textAnchor={span.label.anchor} dominantBaseline="central" fontSize={SPAN_FONT} fill={span.label.inside ? 'var(--color-paper)' : tone.text}>{span.label.text}</text>
                        )}
                    </g>
                );
            })}
            {layout.markers.map((marker) => {
                const key = `m${marker.index}`;
                return (
                    <g key={key} opacity={visible.has(key) ? 1 : 0} className={fade}>
                        <line x1={marker.x} y1={marker.labelY + 4} x2={marker.x} y2={layout.lanesBottom} stroke={MARKER} strokeOpacity="0.75" strokeDasharray="3 3" />
                        <text x={marker.labelX} y={marker.labelY} textAnchor="middle" fontSize={MARKER_FONT} fontFamily="var(--font-mono)" fill={MARKER}>{marker.label}</text>
                    </g>
                );
            })}
            {cursor !== null && (
                <g aria-hidden="true">
                    <line x1={cursor} y1={layout.top - 4} x2={cursor} y2={layout.axisY} stroke="var(--color-amber)" strokeWidth="1.6" />
                    <rect x={Math.max(2, Math.min(cursor - pillW / 2, layout.width - pillW - 2))} y={layout.axisY + 21} width={pillW} height="17" rx="8.5" fill="var(--color-amber)" />
                    <text x={Math.max(2, Math.min(cursor - pillW / 2, layout.width - pillW - 2)) + pillW / 2} y={layout.axisY + 29.5} textAnchor="middle" dominantBaseline="central" fontSize="10" fontFamily="var(--font-mono)" fontWeight="600" fill="var(--color-ink)">{pill}</text>
                </g>
            )}
        </DiagramSvg>
    );
};

// ```visual timeline with { unit?, lanes, spans, markers?, steps?, start?, end?, caption?, title? }; see AUTHORING.diagrams.md
const TimelineView = ({ unit, lanes, spans, markers, steps, start, end, caption, title, code }) => {
    const props = useStable({ unit, lanes, spans, markers, steps, start, end, caption });
    const model = useMemo(() => timelineModel(props), [props]);
    const layout = useMemo(() => timelineLayout(model), [model]);
    const frames = useMemo(() => timelineFrames(props), [props]);
    return (
        <ScriptPlayer frames={frames} title={title} code={code}>
            {(frame) => <TimelineDiagram model={model} layout={layout} frame={frame} />}
        </ScriptPlayer>
    );
};

export default TimelineView;
