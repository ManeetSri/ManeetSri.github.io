import { useMemo, useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { ArrowRight, Bell, Check, Cloud, CreditCard, Database, Layers, Map, Radio, Repeat, Rocket, Route, ShoppingBag, Smartphone, Video, Wrench } from 'lucide-react';
import AppIcon from '../../components/device/AppIcon';
import { features, platforms, services } from '../../data/services';
import { projects } from '../../data/projects';
import { prefillContact } from '../../utils/contactPrefill';

const SERVICE_ICONS = { ios: Smartphone, 'cross-platform': Layers, projects: Wrench, mobility: Route, commerce: ShoppingBag, release: Rocket };
const FEATURE_ICONS = { maps: Map, payments: CreditCard, realtime: Radio, purchases: Repeat, push: Bell, firebase: Cloud, data: Database, video: Video };

const START = services.find((service) => service.id === 'mobility');

const sameFeatures = (a, b) => a.length === b.length && a.every((id) => b.includes(id));

// A small configurator: pick what the app needs, and see the stack and the apps that already use it
const AppBuilder = () => {
    const [platform, setPlatform] = useState(START.platform);
    const [selected, setSelected] = useState(START.features);

    const chosen = useMemo(() => features.filter((feature) => selected.includes(feature.id)), [selected]);
    const platformInfo = platforms.find((item) => item.id === platform);
    const stack = [...platformInfo.stack, ...chosen.map((feature) => feature.stack)];
    const proofIds = [...new Set(chosen.flatMap((feature) => feature.proof))];
    const proof = projects.filter((project) => proofIds.includes(project.id));

    const toggle = (id) => {
        setSelected((current) => (current.includes(id) ? current.filter((item) => item !== id) : [...current, id]));
    };

    const applyService = (service) => {
        setPlatform(service.platform);
        setSelected(service.features);
    };

    const talkAboutIt = () => {
        const list = chosen.map((feature) => feature.label.toLowerCase()).join(', ');
        prefillContact(`Hi Maneet, I'm thinking about an app for ${platformInfo.label}${list ? ` with ${list}` : ''}. Here's the idea: `);
    };

    return (
        <div className="grid gap-5 lg:grid-cols-[minmax(0,7fr)_minmax(0,5fr)]">
            <div className="min-w-0 space-y-6">
                <div>
                    <h3 className="mb-3 font-mono text-sm text-muted">Start from something familiar</h3>
                    {/* A swipeable row on phones, so the choices below stay close to the top */}
                    <ul className="-mx-5 flex snap-x snap-mandatory gap-2 overflow-x-auto px-5 pb-1 [scrollbar-width:none] sm:mx-0 sm:grid sm:grid-cols-2 sm:overflow-visible sm:px-0 sm:pb-0">
                        {services.map((service) => {
                            const Icon = SERVICE_ICONS[service.id];
                            const isActive = platform === service.platform && sameFeatures(service.features, selected);
                            return (
                                <li key={service.id} className="w-[78%] shrink-0 snap-center sm:w-auto">
                                    <button
                                        type="button"
                                        onClick={() => applyService(service)}
                                        aria-pressed={isActive}
                                        className={`flex h-full w-full items-start gap-3 rounded-2xl border p-3 text-left transition-colors ${isActive ? 'border-amber bg-amber/10' : 'border-line bg-surface hover:bg-raised'}`}
                                    >
                                        <span className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl ${isActive ? 'swift-gradient text-ink' : 'bg-white/8 text-amber'}`}>
                                            <Icon size={20} aria-hidden="true" />
                                        </span>
                                        <span className="min-w-0">
                                            <span className="block text-sm font-semibold leading-snug">{service.title}</span>
                                            <span className="mt-0.5 block text-[13px] leading-snug text-muted">{service.body}</span>
                                        </span>
                                    </button>
                                </li>
                            );
                        })}
                    </ul>
                </div>

                <div>
                    <h3 className="mb-3 font-mono text-sm text-muted">Where should it run?</h3>
                    <div className="flex rounded-full border border-line bg-surface p-1">
                        {platforms.map(({ id, label }) => (
                            <button
                                key={id}
                                type="button"
                                onClick={() => setPlatform(id)}
                                aria-pressed={platform === id}
                                className={`relative h-10 flex-1 rounded-full text-sm font-medium transition-colors ${platform === id ? 'text-ink' : 'text-muted hover:text-paper'}`}
                            >
                                {platform === id && (
                                    <motion.span
                                        layoutId="builder-platform"
                                        transition={{ type: 'spring', stiffness: 420, damping: 36 }}
                                        className="absolute inset-0 rounded-full bg-paper"
                                    />
                                )}
                                <span className="relative">{label}</span>
                            </button>
                        ))}
                    </div>
                </div>

                <div>
                    <h3 className="mb-3 font-mono text-sm text-muted">What does it need?</h3>
                    <ul className="flex flex-wrap gap-2">
                        {features.map(({ id, label }) => {
                            const Icon = FEATURE_ICONS[id];
                            const isOn = selected.includes(id);
                            return (
                                <li key={id}>
                                    <motion.button
                                        type="button"
                                        whileTap={{ scale: 0.94 }}
                                        onClick={() => toggle(id)}
                                        aria-pressed={isOn}
                                        className={`flex h-11 items-center gap-2 rounded-full border px-3.5 text-sm font-medium transition-colors ${isOn ? 'border-transparent bg-paper text-ink' : 'border-line bg-surface text-paper hover:bg-raised'}`}
                                    >
                                        <Icon size={16} aria-hidden="true" /> {label}
                                    </motion.button>
                                </li>
                            );
                        })}
                    </ul>
                </div>
            </div>

            {/* The result, kept in view on desktop while choosing */}
            <div className="self-start rounded-[2rem] border border-line bg-surface p-5 lg:sticky lg:top-6">
                <p className="font-mono text-sm text-muted">Your app</p>
                <p className="font-display text-3xl font-semibold tracking-tight" aria-live="polite">{platformInfo.label}</p>

                <div aria-hidden="true" className="mt-4 grid min-h-[92px] grid-cols-4 content-start gap-3 rounded-3xl sm:grid-cols-6 bg-[radial-gradient(110%_90%_at_20%_0%,#3a1a12_0%,#14161c_70%)] p-4">
                    <AnimatePresence mode="popLayout" initial={false}>
                        {chosen.map(({ id }) => {
                            const Icon = FEATURE_ICONS[id];
                            return (
                                <motion.span
                                    key={id}
                                    layout
                                    initial={{ scale: 0, opacity: 0 }}
                                    animate={{ scale: 1, opacity: 1 }}
                                    exit={{ scale: 0, opacity: 0 }}
                                    transition={{ type: 'spring', stiffness: 480, damping: 24 }}
                                    className="swift-gradient flex aspect-square items-center justify-center rounded-[22%] text-ink"
                                >
                                    <Icon size={22} />
                                </motion.span>
                            );
                        })}
                    </AnimatePresence>
                    {chosen.length === 0 && <span className="col-span-4 py-4 text-center text-sm text-muted sm:col-span-6">Pick a feature to add it</span>}
                </div>

                <h4 className="mb-2 mt-4 font-mono text-sm text-muted">Built with</h4>
                <ul className="flex flex-wrap gap-1.5">
                    {stack.map((item) => (
                        <motion.li key={item} layout="position" className="flex items-center gap-1 rounded-full bg-white/8 px-2.5 py-1 text-[13px]">
                            <Check size={13} className="text-[#30D158]" aria-hidden="true" /> {item}
                        </motion.li>
                    ))}
                </ul>

                {proof.length > 0 && (
                    <>
                        <h4 className="mb-2 mt-4 font-mono text-sm text-muted">I've done this before in</h4>
                        <ul className="flex flex-wrap gap-2">
                            {proof.map((project) => (
                                <li key={project.id} className="flex items-center gap-1.5 rounded-full bg-white/8 py-1 pl-1 pr-3 text-[13px]">
                                    <AppIcon project={project} size={24} /> {project.title}
                                </li>
                            ))}
                        </ul>
                    </>
                )}

                <button
                    type="button"
                    onClick={talkAboutIt}
                    className="swift-gradient mt-5 flex h-12 w-full items-center justify-center gap-2 rounded-full font-semibold text-ink transition-transform hover:scale-[1.02]"
                >
                    Talk about this app <ArrowRight size={18} aria-hidden="true" />
                </button>
            </div>
        </div>
    );
};

export default AppBuilder;
