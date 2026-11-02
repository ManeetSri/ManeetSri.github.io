import { useEffect, useRef, useState } from 'react';
import { motion, useSpring, useTransform } from 'framer-motion';
import { Check } from 'lucide-react';
import { markPlayed } from './loaderSession';
import { track } from '../analytics';

const STEPS = [
    { label: 'Compiling Synclovis.swift', note: '2022', ms: 320 },
    { label: 'Compiling JamTech.swift', note: '2023', ms: 280 },
    { label: 'Compiling Singsys.swift', note: '2024', ms: 400 },
    { label: 'Compiling Codeflies.swift', note: '2025', ms: 260 },
    { label: 'Compiling MahindraLogistics.swift', note: 'Now', ms: 360 },
    { label: 'Linking Maneet.app', ms: 240 },
    { label: 'Signing for iPhone', ms: 200 },
];

const BUILD_MS = STEPS.reduce((total, step) => total + step.ms, 0);
const SUCCESS_AT = BUILD_MS + 100;
const MORPH_AT = SUCCESS_AT + 600;
const LANDED_AT = MORPH_AT + 650;
const DONE_AT = LANDED_AT + 560;

const PILL = { width: 232, height: 40 };
const GROUP_HEIGHT = 430;
const FLY_EASE = [0.65, 0, 0.2, 1];

const StepRow = ({ step, state }) => (
    <div
        className={`flex h-7 items-center gap-2.5 transition-opacity duration-200 ${state === 'waiting' ? 'opacity-0' : 'opacity-100'}`}
    >
        <span className="flex h-4 w-4 shrink-0 items-center justify-center">
            {state === 'active' && <span className="h-3.5 w-3.5 animate-spin rounded-full border-2 border-amber border-t-transparent" />}
            {state === 'done' && (
                <motion.span initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ type: 'spring', stiffness: 500, damping: 22 }}>
                    <Check size={15} strokeWidth={3} className="text-[#30D158]" />
                </motion.span>
            )}
        </span>
        <span className={`min-w-0 flex-1 truncate ${state === 'active' ? 'text-paper' : 'text-muted'}`}>{step.label}</span>
        {step.note && <span className="text-muted/70">{step.note}</span>}
    </div>
);

const BuildLoader = ({ onReady, onDone }) => {
    const [current, setCurrent] = useState(0);
    const [phase, setPhase] = useState('building');
    const [target, setTarget] = useState(null);
    const [start] = useState(() => ({
        left: (window.innerWidth - PILL.width) / 2,
        top: Math.max(20, (window.innerHeight - GROUP_HEIGHT) / 2),
        ...PILL,
    }));

    const percent = useSpring(0, { stiffness: 140, damping: 24 });
    const percentLabel = useTransform(percent, (value) => `${Math.min(100, Math.round(value))}`);
    const barScale = useTransform(percent, [0, 100], [0, 1]);
    const glowOpacity = useTransform(percent, [0, 100], [0.05, 0.9]);
    const glowScale = useTransform(percent, [0, 100], [0.6, 1.15]);

    const callbacks = useRef({ onReady, onDone });
    useEffect(() => {
        callbacks.current = { onReady, onDone };
    });

    // Timers rather than animation callbacks, so a page opened in a background tab can't get stuck here
    useEffect(() => {
        markPlayed();
        document.documentElement.style.overflow = 'hidden';

        let elapsed = 0;
        const timers = STEPS.map((step, index) => {
            elapsed += step.ms;
            return setTimeout(() => {
                setCurrent(index + 1);
                percent.set(((index + 1) / STEPS.length) * 100);
            }, elapsed);
        });
        timers.push(setTimeout(() => setPhase('success'), SUCCESS_AT));
        timers.push(setTimeout(() => {
            const island = document.querySelector('[data-island]')?.getBoundingClientRect();
            if (island && island.top < window.innerHeight && island.width > 0) {
                setTarget({ left: island.left, top: island.top, width: island.width, height: island.height });
            }
            setPhase('morph');
        }, MORPH_AT));
        timers.push(setTimeout(() => {
            setPhase('landed');
            callbacks.current.onReady();
        }, LANDED_AT));
        timers.push(setTimeout(() => {
            track('loader_complete', { skipped: false });
            callbacks.current.onDone();
        }, DONE_AT));

        const skip = () => {
            track('loader_complete', { skipped: true });
            callbacks.current.onReady();
            callbacks.current.onDone();
        };
        window.addEventListener('keydown', skip);
        window.addEventListener('pointerdown', skip);

        return () => {
            timers.forEach(clearTimeout);
            window.removeEventListener('keydown', skip);
            window.removeEventListener('pointerdown', skip);
            document.documentElement.style.overflow = '';
        };
    }, [percent]);

    const leaving = phase === 'morph' || phase === 'landed';
    const landed = phase === 'landed';
    const succeeded = phase !== 'building';

    return (
        <div role="status" aria-label="Loading portfolio" className="fixed inset-0 z-[100] overflow-hidden">
            <motion.div
                initial={false}
                animate={{ opacity: leaving ? 0 : 1 }}
                transition={{ duration: 0.5, delay: leaving ? 0.15 : 0 }}
                className="absolute inset-0 bg-ink"
            />

            <motion.div
                aria-hidden="true"
                initial={false}
                animate={{ opacity: leaving ? 0 : 1 }}
                transition={{ duration: 0.25 }}
                className="absolute inset-0"
            >
                <motion.div
                    style={{ opacity: glowOpacity, scale: glowScale }}
                    className="absolute left-1/2 top-1/2 h-[720px] w-[720px] -translate-x-1/2 -translate-y-1/2 bg-[radial-gradient(closest-side,rgba(240,81,56,0.22),transparent)]"
                />

                <div className="absolute inset-x-6" style={{ top: start.top + PILL.height + 18 }}>
                    <div className="mx-auto max-w-sm font-mono text-sm">
                        <div className="flex h-[72px] items-end">
                            {succeeded ? (
                                <motion.p
                                    initial={{ opacity: 0, y: 14, scale: 0.92 }}
                                    animate={{ opacity: 1, y: 0, scale: 1 }}
                                    transition={{ type: 'spring', stiffness: 320, damping: 20 }}
                                    className="flex origin-left items-center gap-3 font-display text-[2.1rem] font-semibold leading-none tracking-tight text-[#30D158]"
                                >
                                    <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-[#30D158]">
                                        <Check size={22} strokeWidth={3.5} className="text-ink" />
                                    </span>
                                    Build Succeeded
                                </motion.p>
                            ) : (
                                <p className="font-display text-7xl font-semibold leading-none tracking-tight tabular-nums">
                                    <motion.span>{percentLabel}</motion.span><span className="swift-gradient-text">%</span>
                                </p>
                            )}
                        </div>

                        <div className="mb-3 mt-4 h-[3px] overflow-hidden rounded-full bg-line">
                            <motion.div style={{ scaleX: barScale }} className="swift-gradient h-full origin-left" />
                        </div>

                        <div>
                            {STEPS.map((step, index) => {
                                const state = index < current ? 'done' : index === current ? 'active' : 'waiting';
                                return <StepRow key={step.label} step={step} state={state} />;
                            })}
                        </div>

                        <p className="mt-4 text-muted/70">Tap or press any key to skip</p>
                    </div>
                </div>
            </motion.div>

            {/* Rings ripple out of the Dynamic Island as the pill lands on it */}
            {landed && target && [0, 1, 2].map((ring) => (
                <motion.span
                    key={ring}
                    aria-hidden="true"
                    initial={{ scale: 0.6, opacity: 0.8 }}
                    animate={{ scale: 9, opacity: 0 }}
                    transition={{ duration: 0.6, delay: ring * 0.09, ease: 'easeOut' }}
                    className="absolute rounded-full border-2 border-swift"
                    style={{
                        left: target.left + (target.width - target.height) / 2,
                        top: target.top,
                        width: target.height,
                        height: target.height,
                    }}
                />
            ))}

            {/* Lands exactly on the hero phone's Dynamic Island */}
            <motion.div
                aria-hidden="true"
                initial={false}
                animate={{
                    ...(leaving && target ? target : start),
                    opacity: leaving && !target ? 0 : 1,
                    scale: landed ? [1, 1.2, 0.96, 1] : 1,
                }}
                transition={{ duration: 0.65, ease: FLY_EASE, scale: { duration: 0.42 } }}
                className={`fixed flex items-center justify-center overflow-hidden whitespace-nowrap rounded-full border font-mono text-sm ${leaving ? 'border-transparent bg-black' : 'border-line bg-surface'}`}
            >
                {/* Glows while flying, then settles into the black of the Dynamic Island */}
                <motion.span
                    initial={false}
                    animate={{ opacity: leaving && !landed ? 1 : 0 }}
                    transition={{ duration: landed ? 0.35 : 0.15 }}
                    className="swift-gradient absolute inset-0"
                />
                <motion.span initial={false} animate={{ opacity: leaving ? 0 : 1 }} transition={{ duration: 0.15 }} className="relative">
                    <span className="text-amber">Maneet</span>
                    <span className="text-muted"> › </span>
                    <span>iPhone</span>
                </motion.span>
            </motion.div>
        </div>
    );
};

export default BuildLoader;
