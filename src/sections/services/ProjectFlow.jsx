import { useEffect, useRef, useState } from 'react';
import { AnimatePresence, motion, useInView, useReducedMotion } from 'framer-motion';
import { useIsDesktop } from '../../hooks/useIsDesktop';
import { track } from '../../analytics';

const STEP_MS = 2800;

const STEPS = [
    { id: 'idea', label: 'Idea', title: 'Start with the problem', body: 'We pin down who the app is for and what the first version really has to do.', wide: { x: 75, y: 70 }, tall: { y: 34 } },
    { id: 'plan', label: 'Architecture', title: 'Plan the architecture', body: 'The screens, data model, API contracts and structure, such as MVVM, before writing feature code.', wide: { x: 215, y: 70 }, tall: { y: 114 } },
    { id: 'build', label: 'Build', title: 'Build it, feature by feature', body: 'SwiftUI, UIKit or React Native, with something you can try early and often.', wide: { x: 355, y: 70 }, tall: { y: 194 } },
    { id: 'integrate', label: 'Integrate', title: 'Connect the services', body: 'Maps, payments, push notifications, Firebase and real-time updates, wired into the app.', wide: { x: 495, y: 70 }, tall: { y: 274 } },
    { id: 'test', label: 'Test', title: 'Test and profile', body: 'Hunting bugs and slow spots with tools like Xcode Instruments before anyone else finds them.', wide: { x: 635, y: 70 }, tall: { y: 354 } },
    { id: 'ready', label: 'Ready?', title: 'Ready to ship?', body: 'If it isn\'t, it goes back to Build. If it is, it moves on to release.', decision: true, wide: { x: 785, y: 70 }, tall: { y: 434 } },
    { id: 'release', label: 'App Store', title: 'Release to the App Store', body: 'A submission that follows App Store policies, so it reaches people without surprises.', wide: { x: 785, y: 190 }, tall: { y: 514 } },
    { id: 'improve', label: 'Improve', title: 'Learn and improve', body: 'Real usage shapes fixes and the next version, which starts the loop again.', wide: { x: 495, y: 190 }, tall: { y: 594 } },
];

const LAYOUTS = {
    wide: { width: 860, height: 240 },
    tall: { width: 340, height: 640 },
};
const TALL_X = 170;

// `to` is the step this line leads into, so the line lights up when that step is active
const EDGES = [
    { id: 'idea-plan', to: 'plan', wide: 'M75 70 L215 70', tall: 'M170 34 L170 114' },
    { id: 'plan-build', to: 'build', wide: 'M215 70 L355 70', tall: 'M170 114 L170 194' },
    { id: 'build-integrate', to: 'integrate', wide: 'M355 70 L495 70', tall: 'M170 194 L170 274' },
    { id: 'integrate-test', to: 'test', wide: 'M495 70 L635 70', tall: 'M170 274 L170 354' },
    { id: 'test-ready', to: 'ready', wide: 'M635 70 L785 70', tall: 'M170 354 L170 434' },
    { id: 'ready-release', to: 'release', wide: 'M785 70 L785 190', tall: 'M170 434 L170 514' },
    { id: 'release-improve', to: 'improve', wide: 'M785 190 L495 190', tall: 'M170 514 L170 594' },
    { id: 'ready-build', to: 'none', dashed: true, wide: 'M785 45 C785 2 355 2 355 45', tall: 'M170 434 C334 434 334 194 170 194' },
    { id: 'improve-build', to: 'none', dashed: true, wide: 'M495 190 C355 190 355 150 355 70', tall: 'M170 594 C6 594 6 194 170 194' },
];

const LABELS = [
    { text: 'Yes', wide: { x: 806, y: 134 }, tall: { x: 190, y: 480 } },
    { text: 'No, back to Build', wide: { x: 570, y: 16 }, tall: { x: 262, y: 312 } },
    { text: 'Next version', wide: { x: 372, y: 150 }, tall: { x: 62, y: 400 } },
];

const ProjectFlow = () => {
    const isDesktop = useIsDesktop();
    const reduceMotion = useReducedMotion();
    const layoutKey = isDesktop ? 'wide' : 'tall';
    const { width, height } = LAYOUTS[layoutKey];

    const containerRef = useRef(null);
    const inView = useInView(containerRef, { amount: 0.3 });
    const [activeId, setActiveId] = useState('idea');
    const [userTookOver, setUserTookOver] = useState(false);
    const active = STEPS.find((step) => step.id === activeId);

    // Walks through the chart by itself until the visitor picks a step
    useEffect(() => {
        if (!inView || userTookOver || reduceMotion) return undefined;
        const timer = setInterval(() => {
            setActiveId((current) => STEPS[(STEPS.findIndex((step) => step.id === current) + 1) % STEPS.length].id);
        }, STEP_MS);
        return () => clearInterval(timer);
    }, [inView, userTookOver, reduceMotion]);

    const position = (step) => (isDesktop ? step.wide : { x: TALL_X, y: step.tall.y });

    return (
        <div ref={containerRef} className="rounded-[2rem] border border-line bg-surface p-4 sm:p-6">
            <div className="relative w-full" style={{ aspectRatio: `${width} / ${height}` }}>
                <svg aria-hidden="true" viewBox={`0 0 ${width} ${height}`} className="absolute inset-0 h-full w-full overflow-visible">
                    {EDGES.map((edge) => {
                        const isLit = edge.to === activeId;
                        return (
                            <g key={edge.id}>
                                <motion.path
                                    d={edge[layoutKey]}
                                    fill="none"
                                    stroke={isLit ? 'var(--color-amber)' : edge.dashed ? 'rgba(242,240,235,0.28)' : 'rgba(242,240,235,0.22)'}
                                    strokeWidth={isLit ? 3 : 2}
                                    strokeDasharray={edge.dashed ? '5 6' : undefined}
                                    initial={edge.dashed ? false : { pathLength: 0 }}
                                    whileInView={edge.dashed ? undefined : { pathLength: 1 }}
                                    viewport={{ once: true }}
                                    transition={{ duration: 0.7 }}
                                />
                                {isLit && !reduceMotion && (
                                    <circle r="5" fill="var(--color-amber)">
                                        <animateMotion dur="1.1s" repeatCount="indefinite" path={edge[layoutKey]} />
                                    </circle>
                                )}
                            </g>
                        );
                    })}
                    {LABELS.map(({ text, ...places }) => (
                        <text key={text} x={places[layoutKey].x} y={places[layoutKey].y} textAnchor="middle" fill="var(--color-muted)" fontSize={isDesktop ? 13 : 12} fontFamily="var(--font-mono)" stroke="var(--color-surface)" strokeWidth="7" paintOrder="stroke">
                            {text}
                        </text>
                    ))}
                </svg>

                {STEPS.map((step) => {
                    const { x, y } = position(step);
                    const isActive = step.id === activeId;
                    return (
                        <motion.button
                            key={step.id}
                            type="button"
                            whileTap={{ scale: 0.95 }}
                            onClick={() => {
                                track('flow_step_select', { step: step.id });
                                setUserTookOver(true);
                                setActiveId(step.id);
                            }}
                            aria-pressed={isActive}
                            className={`absolute flex -translate-x-1/2 -translate-y-1/2 items-center justify-center text-sm font-semibold transition-colors ${step.decision ? 'h-[60px] w-[104px]' : 'h-12 w-[116px] rounded-2xl border lg:w-[13%]'} ${!step.decision && (isActive ? 'border-transparent' : 'border-line')} ${isActive ? 'text-ink' : 'text-paper'} ${!step.decision && !isActive ? 'bg-raised hover:bg-white/10' : ''} ${!step.decision && isActive ? 'swift-gradient' : ''}`}
                            style={{ left: `${(x / width) * 100}%`, top: `${(y / height) * 100}%` }}
                        >
                            {step.decision && (
                                <span
                                    aria-hidden="true"
                                    className={`absolute inset-0 ${isActive ? 'swift-gradient' : 'bg-raised'}`}
                                    style={{ clipPath: 'polygon(50% 0, 100% 50%, 50% 100%, 0 50%)' }}
                                />
                            )}
                            <span className="relative">{step.label}</span>
                        </motion.button>
                    );
                })}
            </div>

            <div className="mt-5 min-h-[92px] rounded-2xl bg-ink p-4" aria-live={userTookOver ? 'polite' : 'off'}>
                <AnimatePresence mode="wait" initial={false}>
                    <motion.div
                        key={active.id}
                        initial={{ opacity: 0, y: 8 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -8 }}
                        transition={{ duration: 0.18 }}
                    >
                        <p className="font-semibold">{active.title}</p>
                        <p className="mt-1 text-sm leading-relaxed text-muted">{active.body}</p>
                    </motion.div>
                </AnimatePresence>
            </div>
        </div>
    );
};

export default ProjectFlow;
