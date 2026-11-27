import { useEffect, useState } from 'react';
import { useReducedMotion } from 'framer-motion';
import { Pause, Play, RotateCcw, SkipBack, SkipForward } from 'lucide-react';
import { HighlightedCode } from '../mdx/CodeBlock.jsx';

const SPEEDS = [
    { label: '0.5×', ms: 1800 },
    { label: '1×', ms: 1100 },
    { label: '2×', ms: 550 },
];

const ControlButton = ({ label, onClick, disabled, children }) => (
    <button type="button" onClick={onClick} disabled={disabled} aria-label={label} className="flex h-10 w-10 items-center justify-center rounded-full bg-white/8 hover:bg-white/12 disabled:opacity-30">
        {children}
    </button>
);

// Steps through a list of frames. It never plays on its own: the learner presses play or steps.
// `children(frame)` draws the current frame, and `code` shows the Swift with the frame's line lit up.
const Player = ({ frames, code, children, title }) => {
    const [index, setIndex] = useState(0);
    const [playing, setPlaying] = useState(false);
    const [speed, setSpeed] = useState(1);
    const reduceMotion = useReducedMotion();
    const frame = frames[Math.min(index, frames.length - 1)];
    const atEnd = index >= frames.length - 1;
    // Playback stops by itself on the last frame
    const isPlaying = playing && !atEnd;

    useEffect(() => {
        if (!isPlaying) return undefined;
        const timer = setTimeout(() => setIndex((value) => value + 1), SPEEDS[speed].ms);
        return () => clearTimeout(timer);
    }, [isPlaying, index, speed]);

    return (
        <figure className="my-8 overflow-hidden rounded-2xl border border-line bg-surface">
            {title && <figcaption className="border-b border-line px-4 py-2.5 font-mono text-xs text-muted">{title}</figcaption>}
            {/* Stacked: a lesson column is too narrow to show the picture and the code side by side */}
            <div>
                <div className="p-4 sm:p-5">
                    <div className={reduceMotion ? '' : 'transition-all'}>{children(frame)}</div>
                    <p aria-live="polite" className="mt-4 min-h-12 rounded-xl bg-white/[0.04] px-4 py-3 text-sm leading-relaxed">
                        <span className="mr-2 font-mono text-xs text-muted">Step {index + 1}/{frames.length}</span>
                        {frame.message}
                    </p>
                </div>
                {code && (
                    <div className="border-t border-line bg-[#101217]">
                        <HighlightedCode code={code} activeLine={frame.line} />
                    </div>
                )}
            </div>
            <div className="flex flex-wrap items-center gap-2 border-t border-line px-4 py-3">
                <ControlButton label="Back to the start" onClick={() => { setPlaying(false); setIndex(0); }} disabled={index === 0}>
                    <RotateCcw size={16} aria-hidden="true" />
                </ControlButton>
                <ControlButton label="Previous step" onClick={() => { setPlaying(false); setIndex((value) => Math.max(0, value - 1)); }} disabled={index === 0}>
                    <SkipBack size={16} aria-hidden="true" />
                </ControlButton>
                <button
                    type="button"
                    onClick={() => {
                        if (atEnd) setIndex(0);
                        setPlaying(atEnd || !isPlaying);
                    }}
                    aria-label={isPlaying ? 'Pause' : 'Play'}
                    className="swift-gradient flex h-10 w-10 items-center justify-center rounded-full text-ink"
                >
                    {isPlaying ? <Pause size={17} aria-hidden="true" /> : <Play size={17} aria-hidden="true" />}
                </button>
                <ControlButton label="Next step" onClick={() => { setPlaying(false); setIndex((value) => Math.min(frames.length - 1, value + 1)); }} disabled={atEnd}>
                    <SkipForward size={16} aria-hidden="true" />
                </ControlButton>
                <input
                    type="range"
                    min={0}
                    max={frames.length - 1}
                    value={index}
                    onChange={(event) => { setPlaying(false); setIndex(Number(event.target.value)); }}
                    aria-label="Step"
                    className="mx-2 min-w-24 flex-1 accent-[var(--color-amber)]"
                />
                <div role="group" aria-label="Speed" className="flex rounded-full bg-white/8 p-0.5">
                    {SPEEDS.map((option, at) => (
                        <button key={option.label} type="button" onClick={() => setSpeed(at)} aria-pressed={speed === at} className={`h-9 rounded-full px-2.5 font-mono text-xs ${speed === at ? 'bg-white/15 text-paper' : 'text-muted'}`}>
                            {option.label}
                        </button>
                    ))}
                </div>
            </div>
        </figure>
    );
};

export default Player;
