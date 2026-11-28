import { useLayoutEffect, useRef } from 'react';
import Player from '../Player.jsx';
import { Inline } from '../../mdx/inline.jsx';
import { textWidth } from '../svg.js';

// Pieces the scripted design diagrams (flow, sequence, states, timeline) share

const inlineMessage = (message) => <Inline text={message} />;

// The Player with inline markdown in its messages; a diagram without steps shows as a still picture
export const ScriptPlayer = (props) => <Player renderMessage={inlineMessage} staticWhenSingle {...props} />;

// The svg at its natural size, shrinking to fit a narrow column down to three quarters of it; any
// narrower and the box scrolls sideways instead, so the page itself never does
export const DiagramSvg = ({ width, height, label, children }) => (
    <div className="overflow-x-auto">
        <svg
            viewBox={`0 0 ${Math.ceil(width)} ${Math.ceil(height)}`}
            role="img"
            aria-label={label}
            className="mx-auto block"
            style={{ width: '100%', maxWidth: Math.ceil(width), minWidth: Math.round(width * 0.75) }}
        >
            {children}
        </svg>
    </div>
);

// A message travelling along an svg path, again and again while its step is showing. SMIL rather than
// CSS, so it follows curves and needs no stylesheet; the views leave it out under reduced motion.
export const Token = ({ path, seconds = 1.6 }) => {
    const motion = useRef(null);
    const fade = useRef(null);
    useLayoutEffect(() => {
        motion.current?.beginElement?.();
        fade.current?.beginElement?.();
    }, [path]);
    const timing = { dur: `${seconds}s`, begin: 'indefinite', repeatCount: 'indefinite', keyTimes: '0;0.12;0.82;1' };
    return (
        <g aria-hidden="true" opacity="0" pointerEvents="none">
            <animate ref={fade} attributeName="opacity" values="0;1;1;0" {...timing} />
            <animateMotion ref={motion} path={path} keyPoints="0;0;1;1" calcMode="linear" {...timing} />
            <circle r="9" fill="var(--color-amber)" opacity="0.22" />
            <circle r="4.5" fill="var(--color-amber)" />
        </g>
    );
};

// A still marker for reduced motion: a dot near where the message arrives
export const ArrivalDot = ({ at }) => <circle cx={at.x} cy={at.y} r="4" fill="var(--color-amber)" aria-hidden="true" />;

// Text on a small plate in the surface colour, so it reads over the lines behind it
export const LabelPlate = ({ x, y, text, fontSize = 10, color = 'var(--color-muted)', weight }) => {
    const width = textWidth(text, fontSize) + 10;
    const height = fontSize + 7;
    return (
        <g>
            <rect x={x - width / 2} y={y - height / 2} width={width} height={height} rx="4" fill="var(--color-surface)" fillOpacity="0.94" />
            <text x={x} y={y} textAnchor="middle" dominantBaseline="central" fontSize={fontSize} fontFamily="var(--font-mono)" fontWeight={weight} fill={color}>{text}</text>
        </g>
    );
};
