import { motion } from 'framer-motion';
import { ChevronDown, Layers, Rocket, Route, ShoppingBag, Smartphone, Wrench } from 'lucide-react';
import { faqs, services } from '../data/services';

const ICONS = {
    ios: Smartphone,
    'cross-platform': Layers,
    projects: Wrench,
    mobility: Route,
    commerce: ShoppingBag,
    release: Rocket,
};

// Each service reads like an App Store listing, with a "Get" button that leads to the contact form
const Services = () => (
    <section id="services" data-tab="skills" className="relative bg-ink px-5 py-16 sm:px-10 lg:px-[5vw] lg:py-24">
        <p className="mb-3 font-mono text-sm text-swift">Available for freelance</p>
        <h2 className="font-display text-[clamp(2.4rem,5vw,4.5rem)] font-semibold leading-none tracking-tight">Need an app built? Let's build it.</h2>
        <p className="mt-5 max-w-2xl text-lg leading-relaxed text-muted">
            Freelance mobile app development for iOS and Android, from a first version to an app already in the store.
        </p>

        <ul className="mt-10 grid gap-3 lg:grid-cols-2">
            {services.map((service, index) => {
                const Icon = ICONS[service.id];
                return (
                    <motion.li
                        key={service.id}
                        initial={{ opacity: 0, y: 18 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true, margin: '-5% 0px' }}
                        transition={{ duration: 0.45, delay: (index % 2) * 0.08 }}
                        className="flex items-center gap-4 rounded-2xl border border-line bg-surface p-4"
                    >
                        <span className="swift-gradient flex h-14 w-14 shrink-0 items-center justify-center rounded-[14px] text-ink">
                            <Icon size={26} aria-hidden="true" />
                        </span>
                        <div className="min-w-0 flex-1">
                            <h3 className="font-semibold leading-snug">{service.title}</h3>
                            <p className="mt-0.5 text-sm leading-snug text-muted">{service.body}</p>
                        </div>
                        <a
                            href="#contact"
                            aria-label={`Get in touch about ${service.title}`}
                            className="phone-ui flex h-9 shrink-0 items-center rounded-full bg-white/10 px-4 text-sm font-bold text-amber transition-colors hover:bg-white/15"
                        >
                            GET
                        </a>
                    </motion.li>
                );
            })}
        </ul>

        <h3 className="mb-3 mt-12 font-display text-3xl font-semibold tracking-tight">Common questions</h3>
        <div className="max-w-3xl overflow-hidden rounded-2xl border border-line bg-surface">
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
    </section>
);

export default Services;
