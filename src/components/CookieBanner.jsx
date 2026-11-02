import { useEffect, useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { Cookie } from 'lucide-react';
import { applyConsent, track } from '../analytics';
import { getConsent, needsChoice, onOpenCookieSettings } from '../analytics/consent';
import { isLoaderPlaying, onLoaderFinished } from './loaderSession';

const OPTIONS = [
    { id: 'analytics', label: 'Analytics', detail: 'Google Analytics and Firebase: visits, pages, device, location by country and how the site performs.' },
    { id: 'ads', label: 'Advertising', detail: 'Google advertising features: measuring ads and personalizing them across Google services. Also turns on Analytics.' },
];

const Toggle = ({ checked, onChange, label }) => (
    <button
        type="button"
        role="switch"
        aria-checked={checked}
        aria-label={label}
        onClick={() => onChange(!checked)}
        className={`relative h-[31px] w-[51px] shrink-0 rounded-full transition-colors ${checked ? 'bg-[#30D158]' : 'bg-white/20'}`}
    >
        <motion.span
            initial={false}
            animate={{ x: checked ? 22 : 2 }}
            transition={{ type: 'spring', stiffness: 500, damping: 34 }}
            className="absolute left-0 top-[2px] h-[27px] w-[27px] rounded-full bg-white shadow"
        />
    </button>
);

// Doesn't block the page. Accept and Reject are equally easy, and the footer link reopens it.
const CookieBanner = () => {
    const [waitingForLoader, setWaitingForLoader] = useState(true);
    const [open, setOpen] = useState(needsChoice);
    const [choosing, setChoosing] = useState(false);
    const [choice, setChoice] = useState(() => {
        const saved = getConsent();
        return { analytics: saved?.analytics ?? false, ads: saved?.ads ?? false };
    });

    // Waits its turn, so it doesn't appear underneath the loading animation
    useEffect(() => {
        const release = () => setWaitingForLoader(false);
        const unsubscribe = onLoaderFinished(release);
        if (!isLoaderPlaying()) release();
        return unsubscribe;
    }, []);

    useEffect(() => onOpenCookieSettings(() => {
        const saved = getConsent();
        setChoice({ analytics: saved?.analytics ?? false, ads: saved?.ads ?? false });
        setChoosing(true);
        setOpen(true);
    }), []);

    const decide = (next) => {
        const consent = applyConsent(next);
        setChoice({ analytics: consent.analytics, ads: consent.ads });
        setOpen(false);
        setChoosing(false);
        track('consent_choice', { analytics: consent.analytics, ads: consent.ads });
    };

    const setOption = (id, value) => {
        setChoice((current) => {
            if (id === 'ads') return { ads: value, analytics: value || current.analytics };
            return { analytics: value, ads: value && current.ads };
        });
    };

    return (
        <AnimatePresence>
            {open && !waitingForLoader && (
                <motion.div
                    role="dialog"
                    aria-label="Cookie choices"
                    initial={{ opacity: 0, y: 40 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: 40 }}
                    transition={{ type: 'spring', stiffness: 340, damping: 30 }}
                    className="phone-ui fixed inset-x-3 bottom-[68px] z-[65] max-h-[calc(100svh-90px)] overflow-y-auto rounded-3xl border border-line bg-raised p-4 shadow-2xl shadow-black/70 lg:left-5 lg:right-auto lg:w-[420px]"
                >
                    <div className="flex items-start gap-3">
                        <span className="swift-gradient flex h-9 w-9 shrink-0 items-center justify-center rounded-xl text-ink">
                            <Cookie size={19} aria-hidden="true" />
                        </span>
                        <p className="text-sm leading-snug text-paper/90">
                            Can I use cookies to understand visits and measure ads? It's your choice, and the site works the same either way.
                        </p>
                    </div>

                    <AnimatePresence initial={false}>
                        {choosing && (
                            <motion.ul
                                initial={{ height: 0, opacity: 0 }}
                                animate={{ height: 'auto', opacity: 1 }}
                                exit={{ height: 0, opacity: 0 }}
                                className="overflow-hidden"
                            >
                                {OPTIONS.map(({ id, label, detail }) => (
                                    <li key={id} className="mt-3 flex items-center gap-3 rounded-2xl bg-ink/60 p-3">
                                        <span className="min-w-0 flex-1">
                                            <span className="block text-sm font-semibold">{label}</span>
                                            <span className="mt-0.5 block text-xs leading-snug text-muted">{detail}</span>
                                        </span>
                                        <Toggle checked={choice[id]} onChange={(value) => setOption(id, value)} label={label} />
                                    </li>
                                ))}
                            </motion.ul>
                        )}
                    </AnimatePresence>

                    <div className="mt-3 grid grid-cols-2 gap-2">
                        <button
                            type="button"
                            onClick={() => decide({ analytics: false, ads: false })}
                            className="h-11 rounded-full bg-white/10 text-sm font-semibold transition-colors hover:bg-white/15"
                        >
                            Reject all
                        </button>
                        <button
                            type="button"
                            onClick={() => decide({ analytics: true, ads: true })}
                            className="h-11 rounded-full bg-paper text-sm font-semibold text-ink transition-opacity hover:opacity-90"
                        >
                            Accept all
                        </button>
                    </div>
                    <button
                        type="button"
                        onClick={() => (choosing ? decide(choice) : setChoosing(true))}
                        aria-expanded={choosing}
                        className="mt-1 h-10 w-full text-sm font-medium text-amber hover:underline"
                    >
                        {choosing ? 'Save my choices' : 'Choose what to allow'}
                    </button>
                </motion.div>
            )}
        </AnimatePresence>
    );
};

export default CookieBanner;
