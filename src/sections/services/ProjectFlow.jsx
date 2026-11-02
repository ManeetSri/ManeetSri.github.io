import { useEffect, useRef, useState } from 'react';
import { AnimatePresence, motion, useInView, useReducedMotion } from 'framer-motion';
import { ArrowRight, Check, CircleHelp, Code2, Compass, Hammer, Lightbulb, Plug, RefreshCcw, Rocket, Undo2 } from 'lucide-react';
import { useIsDesktop } from '../../hooks/useIsDesktop';
import { track } from '../../analytics';

const STEP_MS = 2800;

// A two-row path: left to right, then back right to left, so "Ready?" sits directly under "Build"
const STEPS = [
    { id: 'idea', label: 'Idea', icon: Lightbulb, col: 0, row: 0, title: 'Start with the problem', body: 'We pin down who the app is for and what the first version really has to do.', gives: 'A clear first-version scope' },
    { id: 'plan', label: 'Architecture', icon: Compass, col: 1, row: 0, title: 'Plan the architecture', body: 'The screens, data model, API contracts and structure, such as MVVM, before writing feature code.', gives: 'A screen map and technical plan' },
    { id: 'build', label: 'Build', icon: Code2, col: 2, row: 0, title: 'Build it, feature by feature', body: 'SwiftUI, UIKit or React Native, with something you can try early and often.', gives: 'Working builds to try on your phone' },
    { id: 'integrate', label: 'Integrate', icon: Plug, col: 3, row: 0, title: 'Connect the services', body: 'Maps, payments, push notifications, Firebase and real-time updates, wired into the app.', gives: 'The real services, working together' },
    { id: 'test', label: 'Test', icon: Hammer, col: 3, row: 1, title: 'Test and profile', body: 'Hunting bugs and slow spots with tools like Xcode Instruments before anyone else finds them.', gives: 'Issues found and fixed before launch' },
    { id: 'ready', label: 'Ready?', icon: CircleHelp, col: 2, row: 1, decision: true, title: 'Ready to ship?', body: 'The honest check. Your call: send it back to Build, or move on to release.', gives: 'A clear go or no-go' },
    { id: 'release', label: 'App Store', icon: Rocket, col: 1, row: 1, title: 'Release to the App Store', body: 'A submission that follows App Store policies, so it reaches people without surprises.', gives: 'Your app, live on the App Store' },
    { id: 'improve', label: 'Improve', icon: RefreshCcw, col: 0, row: 1, title: 'Learn and improve', body: 'Real usage shapes the fixes and the next version, which starts the loop again.', gives: 'Priorities for the next version' },
];

const EDGES = [
    { id: 'idea-plan', from: 'idea', to: 'plan' },
    { id: 'plan-build', from: 'plan', to: 'build' },
    { id: 'build-integrate', from: 'build', to: 'integrate' },
    { id: 'integrate-test', from: 'integrate', to: 'test' },
    { id: 'test-ready', from: 'test', to: 'ready' },
    { id: 'ready-release', from: 'ready', to: 'release', label: 'Yes' },
    { id: 'release-improve', from: 'release', to: 'improve' },
    { id: 'ready-build', from: 'ready', to: 'build', loop: true, label: 'Not yet' },
    { id: 'improve-build', from: 'improve', to: 'build', loop: true, curve: true, label: 'Next version' },
];

const LAYOUTS = {
    wide: { width: 640, height: 280, radius: 30 },
    tall: { width: 320, height: 214, radius: 24 },
};

const stepById = (id) => STEPS.find((step) => step.id === id);

const nodeCenter = (step, { width, height }) => ({
    x: (width / 4) * (step.col + 0.5),
    y: step.row === 0 ? height * 0.17 : height * 0.68,
});

// Lines stop at the edge of each node, so their arrowheads stay visible
const edgePath = (edge, layout) => {
    const { radius } = layout;
    const a = nodeCenter(stepById(edge.from), layout);
    const b = nodeCenter(stepById(edge.to), layout);
    if (edge.curve) {
        const startY = a.y - radius - 2;
        const endX = b.x - radius * 0.8;
        const endY = b.y + radius * 0.8;
        const midY = (startY + endY) / 2;
        return `M${a.x} ${startY} C${a.x} ${midY} ${endX - radius} ${midY + radius * 0.6} ${endX} ${endY}`;
    }
    const length = Math.hypot(b.x - a.x, b.y - a.y);
    const ux = (b.x - a.x) / length;
    const uy = (b.y - a.y) / length;
    const startGap = radius + 2;
    // Labels sit under each node on the top row, so upward lines stop short of them
    const endGap = edge.id === 'ready-build' ? radius + 22 : radius + 5;
    const fromGap = edge.from === 'integrate' ? radius + 22 : startGap;
    return `M${a.x + ux * fromGap} ${a.y + uy * fromGap} L${b.x - ux * endGap} ${b.y - uy * endGap}`;
};

const labelPosition = (edge, layout) => {
    const a = nodeCenter(stepById(edge.from), layout);
    const b = nodeCenter(stepById(edge.to), layout);
    if (edge.curve) return { x: (a.x + b.x) / 2 - 62, y: (a.y + b.y) / 2 + 26 };
    if (edge.id === 'ready-build') return { x: b.x + 7, y: (a.y + b.y) / 2 + 12, anchor: 'start' };
    return { x: (a.x + b.x) / 2, y: a.y - 8 };
};

const ProjectFlow = () => {
    const isDesktop = useIsDesktop();
    const reduceMotion = useReducedMotion();
    const layout = LAYOUTS[isDesktop ? 'wide' : 'tall'];
    const { radius } = layout;

    const containerRef = useRef(null);
    const inView = useInView(containerRef, { amount: 0.4 });
    const [activeId, setActiveId] = useState('idea');
    const [litEdgeId, setLitEdgeId] = useState(null);
    const [minorVersion, setMinorVersion] = useState(0);
    const [userTookOver, setUserTookOver] = useState(false);

    const active = stepById(activeId);
    const activeIndex = STEPS.indexOf(active);
    const nextStep = STEPS[activeIndex + 1];

    // Walks the path once by itself, then waits. Any tap hands control to the visitor.
    useEffect(() => {
        if (!inView || userTookOver || reduceMotion) return undefined;
        const timer = setInterval(() => {
            const next = STEPS[activeIndex + 1];
            if (!next) {
                setUserTookOver(true);
                return;
            }
            setActiveId(next.id);
            setLitEdgeId(EDGES.find((edge) => !edge.loop && edge.to === next.id)?.id ?? null);
        }, STEP_MS);
        return () => clearInterval(timer);
    }, [inView, userTookOver, reduceMotion, activeIndex]);

    const goTo = (id, edgeId = null) => {
        setUserTookOver(true);
        setActiveId(id);
        setLitEdgeId(edgeId ?? EDGES.find((edge) => !edge.loop && edge.to === id)?.id ?? null);
    };

    const select = (id) => {
        track('flow_step_select', { step: id });
        goTo(id);
    };

    const decide = (choice, id, edgeId) => {
        track('flow_decision', { choice });
        if (choice === 'next_version') setMinorVersion((version) => version + 1);
        goTo(id, edgeId);
    };

    return (
        <div ref={containerRef} className="grid overflow-hidden rounded-[2rem] border border-line bg-surface lg:grid-cols-[minmax(0,8fr)_minmax(0,4fr)]">
            <div className="flex min-w-0 items-center p-3 sm:p-5">
                <div className="relative w-full" style={{ aspectRatio: `${layout.width} / ${layout.height}` }}>
                    <svg aria-hidden="true" viewBox={`0 0 ${layout.width} ${layout.height}`} className="absolute inset-0 h-full w-full overflow-visible">
                        <defs>
                            <marker id="flow-arrow" viewBox="0 0 8 8" refX="6" refY="4" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
                                <path d="M0 0 L8 4 L0 8 z" fill="rgba(242,240,235,0.45)" />
                            </marker>
                            <marker id="flow-arrow-lit" viewBox="0 0 8 8" refX="6" refY="4" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
                                <path d="M0 0 L8 4 L0 8 z" fill="var(--color-amber)" />
                            </marker>
                        </defs>
                        {EDGES.map((edge) => {
                            const isLit = edge.id === litEdgeId;
                            const d = edgePath(edge, layout);
                            const position = edge.label ? labelPosition(edge, layout) : null;
                            return (
                                <g key={edge.id}>
                                    <path
                                        d={d}
                                        fill="none"
                                        stroke={isLit ? 'var(--color-amber)' : 'rgba(242,240,235,0.28)'}
                                        strokeWidth={isLit ? 2.5 : 1.5}
                                        strokeDasharray={edge.loop ? '4 5' : undefined}
                                        markerEnd={`url(#flow-arrow${isLit ? '-lit' : ''})`}
                                    />
                                    {isLit && !reduceMotion && (
                                        <circle r="4" fill="var(--color-amber)">
                                            <animateMotion dur="1s" repeatCount="indefinite" path={d} />
                                        </circle>
                                    )}
                                    {edge.label && isDesktop && (
                                        <text x={position.x} y={position.y} textAnchor={position.anchor ?? 'middle'} fill={isLit ? 'var(--color-amber)' : 'var(--color-muted)'} fontSize="12" fontFamily="var(--font-mono)" stroke="var(--color-surface)" strokeWidth="5" paintOrder="stroke">
                                            {edge.label}
                                        </text>
                                    )}
                                </g>
                            );
                        })}
                    </svg>

                    {STEPS.map((step, index) => {
                        const { x, y } = nodeCenter(step, layout);
                        const isActive = step.id === activeId;
                        const isDone = index < activeIndex;
                        const Icon = step.icon;
                        const size = radius * 2;
                        const nodeTone = isActive
                            ? 'swift-gradient border-transparent text-ink'
                            : isDone
                                ? 'border-amber/50 bg-amber/10 text-amber'
                                : 'border-line bg-raised text-paper group-hover:bg-white/10';
                        return (
                            <button
                                key={step.id}
                                type="button"
                                onClick={() => select(step.id)}
                                aria-pressed={isActive}
                                aria-label={`${step.label}: ${step.title}`}
                                className="group absolute flex -translate-x-1/2 flex-col items-center"
                                style={{ left: `${(x / layout.width) * 100}%`, top: `${((y - radius) / layout.height) * 100}%` }}
                            >
                                <motion.span
                                    animate={{ scale: isActive ? 1.1 : 1 }}
                                    transition={{ type: 'spring', stiffness: 400, damping: 22 }}
                                    className={`relative flex items-center justify-center transition-colors ${step.decision ? (isActive ? 'text-ink' : isDone ? 'text-amber' : 'text-paper') : `rounded-full border ${nodeTone}`}`}
                                    style={{ width: size, height: size }}
                                >
                                    {step.decision && (
                                        <span
                                            aria-hidden="true"
                                            className={`absolute -inset-1 ${isActive ? 'swift-gradient' : isDone ? 'bg-[#3a2a1a]' : 'bg-raised'}`}
                                            style={{ clipPath: 'polygon(50% 0, 100% 50%, 50% 100%, 0 50%)' }}
                                        />
                                    )}
                                    {isDone && !step.decision
                                        ? <Check size={radius * 0.75} strokeWidth={3} aria-hidden="true" className="relative" />
                                        : <Icon size={radius * 0.75} aria-hidden="true" className="relative" />}
                                </motion.span>
                                <span className={`mt-1 whitespace-nowrap text-xs font-medium lg:mt-1.5 lg:text-[13px] ${isActive ? 'text-paper' : 'text-muted'}`}>{step.label}</span>
                            </button>
                        );
                    })}
                </div>
            </div>

            {/* The current step, with what to do next */}
            <div className="flex min-h-[236px] min-w-0 flex-col border-t border-line bg-ink/40 p-4 sm:p-5 lg:border-l lg:border-t-0" aria-live={userTookOver ? 'polite' : 'off'}>
                <div className="flex items-center justify-between font-mono text-xs text-muted">
                    <span>Step {activeIndex + 1} of {STEPS.length}</span>
                    <span className="rounded-full bg-white/8 px-2 py-0.5 text-amber">v1.{minorVersion}</span>
                </div>

                <AnimatePresence mode="wait" initial={false}>
                    <motion.div
                        key={active.id}
                        initial={{ opacity: 0, y: 8 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -8 }}
                        transition={{ duration: 0.16 }}
                        className="mt-2"
                    >
                        <p className="font-display text-xl font-semibold leading-tight tracking-tight">{active.title}</p>
                        <p className="mt-1.5 text-sm leading-snug text-muted">{active.body}</p>
                        <p className="mt-2 flex items-start gap-1.5 text-[13px] leading-snug text-paper/90">
                            <Check size={15} className="mt-0.5 shrink-0 text-[#30D158]" aria-hidden="true" /> {active.gives}
                        </p>
                    </motion.div>
                </AnimatePresence>

                <div className="mt-auto grid gap-2 pt-3">
                    {active.id === 'ready' && (
                        <>
                            <button type="button" onClick={() => decide('ship', 'release', 'ready-release')} className="swift-gradient flex h-11 items-center justify-center gap-2 rounded-full text-sm font-semibold text-ink">
                                <Rocket size={16} aria-hidden="true" /> Yes, ship it
                            </button>
                            <button type="button" onClick={() => decide('not_yet', 'build', 'ready-build')} className="flex h-11 items-center justify-center gap-2 rounded-full bg-white/10 text-sm font-semibold hover:bg-white/15">
                                <Undo2 size={16} aria-hidden="true" /> Not yet, back to Build
                            </button>
                        </>
                    )}
                    {active.id === 'improve' && (
                        <button type="button" onClick={() => decide('next_version', 'build', 'improve-build')} className="swift-gradient flex h-11 items-center justify-center gap-2 rounded-full text-sm font-semibold text-ink">
                            <RefreshCcw size={16} aria-hidden="true" /> Start v1.{minorVersion + 1}
                        </button>
                    )}
                    {active.id !== 'ready' && active.id !== 'improve' && nextStep && (
                        <button type="button" onClick={() => select(nextStep.id)} className="flex h-11 items-center justify-center gap-2 rounded-full bg-white/10 text-sm font-semibold hover:bg-white/15">
                            Next: {nextStep.label} <ArrowRight size={16} aria-hidden="true" />
                        </button>
                    )}
                </div>
            </div>
        </div>
    );
};

export default ProjectFlow;
