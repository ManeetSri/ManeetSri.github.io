import { useEffect, useRef, useState } from 'react';
import { motion } from 'framer-motion';
import { ArrowUp, FileText, Github, Linkedin, Mail } from 'lucide-react';
import { submitNetlifyForm } from '../utils/netlifyForm';
import { onContactPrefill } from '../utils/contactPrefill';
import { track } from '../analytics';
import { openCookieSettings } from '../analytics/consent';

const BUBBLES = [
    'Hi, thanks for scrolling all the way to the end.',
    'I\'m open to projects, roles and collaborations around iOS, Android and user-centric mobile products.',
    'Happy to talk architecture, performance and product trade-offs. What are you building?',
];

const LINKS = [
    { icon: Mail, label: 'srivastavmaneet@gmail.com', href: 'mailto:srivastavmaneet@gmail.com' },
    { icon: Github, label: 'GitHub', href: 'https://github.com/ManeetSri' },
    { icon: Linkedin, label: 'LinkedIn', href: 'https://www.linkedin.com/in/maneet-srivastav-1499a1196/' },
    { icon: FileText, label: 'Medium', href: 'https://medium.com/@maneetsrivastav' },
];

const EMPTY_FORM = { name: '', email: '', message: '' };

const fieldClass = 'w-full rounded-2xl border border-line bg-ink px-4 py-3 text-base text-paper placeholder:text-muted/80 focus:border-amber focus:outline-none';

const Contact = () => {
    const [formData, setFormData] = useState(EMPTY_FORM);
    const [status, setStatus] = useState('');
    const [sent, setSent] = useState([]);
    const nameRef = useRef(null);
    const startedRef = useRef(false);

    // A message started by the app builder, unless the visitor has already written their own
    useEffect(() => onContactPrefill((message) => {
        setFormData((current) => (current.message.trim() ? current : { ...current, message }));
        track('contact_prefilled');
        nameRef.current?.focus({ preventScroll: true });
    }), []);

    const handleChange = (event) => {
        setFormData({ ...formData, [event.target.name]: event.target.value });
    };

    const handleSubmit = (event) => {
        event.preventDefault();
        setStatus('sending');

        submitNetlifyForm('contact', { 'bot-field': event.target.elements['bot-field'].value, ...formData })
            .then(() => {
                setStatus('success');
                track('generate_lead', { form: 'contact' });
                setSent((messages) => [...messages, formData.message]);
                setFormData(EMPTY_FORM);
            })
            .catch((error) => {
                console.error('Error:', error);
                setStatus('error');
                track('form_error', { form: 'contact' });
            });
    };

    return (
        <section id="contact" className="relative bg-ink px-5 pb-28 pt-16 sm:px-10 lg:px-[5vw] lg:pt-24">
            <h2 className="mb-12 font-display text-[clamp(2.4rem,6vw,5.5rem)] font-semibold leading-none tracking-tight">
                Ready to <span className="swift-gradient-text">ship</span> something?
            </h2>

            <div className="mx-auto max-w-2xl rounded-[2rem] border border-line bg-surface p-4 sm:p-6">
                <p className="mb-5 text-center">
                    <span className="swift-gradient mx-auto mb-1.5 flex h-12 w-12 items-center justify-center rounded-full font-semibold text-ink">MS</span>
                    <span className="phone-ui text-sm font-medium">Maneet</span>
                </p>

                <div className="phone-ui space-y-2">
                    {BUBBLES.map((bubble, index) => (
                        <motion.p
                            key={bubble}
                            initial={{ opacity: 0, y: 18, scale: 0.94 }}
                            whileInView={{ opacity: 1, y: 0, scale: 1 }}
                            viewport={{ once: true, margin: '-10% 0px' }}
                            transition={{ type: 'spring', stiffness: 260, damping: 24, delay: index * 0.35 }}
                            className="w-fit max-w-[85%] origin-bottom-left rounded-[20px] bg-raised px-4 py-2.5 leading-snug"
                        >
                            {bubble}
                        </motion.p>
                    ))}

                    {sent.map((message, index) => (
                        <motion.p
                            key={`${index}-${message}`}
                            initial={{ opacity: 0, y: 18, scale: 0.94 }}
                            animate={{ opacity: 1, y: 0, scale: 1 }}
                            className="swift-gradient ml-auto w-fit max-w-[85%] origin-bottom-right whitespace-pre-wrap rounded-[20px] px-4 py-2.5 leading-snug text-ink"
                        >
                            {message}
                        </motion.p>
                    ))}
                    {status === 'success' && (
                        <p role="status" className="text-right text-sm text-muted">Delivered. I'll be in touch soon.</p>
                    )}
                </div>

                <form
                    onSubmit={handleSubmit}
                    onFocus={() => {
                        if (startedRef.current) return;
                        startedRef.current = true;
                        track('form_start', { form: 'contact' });
                    }}
                    name="contact"
                    data-netlify="true"
                    data-netlify-honeypot="bot-field"
                    className="mt-6 space-y-3"
                >
                    <input type="hidden" name="form-name" value="contact" />
                    {/* Honeypot: hidden from people, filled in by bots */}
                    <input type="text" name="bot-field" className="hidden" tabIndex={-1} autoComplete="off" aria-hidden="true" />

                    <div className="grid gap-3 sm:grid-cols-2">
                        <div>
                            <label htmlFor="name" className="mb-1 block pl-1 text-sm text-muted">Name</label>
                            <input ref={nameRef} id="name" name="name" type="text" required autoComplete="name" value={formData.name} onChange={handleChange} className={fieldClass} />
                        </div>
                        <div>
                            <label htmlFor="email" className="mb-1 block pl-1 text-sm text-muted">Email</label>
                            <input id="email" name="email" type="email" required autoComplete="email" value={formData.email} onChange={handleChange} className={fieldClass} />
                        </div>
                    </div>

                    <div>
                        <label htmlFor="message" className="mb-1 block pl-1 text-sm text-muted">Message</label>
                        <div className="relative">
                            <textarea
                                id="message"
                                name="message"
                                required
                                rows="4"
                                value={formData.message}
                                onChange={handleChange}
                                placeholder="Tell me about the role or project..."
                                className={`${fieldClass} resize-none pr-16`}
                            />
                            <button
                                type="submit"
                                disabled={status === 'sending'}
                                aria-label={status === 'sending' ? 'Sending message' : 'Send message'}
                                className="swift-gradient absolute bottom-3 right-3 flex h-11 w-11 items-center justify-center rounded-full text-ink transition-transform hover:scale-105 disabled:opacity-60"
                            >
                                <ArrowUp size={22} strokeWidth={2.5} aria-hidden="true" />
                            </button>
                        </div>
                    </div>

                    {status === 'error' && (
                        <p role="alert" className="rounded-2xl border border-[#FF453A]/40 bg-[#FF453A]/10 px-4 py-3 text-sm text-[#FF9D96]">
                            Your message wasn't sent. Please try again or email me at{' '}
                            <a href="mailto:srivastavmaneet@gmail.com" className="underline">srivastavmaneet@gmail.com</a>.
                        </p>
                    )}
                </form>
            </div>

            <ul className="mx-auto mt-8 flex max-w-2xl flex-wrap justify-center gap-2">
                {LINKS.map(({ icon: Icon, label, href }) => (
                    <li key={label}>
                        <a
                            href={href}
                            target={href.startsWith('mailto') ? undefined : '_blank'}
                            rel="noopener noreferrer"
                            data-event="profile_click"
                            data-event-profile={label === 'srivastavmaneet@gmail.com' ? 'email' : label.toLowerCase()}
                            data-event-source="contact"
                            className="inline-flex h-11 items-center gap-2 rounded-full border border-line bg-white/5 px-4 text-sm font-medium transition-colors hover:bg-white/10"
                        >
                            <Icon size={16} aria-hidden="true" /> {label}
                        </a>
                    </li>
                ))}
            </ul>

            <footer className="mt-20 border-t border-line pt-6 text-center font-mono text-sm text-muted">
                <p><span className="text-[#30D158]">Build succeeded</span> · © {new Date().getFullYear()} · Designed & built by Maneet Srivastav</p>
                <p className="mt-3 text-xs">
                    <button
                        type="button"
                        onClick={openCookieSettings}
                        className="inline-flex min-h-6 items-center underline underline-offset-2 hover:text-paper"
                    >
                        Cookie settings
                    </button>
                </p>
            </footer>
        </section>
    );
};

export default Contact;
