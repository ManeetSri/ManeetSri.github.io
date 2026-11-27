import { Fragment } from 'react';

// Quiz prompts, options and explanations are plain strings. This renders the little markdown they use,
// `code`, **bold** and *emphasis*, as React elements (never as HTML).
const PATTERN = /(`[^`]+`|\*\*[^*]+\*\*|\*[^*]+\*)/g;

export const Inline = ({ text }) => (
    <>
        {String(text).split(PATTERN).map((part, index) => {
            if (part.startsWith('`') && part.endsWith('`') && part.length > 1) {
                return <code key={index} className="rounded-md bg-white/8 px-1.5 py-0.5 font-mono text-[0.88em] text-amber">{part.slice(1, -1)}</code>;
            }
            if (part.startsWith('**') && part.endsWith('**') && part.length > 3) return <strong key={index} className="font-semibold text-paper">{part.slice(2, -2)}</strong>;
            if (part.startsWith('*') && part.endsWith('*') && part.length > 1) return <em key={index}>{part.slice(1, -1)}</em>;
            return <Fragment key={index}>{part}</Fragment>;
        })}
    </>
);
