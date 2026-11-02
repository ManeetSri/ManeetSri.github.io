import { useEffect, useRef, useState } from 'react';
import { motion } from 'framer-motion';
import { Check } from 'lucide-react';
import { markPlayed } from './loaderSession';

const LOG = [
    'Compiling Synclovis.swift',
    'Compiling JamTech.swift',
    'Compiling Singsys.swift',
    'Compiling Codeflies.swift',
    'Compiling MahindraLogistics.swift',
    'Linking Maneet.app',
    'Signing for iPhone',
];

const LINE_MS = 130;
const SUCCESS_AT = LINE_MS * LOG.length + 60;
const MORPH_AT = SUCCESS_AT + 340;
const DONE_AT = MORPH_AT + 520;

const PILL = { width: 232, height: 40 };

const BuildLoader = ({ onDone }) => {
    const [lines, setLines] = useState(0);
    const [phase, setPhase] = useState('building');
    const [target, setTarget] = useState(null);
    const [start] = useState(() => ({
        left: (window.innerWidth - PILL.width) / 2,
        top: Math.max(24, window.innerHeight / 2 - 150),
        ...PILL,
    }));

    const onDoneRef = useRef(onDone);
    useEffect(() => {
        onDoneRef.current = onDone;
    });

    // Timers rather than animation callbacks, so a page opened in a background tab can't get stuck here
    useEffect(() => {
        markPlayed();
        document.documentElement.style.overflow = 'hidden';

        const lineTimer = setInterval(() => setLines((count) => Math.min(count + 1, LOG.length)), LINE_MS);
        const successTimer = setTimeout(() => setPhase('success'), SUCCESS_AT);
        const morphTimer = setTimeout(() => {
            const island = document.querySelector('[data-island]')?.getBoundingClientRect();
            if (island && island.top < window.innerHeight && island.width > 0) {
                setTarget({ left: island.left, top: island.top, width: island.width, height: island.height });
            }
            setPhase('morph');
        }, MORPH_AT);
        const doneTimer = setTimeout(() => onDoneRef.current(), DONE_AT);

        const skip = () => onDoneRef.current();
        window.addEventListener('keydown', skip);
        window.addEventListener('pointerdown', skip);

        return () => {
            clearInterval(lineTimer);
            clearTimeout(successTimer);
            clearTimeout(morphTimer);
            clearTimeout(doneTimer);
            window.removeEventListener('keydown', skip);
            window.removeEventListener('pointerdown', skip);
            document.documentElement.style.overflow = '';
        };
    }, []);

    const morphing = phase === 'morph';
    const progress = phase === 'building' ? (lines / LOG.length) * 0.92 : 1;

    return (
        <div role="status" aria-label="Loading portfolio" className="fixed inset-0 z-[100]">
            <motion.div
                initial={false}
                animate={{ opacity: morphing ? 0 : 1 }}
                transition={{ duration: 0.4 }}
                className="absolute inset-0 bg-ink"
            />

            <motion.div
                initial={false}
                animate={{ opacity: morphing ? 0 : 1 }}
                transition={{ duration: 0.2 }}
                aria-hidden="true"
                className="absolute inset-x-6 font-mono text-xs sm:text-sm"
                style={{ top: start.top + PILL.height + 20 }}
            >
                <div className="mx-auto max-w-sm">
                    <div className="mb-4 h-[3px] overflow-hidden rounded-full bg-line">
                        <motion.div
                            initial={{ scaleX: 0 }}
                            animate={{ scaleX: progress }}
                            transition={{ duration: 0.15, ease: 'linear' }}
                            className="swift-gradient h-full origin-left"
                        />
                    </div>
                    <div className="h-60 space-y-1.5 text-muted">
                        {LOG.slice(0, lines).map((line) => (
                            <p key={line}>{line}</p>
                        ))}
                        {phase !== 'building' && (
                            <p className="flex items-center gap-1.5 pt-1 font-semibold text-[#30D158]">
                                <Check size={15} aria-hidden="true" /> Build Succeeded
                            </p>
                        )}
                    </div>
                    <p className="text-muted/70">Press any key to skip</p>
                </div>
            </motion.div>

            {/* Lands exactly on the hero phone's Dynamic Island */}
            <motion.div
                aria-hidden="true"
                initial={false}
                animate={morphing && target ? { ...target, opacity: 1 } : { ...start, opacity: morphing ? 0 : 1 }}
                transition={{ duration: 0.45, ease: [0.4, 0, 0.1, 1] }}
                className={`fixed flex items-center justify-center overflow-hidden whitespace-nowrap rounded-full border font-mono text-sm ${morphing ? 'border-transparent bg-black' : 'border-line bg-surface'}`}
            >
                <motion.span initial={false} animate={{ opacity: morphing ? 0 : 1 }} transition={{ duration: 0.12 }}>
                    <span className="text-amber">Maneet</span>
                    <span className="text-muted"> › </span>
                    <span>iPhone</span>
                </motion.span>
            </motion.div>
        </div>
    );
};

export default BuildLoader;
