import { useEffect, useRef, useState } from 'react';
import { AnimatePresence, motion, useDragControls } from 'framer-motion';
import { ArrowRight, Check, FileText, Github, Linkedin, Mail, MessageSquareHeart, Newspaper, Star, X } from 'lucide-react';
import { useLocation, useNavigate } from 'react-router-dom';
import { FIELD_LIMITS, FormCooldownError, submitNetlifyForm } from '../utils/netlifyForm';
import { track } from '../analytics';

const PROMPTED_KEY = 'maneet-feedback-prompted';
const PROMPT_AFTER_MS = 45000;
const PROMPT_VISIBLE_MS = 10000;

const CONNECT_LINKS = [
    { icon: Mail, label: 'Email', detail: 'srivastavmaneet@gmail.com', href: 'mailto:srivastavmaneet@gmail.com' },
    { icon: Linkedin, label: 'LinkedIn', detail: 'Maneet Srivastav', href: 'https://www.linkedin.com/in/maneet-srivastav-1499a1196/' },
    { icon: Github, label: 'GitHub', detail: 'ManeetSri', href: 'https://github.com/ManeetSri' },
    { icon: Newspaper, label: 'Medium', detail: '@maneetsrivastav', href: 'https://medium.com/@maneetsrivastav' },
    { icon: FileText, label: 'Resume', detail: 'PDF', href: '/resume.pdf' },
];

const TABS = [
    { id: 'feedback', label: 'Feedback' },
    { id: 'connect', label: 'Connect' },
];

const wasPrompted = () => {
    try {
        return Boolean(localStorage.getItem(PROMPTED_KEY));
    } catch {
        return false;
    }
};

const markPrompted = () => {
    try {
        localStorage.setItem(PROMPTED_KEY, '1');
    } catch {
        // Without storage the prompt can simply appear again on a later visit
    }
};

const fieldClass = 'w-full rounded-2xl border border-line bg-ink px-4 py-3 text-base text-paper placeholder:text-muted/80 focus:border-amber focus:outline-none';

const FeedbackForm = ({ onConnect }) => {
    const [rating, setRating] = useState(0);
    const [message, setMessage] = useState('');
    const [email, setEmail] = useState('');
    const [status, setStatus] = useState('');
    const canSend = rating > 0 || message.trim().length > 0;

    const onSubmit = async (event) => {
        event.preventDefault();
        if (!canSend) return;
        setStatus('sending');
        try {
            await submitNetlifyForm('feedback', {
                'bot-field': event.target.elements['bot-field'].value,
                rating,
                message,
                email,
                page: window.location.pathname,
            });
            setStatus('success');
            track('feedback_submit', { rating, has_message: message.trim().length > 0, has_email: email.trim().length > 0 });
        } catch (error) {
            if (error instanceof FormCooldownError) {
                setStatus('cooldown');
                return;
            }
            console.error('Error:', error);
            setStatus('error');
            track('form_error', { form: 'feedback' });
        }
    };

    if (status === 'success') {
        return (
            <div role="status" className="py-6 text-center">
                <motion.span
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ type: 'spring', stiffness: 400, damping: 18 }}
                    className="mx-auto mb-3 flex h-14 w-14 items-center justify-center rounded-full bg-[#30D158]"
                >
                    <Check size={30} strokeWidth={3} className="text-ink" aria-hidden="true" />
                </motion.span>
                <p className="font-display text-2xl font-semibold tracking-tight">Thanks, feedback received.</p>
                <p className="mt-1 text-muted">It helps me make this better.</p>
                <button type="button" onClick={onConnect} className="mt-4 inline-flex h-11 items-center gap-1.5 font-medium text-amber hover:underline">
                    Connect with me <ArrowRight size={17} aria-hidden="true" />
                </button>
            </div>
        );
    }

    return (
        <form onSubmit={onSubmit} name="feedback" data-netlify="true" data-netlify-honeypot="bot-field" className="space-y-4">
            <input type="text" name="bot-field" className="hidden" tabIndex={-1} autoComplete="off" aria-hidden="true" />

            <fieldset>
                <legend className="mb-2 text-sm text-muted">How was your visit?</legend>
                <div className="flex gap-1">
                    {[1, 2, 3, 4, 5].map((value) => (
                        <motion.button
                            key={value}
                            type="button"
                            whileTap={{ scale: 0.8 }}
                            onClick={() => setRating(value)}
                            aria-label={`${value} out of 5 stars`}
                            aria-pressed={rating === value}
                            className="flex h-11 w-11 items-center justify-center rounded-xl"
                        >
                            <Star size={30} aria-hidden="true" className={value <= rating ? 'fill-amber text-amber' : 'text-muted/60'} />
                        </motion.button>
                    ))}
                </div>
            </fieldset>

            <div>
                <label htmlFor="feedback-message" className="mb-1 block pl-1 text-sm text-muted">What could be better?</label>
                <textarea
                    id="feedback-message"
                    maxLength={FIELD_LIMITS.message}
                    rows="3"
                    value={message}
                    onChange={(event) => setMessage(event.target.value)}
                    placeholder="A bug, an idea, or something you liked..."
                    className={`${fieldClass} resize-none`}
                />
            </div>

            <div>
                <label htmlFor="feedback-email" className="mb-1 block pl-1 text-sm text-muted">Email (optional, if you'd like a reply)</label>
                <input
                    id="feedback-email"
                    maxLength={FIELD_LIMITS.email}
                    type="email"
                    autoComplete="email"
                    value={email}
                    onChange={(event) => setEmail(event.target.value)}
                    className={fieldClass}
                />
            </div>

            {status === 'cooldown' && (
                <p role="status" className="rounded-2xl border border-line bg-white/5 px-4 py-3 text-sm text-muted">
                    Please wait a few seconds before sending more feedback.
                </p>
            )}
            {status === 'error' && (
                <p role="alert" className="rounded-2xl border border-[#FF453A]/40 bg-[#FF453A]/10 px-4 py-3 text-sm text-[#FF9D96]">
                    That didn't send. Please try again or email{' '}
                    <a href="mailto:srivastavmaneet@gmail.com" className="underline">srivastavmaneet@gmail.com</a>.
                </p>
            )}

            <button
                type="submit"
                disabled={!canSend || status === 'sending'}
                className="swift-gradient h-12 w-full rounded-full font-semibold text-ink transition-opacity disabled:opacity-40"
            >
                {status === 'sending' ? 'Sending…' : 'Send Feedback'}
            </button>
        </form>
    );
};

const ConnectPanel = ({ onStartProject }) => (
    <div>
        <button
            type="button"
            onClick={onStartProject}
            data-event="cta_click"
            data-event-cta="start_project"
            className="swift-gradient mb-4 flex h-12 w-full items-center justify-center gap-2 rounded-full font-semibold text-ink"
        >
            Start a project <ArrowRight size={18} aria-hidden="true" />
        </button>
        <ul className="overflow-hidden rounded-2xl border border-line">
            {CONNECT_LINKS.map(({ icon: Icon, label, detail, href }) => (
                <li key={label} className="border-b border-line last:border-b-0">
                    <a
                        href={href}
                        target={href.startsWith('mailto') ? undefined : '_blank'}
                        rel="noopener noreferrer"
                        data-event={label === 'Resume' ? 'resume_open' : 'profile_click'}
                        data-event-profile={label === 'Resume' ? undefined : label.toLowerCase()}
                        data-event-source="feedback_sheet"
                        className="flex min-h-13 items-center gap-3 px-4 py-2.5 transition-colors hover:bg-raised"
                    >
                        <Icon size={20} className="shrink-0 text-amber" aria-hidden="true" />
                        <span className="font-medium">{label}</span>
                        <span className="ml-auto min-w-0 truncate text-sm text-muted">{detail}</span>
                    </a>
                </li>
            ))}
        </ul>
    </div>
);

const Sheet = ({ initialTab, onClose, onStartProject }) => {
    const [tab, setTab] = useState(initialTab);
    const panelRef = useRef(null);
    const closeRef = useRef(null);
    const dragControls = useDragControls();

    // A modal: page scroll stops, focus moves in and stays in, and it's given back on close
    useEffect(() => {
        const previouslyFocused = document.activeElement;
        document.documentElement.style.overflow = 'hidden';
        closeRef.current?.focus();
        return () => {
            document.documentElement.style.overflow = '';
            previouslyFocused?.focus?.({ preventScroll: true });
        };
    }, []);

    const onKeyDown = (event) => {
        if (event.key === 'Escape') {
            onClose();
            return;
        }
        if (event.key !== 'Tab') return;
        const focusable = [...panelRef.current.querySelectorAll('a[href], button:not([disabled]), textarea, input:not([type="hidden"]):not(.hidden)')];
        const first = focusable[0];
        const last = focusable[focusable.length - 1];
        if (event.shiftKey && document.activeElement === first) {
            event.preventDefault();
            last.focus();
        } else if (!event.shiftKey && document.activeElement === last) {
            event.preventDefault();
            first.focus();
        }
    };

    return (
        <div className="fixed inset-0 z-[70]" onKeyDown={onKeyDown}>
            <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                onClick={onClose}
                className="absolute inset-0 bg-black/60"
            />
            <motion.div
                ref={panelRef}
                role="dialog"
                aria-modal="true"
                aria-labelledby="feedback-title"
                initial={{ y: '100%' }}
                animate={{ y: 0 }}
                exit={{ y: '100%' }}
                transition={{ type: 'spring', stiffness: 380, damping: 36 }}
                drag="y"
                dragControls={dragControls}
                dragListener={false}
                dragConstraints={{ top: 0, bottom: 0 }}
                dragElastic={{ top: 0, bottom: 0.7 }}
                onDragEnd={(event, info) => {
                    if (info.offset.y > 110 || info.velocity.y > 600) onClose();
                }}
                className="absolute inset-x-0 bottom-0 max-h-[88svh] overflow-y-auto rounded-t-[2rem] border border-b-0 border-line bg-surface px-5 pb-[max(1.25rem,env(safe-area-inset-bottom))] lg:bottom-5 lg:left-auto lg:right-5 lg:w-[420px] lg:rounded-[2rem] lg:border-b"
            >
                <div
                    onPointerDown={(event) => dragControls.start(event)}
                    className="sticky top-0 z-10 -mx-5 flex cursor-grab touch-none justify-center bg-surface pb-2 pt-3 lg:hidden"
                >
                    <span aria-hidden="true" className="h-1.5 w-11 rounded-full bg-paper/30" />
                </div>

                <div className="mb-4 flex items-center justify-between pt-1 lg:pt-5">
                    <h2 id="feedback-title" className="font-display text-2xl font-semibold tracking-tight">
                        {tab === 'feedback' ? 'Send feedback' : "Let's connect"}
                    </h2>
                    <button
                        ref={closeRef}
                        type="button"
                        onClick={onClose}
                        aria-label="Close"
                        className="-mr-1 flex h-11 w-11 items-center justify-center rounded-full bg-white/5 hover:bg-white/10"
                    >
                        <X size={20} aria-hidden="true" />
                    </button>
                </div>

                <div className="mb-5 flex rounded-full bg-ink p-1">
                    {TABS.map(({ id, label }) => (
                        <button
                            key={id}
                            type="button"
                            onClick={() => setTab(id)}
                            data-event="feedback_tab"
                            data-event-tab={id}
                            aria-pressed={tab === id}
                            className={`relative h-10 flex-1 rounded-full text-sm font-medium transition-colors ${tab === id ? 'text-ink' : 'text-muted hover:text-paper'}`}
                        >
                            {tab === id && (
                                <motion.span
                                    layoutId="feedback-tab"
                                    transition={{ type: 'spring', stiffness: 420, damping: 36 }}
                                    className="absolute inset-0 rounded-full bg-paper"
                                />
                            )}
                            <span className="relative">{label}</span>
                        </button>
                    ))}
                </div>

                {tab === 'feedback'
                    ? <FeedbackForm onConnect={() => setTab('connect')} />
                    : <ConnectPanel onStartProject={onStartProject} />}
            </motion.div>
        </div>
    );
};

// A small button that's always there, a one-time notification-style nudge, and a sheet with both
const FeedbackSheet = () => {
    const { pathname } = useLocation();
    const navigate = useNavigate();
    const [open, setOpen] = useState(false);
    const [prompting, setPrompting] = useState(false);

    // The nudge comes after the visitor has seen the apps, or after a while on the page. Once only.
    useEffect(() => {
        if (pathname !== '/' || wasPrompted()) return undefined;
        const prompt = () => {
            if (wasPrompted()) return;
            markPrompted();
            track('nudge_shown');
            setPrompting(true);
        };
        const timer = setTimeout(prompt, PROMPT_AFTER_MS);
        const skills = document.getElementById('skills');
        const observer = new IntersectionObserver((entries) => {
            if (entries.some((entry) => entry.isIntersecting)) prompt();
        }, { rootMargin: '-40% 0px -40% 0px' });
        if (skills) observer.observe(skills);
        return () => {
            clearTimeout(timer);
            observer.disconnect();
        };
    }, [pathname]);

    useEffect(() => {
        if (!prompting) return undefined;
        const timer = setTimeout(() => setPrompting(false), PROMPT_VISIBLE_MS);
        return () => clearTimeout(timer);
    }, [prompting]);

    const openSheet = (source) => {
        track('feedback_open', { source });
        setPrompting(false);
        setOpen(true);
    };

    const startProject = () => {
        setOpen(false);
        if (pathname === '/') {
            // Wait for the sheet to give scrolling back before moving the page
            setTimeout(() => document.getElementById('contact')?.scrollIntoView(), 60);
        } else {
            navigate('/#contact');
        }
    };

    return (
        <>
            <button
                type="button"
                onClick={() => openSheet('button')}
                aria-label="Send feedback or connect"
                className="phone-ui fixed right-3 top-3 z-40 flex h-11 w-11 items-center justify-center gap-2 rounded-full border border-line bg-surface/80 text-paper shadow-xl shadow-black/40 backdrop-blur-xl transition-colors hover:bg-raised lg:bottom-3 lg:right-5 lg:top-auto lg:w-auto lg:px-4"
            >
                <MessageSquareHeart size={19} aria-hidden="true" className="text-amber" />
                <span className="hidden text-sm font-medium lg:inline">Feedback</span>
            </button>

            <AnimatePresence>
                {prompting && !open && (
                    <motion.div
                        initial={{ opacity: 0, y: -30, scale: 0.96 }}
                        animate={{ opacity: 1, y: 0, scale: 1 }}
                        exit={{ opacity: 0, y: -30, scale: 0.96 }}
                        transition={{ type: 'spring', stiffness: 360, damping: 28 }}
                        className="phone-ui fixed inset-x-3 top-3 z-[60] flex items-center gap-1 rounded-[22px] border border-line bg-raised/95 p-2 shadow-2xl shadow-black/60 backdrop-blur-xl lg:bottom-16 lg:left-auto lg:right-5 lg:top-auto lg:w-[360px]"
                    >
                        <button type="button" onClick={() => openSheet('nudge')} className="flex min-w-0 flex-1 items-center gap-3 rounded-2xl p-1 text-left">
                            <span className="swift-gradient flex h-10 w-10 shrink-0 items-center justify-center rounded-xl text-sm font-bold text-ink">MS</span>
                            <span className="min-w-0">
                                <span className="block text-sm font-semibold">How's the build so far?</span>
                                <span className="block truncate text-[13px] text-muted">Send feedback or connect with me</span>
                            </span>
                        </button>
                        <button
                            type="button"
                            onClick={() => setPrompting(false)}
                            data-event="nudge_dismiss"
                            aria-label="Dismiss"
                            className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full text-muted hover:text-paper"
                        >
                            <X size={18} aria-hidden="true" />
                        </button>
                    </motion.div>
                )}
            </AnimatePresence>

            <AnimatePresence>
                {open && <Sheet initialTab="feedback" onClose={() => setOpen(false)} onStartProject={startProject} />}
            </AnimatePresence>
        </>
    );
};

export default FeedbackSheet;
