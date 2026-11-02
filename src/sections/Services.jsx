import { useState } from 'react';
import { motion } from 'framer-motion';
import { ChevronDown, GitFork, Map, SlidersHorizontal } from 'lucide-react';
import AppBuilder from './services/AppBuilder';
import ProjectFlow from './services/ProjectFlow';
import RideDemo from './services/RideDemo';
import { faqs } from '../data/services';
import { useIsDesktop } from '../hooks/useIsDesktop';

const MODULES = [
    { id: 'builder', tab: 'Your app', icon: SlidersHorizontal, title: 'Sketch your app', intro: 'Choose what it needs, and see what it would be built with and where I\'ve done it before.', Component: AppBuilder },
    { id: 'flow', tab: 'The path', icon: GitFork, title: 'From idea to App Store', intro: 'How an app gets made, loops included. Tap any step.', Component: ProjectFlow },
    { id: 'ride', tab: 'Take a ride', icon: Map, title: 'Take a ride', intro: 'The kind of real-time map I build. Tap a destination and watch it go, or drag through the trip.', Component: RideDemo },
];

const ModuleHeading = ({ title, intro }) => (
    <div className="mb-5">
        <h3 className="font-display text-3xl font-semibold tracking-tight">{title}</h3>
        <p className="mt-1.5 max-w-2xl leading-relaxed text-muted">{intro}</p>
    </div>
);

const Faq = () => (
    <div>
        <h3 className="mb-4 font-display text-3xl font-semibold tracking-tight">Common questions</h3>
        <div className="overflow-hidden rounded-2xl border border-line bg-surface">
            {faqs.map((faq) => (
                <details key={faq.question} className="group border-b border-line last:border-b-0">
                    <summary className="flex min-h-14 cursor-pointer list-none items-center justify-between gap-3 px-4 py-3 font-medium transition-colors hover:bg-raised sm:px-5 [&::-webkit-details-marker]:hidden">
                        {faq.question}
                        <ChevronDown size={18} aria-hidden="true" className="shrink-0 text-muted transition-transform group-open:rotate-180" />
                    </summary>
                    <p className="px-4 pb-4 leading-relaxed text-muted sm:px-5">{faq.answer}</p>
                </details>
            ))}
        </div>
    </div>
);

// Desktop shows everything. Phones get one module at a time, so the page doesn't grow by three screens.
const Services = () => {
    const isDesktop = useIsDesktop();
    const [tab, setTab] = useState(MODULES[0].id);
    const current = MODULES.find((module) => module.id === tab);

    return (
        <section id="services" data-tab="skills" className="relative bg-ink px-5 py-16 sm:px-10 lg:px-[5vw] lg:py-24">
            <p className="mb-3 font-mono text-sm text-swift">Got an idea?</p>
            <h2 className="font-display text-[clamp(2.4rem,5vw,4.5rem)] font-semibold leading-none tracking-tight">Let's see what your app could be.</h2>
            <p className="mt-5 max-w-2xl text-lg leading-relaxed text-muted">
                Sketch it, follow the path it takes to the App Store, or take one of my maps for a ride.
            </p>

            {isDesktop ? (
                <div className="mt-14 space-y-16">
                    <div>
                        <ModuleHeading title={MODULES[0].title} intro={MODULES[0].intro} />
                        <AppBuilder />
                    </div>
                    <div>
                        <ModuleHeading title={MODULES[1].title} intro={MODULES[1].intro} />
                        <ProjectFlow />
                    </div>
                    <div className="grid items-start gap-10 lg:grid-cols-[minmax(0,7fr)_minmax(0,5fr)]">
                        <div>
                            <ModuleHeading title={MODULES[2].title} intro={MODULES[2].intro} />
                            <RideDemo />
                        </div>
                        <Faq />
                    </div>
                </div>
            ) : (
                <>
                    <div role="group" aria-label="Choose a demo" className="mt-8 flex rounded-full border border-line bg-surface p-1">
                        {MODULES.map(({ id, tab: label, icon: Icon }) => (
                            <button
                                key={id}
                                type="button"
                                onClick={() => setTab(id)}
                                aria-pressed={tab === id}
                                className={`relative flex h-11 min-w-0 flex-1 items-center justify-center gap-1.5 rounded-full text-[13px] font-medium transition-colors ${tab === id ? 'text-ink' : 'text-muted'}`}
                            >
                                {tab === id && (
                                    <motion.span
                                        layoutId="services-tab"
                                        transition={{ type: 'spring', stiffness: 420, damping: 36 }}
                                        className="absolute inset-0 rounded-full bg-paper"
                                    />
                                )}
                                <Icon size={15} aria-hidden="true" className="relative shrink-0" />
                                <span className="relative truncate">{label}</span>
                            </button>
                        ))}
                    </div>

                    <motion.div key={current.id} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.25 }} className="mt-6">
                        <ModuleHeading title={current.title} intro={current.intro} />
                        <current.Component />
                    </motion.div>

                    <div className="mt-12"><Faq /></div>
                </>
            )}
        </section>
    );
};

export default Services;
