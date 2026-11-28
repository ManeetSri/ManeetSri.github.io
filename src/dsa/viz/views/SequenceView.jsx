import { useId, useMemo } from 'react';
import { useReducedMotion } from 'framer-motion';
import { ArrowMarker } from '../svg.js';
import { LINE, LINE_ACTIVE, TONES } from '../tones.js';
import { useStable } from '../useStable.js';
import { LABEL_FONT, NOTE_FONT, sequenceFrames, sequenceLayout, sequenceModel, sequenceSummary } from '../script/sequence.js';
import { DiagramSvg, ScriptPlayer, Token } from './ScriptParts.jsx';

// Messages after the current step stay faint, so the whole conversation's shape is visible from the start
const FUTURE = 0.16;

const Message = ({ row, current, marker }) => {
    const colour = current ? LINE_ACTIVE : LINE;
    const head = `url(#${marker}-${row.reply || row.async ? 'open' : 'solid'}-${current ? 'active' : 'rest'})`;
    const dash = row.reply ? '5 4' : undefined;
    if (row.self) {
        return (
            <g>
                <path d={`M ${row.x1} ${row.y} H ${row.x1 + 30} V ${row.loopBottom} H ${row.x1 + 2}`} fill="none" stroke={colour} strokeWidth={current ? 1.8 : 1.3} strokeDasharray={dash} markerEnd={head} />
                <text x={row.labelX} y={row.labelY} fontSize={LABEL_FONT} fontFamily="var(--font-mono)" fill={current ? 'var(--color-amber)' : 'var(--color-paper)'}>{row.text}</text>
            </g>
        );
    }
    const direction = Math.sign(row.x2 - row.x1);
    return (
        <g>
            <line x1={row.x1} y1={row.y} x2={row.x2 - direction} y2={row.y} stroke={colour} strokeWidth={current ? 1.8 : 1.3} strokeDasharray={dash} markerEnd={head} />
            <text x={row.labelX} y={row.labelY} textAnchor="middle" fontSize={LABEL_FONT} fontFamily="var(--font-mono)" fill={current ? 'var(--color-amber)' : 'var(--color-paper)'}>{row.text}</text>
        </g>
    );
};

const Note = ({ row, current }) => (
    <g>
        <rect x={row.box.x} y={row.box.y} width={row.box.w} height={row.box.h} rx="4" fill={current ? TONES.active.fill : 'rgba(253,176,58,0.06)'} stroke={current ? 'var(--color-amber)' : 'rgba(253,176,58,0.38)'} />
        {row.lines.map((line, index) => (
            <text key={index} x={row.box.x + 8} y={row.box.y + 16 + index * 14} fontSize={NOTE_FONT} fill={current ? 'var(--color-amber)' : 'var(--color-paper)'}>{line}</text>
        ))}
    </g>
);

const SequenceDiagram = ({ model, layout, frame }) => {
    const id = useId().replace(/:/g, '');
    const reduceMotion = useReducedMotion();
    const fade = reduceMotion ? undefined : 'transition-opacity duration-300';
    const visible = new Set(frame.visible);
    const current = new Set(frame.active);
    const involved = new Set(layout.rows.filter((row) => current.has(`m${row.index}`)).flatMap((row) => (row.type === 'note' ? row.over : [row.from, row.to])));

    return (
        <DiagramSvg width={layout.width} height={layout.height} label={sequenceSummary(model)}>
            <defs>
                {['solid', 'open'].flatMap((shape) => [['rest', LINE], ['active', LINE_ACTIVE]].map(([state, colour]) => (
                    <ArrowMarker key={`${shape}-${state}`} id={`${id}-${shape}-${state}`} fill={colour} open={shape === 'open'} size={shape === 'open' ? 8 : 6.5} refX={shape === 'open' ? 9.5 : 10} />
                )))}
            </defs>
            {layout.fragments.map((fragment, index) => {
                const shown = frame.upTo >= fragment.from;
                return (
                    <g key={`fragment-${index}`} opacity={shown ? 1 : FUTURE} className={fade}>
                        <rect x={fragment.x} y={fragment.top} width={fragment.w} height={fragment.bottom - fragment.top} rx="6" fill="rgba(242,240,235,0.02)" stroke="rgba(242,240,235,0.3)" />
                        <path d={`M ${fragment.x} ${fragment.top + 6} Q ${fragment.x} ${fragment.top} ${fragment.x + 6} ${fragment.top} H ${fragment.x + fragment.tab} V ${fragment.top + 11} L ${fragment.x + fragment.tab - 6} ${fragment.top + 17} H ${fragment.x} Z`} fill="rgba(242,240,235,0.1)" />
                        <text x={fragment.x + 7} y={fragment.top + 12} fontSize="9.5" fontFamily="var(--font-mono)" fontWeight="600" fill="var(--color-paper)">{fragment.kind}</text>
                        {fragment.label && <text x={fragment.x + fragment.tab + 8} y={fragment.top + 12.5} fontSize="10" fill="var(--color-muted)">[{fragment.label}]</text>}
                        {fragment.elseY !== undefined && (
                            <g>
                                <line x1={fragment.x} y1={fragment.elseY + 2} x2={fragment.x + fragment.w} y2={fragment.elseY + 2} stroke="rgba(242,240,235,0.3)" strokeDasharray="5 4" />
                                <text x={fragment.x + 8} y={fragment.elseY + 15} fontSize="10" fill="var(--color-muted)">[{fragment.elseLabel || 'else'}]</text>
                            </g>
                        )}
                    </g>
                );
            })}
            {layout.participants.map((participant) => (
                <line key={`life-${participant.id}`} x1={participant.x} y1={layout.lifelineTop} x2={participant.x} y2={layout.lifelineBottom} stroke="rgba(242,240,235,0.2)" strokeDasharray="3 4" />
            ))}
            {layout.participants.map((participant) => {
                const lit = involved.has(participant.id);
                return (
                    <g key={participant.id}>
                        <rect x={participant.x - participant.headW / 2} y={layout.headTop} width={participant.headW} height={layout.headHeight} rx="8" fill={lit ? TONES.active.fill : TONES.neutral.fill} stroke={lit ? 'var(--color-amber)' : TONES.neutral.stroke} />
                        <text x={participant.x} y={layout.headTop + layout.headHeight / 2} textAnchor="middle" dominantBaseline="central" fontSize="11.5" fill={lit ? 'var(--color-amber)' : 'var(--color-paper)'}>{participant.label}</text>
                    </g>
                );
            })}
            {layout.rows.map((row) => {
                const key = `m${row.index}`;
                const isCurrent = current.has(key);
                return (
                    <g key={key} opacity={visible.has(key) ? 1 : FUTURE} className={fade}>
                        {row.type === 'note' ? <Note row={row} current={isCurrent} /> : <Message row={row} current={isCurrent} marker={id} />}
                    </g>
                );
            })}
            {!reduceMotion && layout.rows.filter((row) => row.type === 'message' && current.has(`m${row.index}`)).map((row) => (
                <Token
                    key={`token-${row.index}`}
                    path={row.self ? `M ${row.x1} ${row.y} H ${row.x1 + 30} V ${row.loopBottom} H ${row.x1 + 2}` : `M ${row.x1} ${row.y} L ${row.x2} ${row.y}`}
                    seconds={row.self ? 1.4 : 1.6}
                />
            ))}
        </DiagramSvg>
    );
};

// ```visual sequence with { participants, messages, fragments?, steps?, title? }; see AUTHORING.diagrams.md
const SequenceView = ({ participants, messages, fragments, steps, title, code }) => {
    const props = useStable({ participants, messages, fragments, steps });
    const model = useMemo(() => sequenceModel(props), [props]);
    const layout = useMemo(() => sequenceLayout(model), [model]);
    const frames = useMemo(() => sequenceFrames(props), [props]);
    return (
        <ScriptPlayer frames={frames} title={title} code={code}>
            {(frame) => <SequenceDiagram model={model} layout={layout} frame={frame} />}
        </ScriptPlayer>
    );
};

export default SequenceView;
