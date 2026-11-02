import { motion } from 'framer-motion';
import { ArrowRight, ChevronDown, Sparkles } from 'lucide-react';
import { Link } from 'react-router-dom';
import { faqs, services } from '../data/services';
import { SERVICE_ICONS } from '../game/icons';
import { track } from '../analytics';

// The game lives on its own page. This invites people in, and each mission starts it there.
const Services = () => (
    <section id="services" data-tab="skills" className="relative bg-ink px-5 py-16 sm:px-10 lg:px-[5vw] lg:py-24">
        <div className="relative overflow-hidden rounded-[2rem] border border-line bg-[radial-gradient(80%_120%_at_0%_0%,rgba(240,81,56,0.2),transparent_65%)] bg-surface p-5 sm:p-8 lg:p-10">
            <div className="grid items-center gap-8 lg:grid-cols-[minmax(0,5fr)_minmax(0,6fr)]">
                <div>
                    <p className="mb-3 flex items-center gap-2 font-mono text-sm text-amber">
                        <Sparkles size={15} aria-hidden="true" /> Play · 5 levels
                    </p>
                    <h2 className="font-display text-[clamp(2.2rem,4.6vw,4rem)] font-semibold leading-none tracking-tight">Let's see what your app could be.</h2>
                    <p className="mt-4 max-w-xl text-lg leading-relaxed text-muted">
                        Got an idea? Pick a mission, power up your app, take a test ride and get it to the App Store.
                    </p>
                    <Link
                        to="/build"
                        data-event="game_entry"
                        data-event-source="home_button"
                        className="swift-gradient mt-6 inline-flex h-12 items-center justify-center gap-2 rounded-full px-7 font-semibold text-ink transition-transform hover:scale-[1.03]"
                    >
                        Ship your app <ArrowRight size={18} aria-hidden="true" />
                    </Link>
                </div>

                <ul className="grid grid-cols-2 gap-2 sm:grid-cols-3">
                    {services.map((service, index) => {
                        const Icon = SERVICE_ICONS[service.id];
                        return (
                            <motion.li
                                key={service.id}
                                initial={{ opacity: 0, scale: 0.9 }}
                                whileInView={{ opacity: 1, scale: 1 }}
                                viewport={{ once: true }}
                                transition={{ type: 'spring', stiffness: 300, damping: 22, delay: index * 0.05 }}
                            >
                                <Link
                                    to={`/build?mission=${service.id}`}
                                    aria-label={`Start the game with ${service.title}`}
                                    data-event="game_entry"
                                    data-event-source={service.id}
                                    className="flex h-full min-h-[108px] flex-col justify-between gap-3 rounded-2xl border border-line bg-ink/50 p-3.5 transition-colors hover:border-amber/60 hover:bg-raised"
                                >
                                    <Icon size={22} aria-hidden="true" className="text-amber" />
                                    <span className="text-sm font-semibold leading-snug">{service.title}</span>
                                </Link>
                            </motion.li>
                        );
                    })}
                </ul>
            </div>
        </div>

        <h3 className="mb-4 mt-12 font-display text-3xl font-semibold tracking-tight">Common questions</h3>
        <div className="max-w-3xl overflow-hidden rounded-2xl border border-line bg-surface">
            {faqs.map((faq) => (
                <details
                    key={faq.question}
                    onToggle={(event) => {
                        if (event.currentTarget.open) track('faq_open', { question: faq.question });
                    }}
                    className="group border-b border-line last:border-b-0"
                >
                    <summary className="flex min-h-14 cursor-pointer list-none items-center justify-between gap-3 px-4 py-3 font-medium transition-colors hover:bg-raised sm:px-5 [&::-webkit-details-marker]:hidden">
                        {faq.question}
                        <ChevronDown size={18} aria-hidden="true" className="shrink-0 text-muted transition-transform group-open:rotate-180" />
                    </summary>
                    <p className="px-4 pb-4 leading-relaxed text-muted sm:px-5">{faq.answer}</p>
                </details>
            ))}
        </div>
    </section>
);

export default Services;
