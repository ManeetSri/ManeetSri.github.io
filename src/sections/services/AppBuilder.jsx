import { useMemo, useState } from 'react';
import { motion } from 'framer-motion';
import { ArrowRight, Bell, Cloud, CreditCard, Database, Map, Radio, Repeat, Video } from 'lucide-react';
import AppIcon from '../../components/device/AppIcon';
import { features, platforms, services } from '../../data/services';
import { projects } from '../../data/projects';
import { prefillContact } from '../../utils/contactPrefill';
import { track } from '../../analytics';

const FEATURE_ICONS = { maps: Map, payments: CreditCard, realtime: Radio, purchases: Repeat, push: Bell, firebase: Cloud, data: Database, video: Video };

const START = services.find((service) => service.id === 'mobility');

const sameFeatures = (a, b) => a.length === b.length && a.every((id) => b.includes(id));

const nameList = (names) => (names.length > 1 ? `${names.slice(0, -1).join(', ')} and ${names[names.length - 1]}` : names[0]);

// A compact configurator: pick a starting point, adjust it, and see the stack and where it's been done
const AppBuilder = () => {
    const [platform, setPlatform] = useState(START.platform);
    const [selected, setSelected] = useState(START.features);

    const chosen = useMemo(() => features.filter((feature) => selected.includes(feature.id)), [selected]);
    const platformInfo = platforms.find((item) => item.id === platform);
    const stack = [...platformInfo.stack, ...chosen.map((feature) => feature.stack)];
    const proofIds = [...new Set(chosen.flatMap((feature) => feature.proof))];
    const proof = projects.filter((project) => proofIds.includes(project.id));
    const activeService = services.find((service) => service.platform === platform && sameFeatures(service.features, selected));

    const toggle = (id) => {
        track('builder_feature', { feature: id, on: !selected.includes(id) });
        setSelected((current) => (current.includes(id) ? current.filter((item) => item !== id) : [...current, id]));
    };

    const applyService = (service) => {
        track('builder_preset', { service: service.id });
        setPlatform(service.platform);
        setSelected(service.features);
    };

    const talkAboutIt = () => {
        track('builder_cta', { platform, feature_count: chosen.length, features: chosen.map((feature) => feature.id).join(',') });
        const list = chosen.map((feature) => feature.label.toLowerCase()).join(', ');
        prefillContact(`Hi Maneet, I'm thinking about an app for ${platformInfo.label}${list ? ` with ${list}` : ''}. Here's the idea: `);
    };

    return (
        <div className="grid overflow-hidden rounded-[2rem] border border-line bg-surface lg:grid-cols-[minmax(0,7fr)_minmax(0,5fr)]">
            <div className="min-w-0 p-4 sm:p-5">
                <ul className="-mx-4 flex gap-1.5 overflow-x-auto px-4 pb-1 [scrollbar-width:none] sm:-mx-5 sm:px-5 lg:mx-0 lg:flex-wrap lg:overflow-visible lg:px-0 lg:pb-0">
                    {services.map((service) => {
                        const isActive = service === activeService;
                        return (
                            <li key={service.id} className="shrink-0">
                                <button
                                    type="button"
                                    onClick={() => applyService(service)}
                                    aria-pressed={isActive}
                                    aria-label={service.title}
                                    className={`h-10 whitespace-nowrap rounded-full border px-3.5 text-[13px] font-semibold transition-colors ${isActive ? 'swift-gradient border-transparent text-ink' : 'border-line text-paper hover:bg-raised'}`}
                                >
                                    {service.short}
                                </button>
                            </li>
                        );
                    })}
                </ul>

                {/* The chosen service's description, with space held so nothing jumps */}
                <p className="mt-2 min-h-10 text-[13px] leading-snug text-muted" aria-live="polite">
                    {activeService ? activeService.body : 'Your own mix. Add or remove anything below.'}
                </p>

                <ul className="mt-2 flex flex-wrap gap-1.5">
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
                                    className={`flex h-10 items-center gap-1.5 rounded-full px-3 text-[13px] font-medium transition-colors ${isOn ? 'bg-paper text-ink' : 'bg-white/8 text-paper hover:bg-white/12'}`}
                                >
                                    <Icon size={15} aria-hidden="true" /> {label}
                                </motion.button>
                            </li>
                        );
                    })}
                </ul>
            </div>

            <div className="flex min-w-0 flex-col gap-3 border-t border-line bg-ink/40 p-4 sm:p-5 lg:border-l lg:border-t-0">
                <div className="flex rounded-full bg-ink p-1">
                    {platforms.map(({ id, label }) => (
                        <button
                            key={id}
                            type="button"
                            onClick={() => {
                                track('builder_platform', { platform: id });
                                setPlatform(id);
                            }}
                            aria-pressed={platform === id}
                            className={`relative h-9 flex-1 rounded-full text-[13px] font-medium transition-colors ${platform === id ? 'text-ink' : 'text-muted hover:text-paper'}`}
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

                <p className="text-[13px] leading-relaxed">
                    <span className="font-mono text-muted">Built with </span>
                    {stack.join(' · ')}
                </p>

                {proof.length > 0 && (
                    <div className="flex items-center gap-2.5">
                        <span aria-hidden="true" className="flex shrink-0 -space-x-2">
                            {proof.slice(0, 4).map((project) => (
                                <span key={project.id} className="rounded-[9px] ring-2 ring-surface"><AppIcon project={project} size={28} /></span>
                            ))}
                        </span>
                        <p className="min-w-0 text-[13px] leading-snug text-muted">
                            Done before in {nameList(proof.map((project) => project.title))}
                        </p>
                    </div>
                )}

                <button
                    type="button"
                    onClick={talkAboutIt}
                    className="swift-gradient mt-auto flex h-11 w-full shrink-0 items-center justify-center gap-2 rounded-full text-sm font-semibold text-ink transition-transform hover:scale-[1.02]"
                >
                    Talk about this app <ArrowRight size={17} aria-hidden="true" />
                </button>
            </div>
        </div>
    );
};

export default AppBuilder;
