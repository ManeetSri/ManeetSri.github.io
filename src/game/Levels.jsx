import { useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { ArrowRight, Check, Rocket, Smartphone } from 'lucide-react';
import AppIcon from '../components/device/AppIcon';
import Phone from '../components/device/Phone';
import { features, platforms, services } from '../data/services';
import { FEATURE_ICONS, SERVICE_ICONS } from './icons';
import { proofFor, stackFor, useFocusOnMount } from './gameData';
import ProjectFlow from './ProjectFlow';
import RideDemo from './RideDemo';

export const PrimaryButton = ({ children, className = '', ...props }) => (
    <button
        type="button"
        className={`swift-gradient inline-flex h-12 items-center justify-center gap-2 rounded-full px-7 font-semibold text-ink transition-transform hover:scale-[1.02] disabled:cursor-not-allowed disabled:opacity-40 disabled:hover:scale-100 ${className}`}
        {...props}
    >
        {children}
    </button>
);

export const IntroLevel = ({ name, setName, onStart, hasMission }) => (
    <div className="grid items-center gap-10 lg:grid-cols-[minmax(0,1fr)_340px]">
        <div>
            <p className="mb-3 font-mono text-sm text-swift">Got an idea?</p>
            <h1 className="font-display text-[clamp(2.6rem,6vw,5rem)] font-semibold leading-none tracking-tight">
                Let's see what your app could be.
            </h1>
            <p className="mt-5 max-w-xl text-lg leading-relaxed text-muted">
                Five quick levels take your idea from first thought to the App Store. Earn XP, make the calls, and see what you've shipped at the end.
            </p>
            <form
                onSubmit={(event) => {
                    event.preventDefault();
                    onStart();
                }}
                className="mt-8 max-w-md"
            >
                <label htmlFor="game-app-name" className="mb-1.5 block text-sm text-muted">Name your app</label>
                <input
                    id="game-app-name"
                    type="text"
                    maxLength={24}
                    autoComplete="off"
                    value={name}
                    onChange={(event) => setName(event.target.value)}
                    placeholder="My App"
                    className="w-full rounded-2xl border border-line bg-surface px-4 py-3 text-base text-paper placeholder:text-muted/80 focus:border-amber focus:outline-none"
                />
                <PrimaryButton type="submit" className="mt-4 w-full sm:w-auto">
                    {hasMission ? 'Continue your mission' : 'Start the game'} <ArrowRight size={18} aria-hidden="true" />
                </PrimaryButton>
            </form>
        </div>

        <div className="mx-auto h-[400px] w-full max-w-[240px] lg:h-[520px] lg:max-w-none">
            <Phone>
                <HomeScreenPreview name={name} selected={[]} />
            </Phone>
        </div>
    </div>
);

const LevelHeading = ({ number, title, intro }) => {
    const headingRef = useFocusOnMount();

    return (
        <div className="mb-5 lg:mb-6">
            <p className="mb-1.5 font-mono text-sm text-swift">Level {number}</p>
            <h2 ref={headingRef} tabIndex={-1} className="font-display text-[clamp(2rem,4.5vw,3.5rem)] font-semibold leading-none tracking-tight focus:outline-none">{title}</h2>
            <p className="mt-2.5 max-w-2xl leading-relaxed text-muted lg:mt-3 lg:text-lg">{intro}</p>
        </div>
    );
};

export const MissionLevel = ({ mission, onPick }) => (
    <div>
        <LevelHeading number={1} title="Choose your mission" intro="What are you setting out to build? This sets up your starting features." />
        <ul className="grid gap-2 sm:grid-cols-2 sm:gap-3 lg:grid-cols-3">
            {services.map((service, index) => {
                const Icon = SERVICE_ICONS[service.id];
                const isActive = mission === service.id;
                return (
                    <motion.li key={service.id} initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: index * 0.05 }}>
                        <motion.button
                            type="button"
                            whileTap={{ scale: 0.97 }}
                            onClick={() => onPick(service)}
                            aria-pressed={isActive}
                            className={`flex h-full w-full items-start gap-3 rounded-3xl border p-3.5 text-left transition-colors sm:flex-col sm:p-5 ${isActive ? 'border-amber bg-amber/10' : 'border-line bg-surface hover:bg-raised'}`}
                        >
                            <span className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl sm:h-12 sm:w-12 ${isActive ? 'swift-gradient text-ink' : 'bg-white/8 text-amber'}`}>
                                <Icon size={22} aria-hidden="true" />
                            </span>
                            <span className="min-w-0">
                                <span className="block font-semibold leading-snug">{service.title}</span>
                                <span className="mt-1 block text-[13px] leading-snug text-muted sm:mt-2 sm:text-sm">{service.body}</span>
                            </span>
                        </motion.button>
                    </motion.li>
                );
            })}
        </ul>
    </div>
);

export const PlatformLevel = ({ platform, onPick }) => (
    <div>
        <LevelHeading number={2} title="Where will it run?" intro="Native for the best iPhone experience, or one codebase for both platforms." />
        <div className="grid gap-3 sm:grid-cols-2">
            {platforms.map(({ id, label, stack }) => {
                const isActive = platform === id;
                return (
                    <motion.button
                        key={id}
                        type="button"
                        whileTap={{ scale: 0.97 }}
                        onClick={() => onPick(id)}
                        aria-pressed={isActive}
                        className={`rounded-3xl border p-6 text-left transition-colors ${isActive ? 'border-amber bg-amber/10' : 'border-line bg-surface hover:bg-raised'}`}
                    >
                        <span className="mb-4 flex gap-1 text-amber" aria-hidden="true">
                            <Smartphone size={30} />
                            {id === 'both' && <Smartphone size={30} />}
                        </span>
                        <span className="block font-display text-3xl font-semibold tracking-tight">{label}</span>
                        <span className="mt-2 block text-muted">{stack.join(' · ')}</span>
                    </motion.button>
                );
            })}
        </div>
    </div>
);

export const HomeScreenPreview = ({ name, selected }) => {
    const chosen = features.filter((feature) => selected.includes(feature.id));

    return (
        <div aria-hidden="true" className="absolute inset-0 bg-[radial-gradient(110%_60%_at_20%_0%,#5a2214_0%,#14161c_60%,#0a0b0f_100%)] px-6 pt-16">
            <p className="truncate text-center text-[26px] font-bold">{name.trim() || 'My App'}</p>
            <p className="mb-6 text-center text-[13px] text-white/65">
                {chosen.length === 0 ? 'Waiting for features' : `${chosen.length} feature${chosen.length === 1 ? '' : 's'} installed`}
            </p>
            <div className="grid grid-cols-4 gap-x-3 gap-y-4">
                <AnimatePresence initial={false}>
                    {chosen.map(({ id, label }) => {
                        const Icon = FEATURE_ICONS[id];
                        return (
                            <motion.div
                                key={id}
                                initial={{ scale: 0, opacity: 0 }}
                                animate={{ scale: 1, opacity: 1 }}
                                exit={{ scale: 0, opacity: 0 }}
                                transition={{ type: 'spring', stiffness: 480, damping: 22 }}
                                className="flex flex-col items-center"
                            >
                                <span className="swift-gradient flex h-[52px] w-[52px] items-center justify-center rounded-[13px] text-black">
                                    <Icon size={25} />
                                </span>
                                <span className="mt-1 w-[60px] truncate text-center text-[10px] text-white/85">{label}</span>
                            </motion.div>
                        );
                    })}
                </AnimatePresence>
            </div>
            <div className="absolute inset-x-3 bottom-3 h-[72px] rounded-[28px] bg-white/10" />
        </div>
    );
};

export const FeaturesLevel = ({ name, platform, selected, onToggle, onContinue }) => {
    const proof = proofFor(selected);

    return (
        <div>
            <LevelHeading number={3} title="Power up your app" intro="Every feature you add installs on the phone, and earns XP." />
            <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_320px]">
                <div className="min-w-0">
                    <ul className="flex flex-wrap gap-2">
                        {features.map(({ id, label }) => {
                            const Icon = FEATURE_ICONS[id];
                            const isOn = selected.includes(id);
                            return (
                                <li key={id}>
                                    <motion.button
                                        type="button"
                                        whileTap={{ scale: 0.92 }}
                                        onClick={() => onToggle(id)}
                                        aria-pressed={isOn}
                                        className={`flex h-11 items-center gap-1.5 rounded-full border px-3 text-sm font-medium transition-colors lg:h-12 lg:gap-2 lg:px-4 lg:text-base ${isOn ? 'border-transparent bg-paper text-ink' : 'border-line bg-surface hover:bg-raised'}`}
                                    >
                                        <Icon size={18} aria-hidden="true" /> {label}
                                    </motion.button>
                                </li>
                            );
                        })}
                    </ul>

                    <h3 className="mb-2 mt-6 font-mono text-sm text-muted">Built with</h3>
                    <ul className="flex flex-wrap gap-1.5">
                        {stackFor(platform, selected).map((item) => (
                            <li key={item} className="flex items-center gap-1 rounded-full bg-white/8 px-2.5 py-1 text-[13px]">
                                <Check size={13} className="text-[#30D158]" aria-hidden="true" /> {item}
                            </li>
                        ))}
                    </ul>

                    {proof.length > 0 && (
                        <>
                            <h3 className="mb-2 mt-5 font-mono text-sm text-muted">Maneet has done this before in</h3>
                            <ul className="flex flex-wrap gap-2">
                                {proof.map((project) => (
                                    <li key={project.id} className="flex items-center gap-1.5 rounded-full bg-white/8 py-1 pl-1 pr-3 text-[13px]">
                                        <AppIcon project={project} size={24} /> {project.title}
                                    </li>
                                ))}
                            </ul>
                        </>
                    )}

                    <PrimaryButton onClick={onContinue} disabled={selected.length === 0} className="sticky bottom-3 z-10 mt-6 w-full shadow-xl shadow-black/60 sm:w-auto lg:static lg:shadow-none">
                        Lock in features <ArrowRight size={18} aria-hidden="true" />
                    </PrimaryButton>
                </div>

                <div className="order-first mx-auto h-[230px] w-full max-w-[140px] lg:order-none lg:h-[560px] lg:max-w-none">
                    <Phone><HomeScreenPreview name={name} selected={selected} /></Phone>
                </div>
            </div>
        </div>
    );
};

export const RideLevel = ({ onArrive, arrived, onContinue }) => (
    <div>
        <LevelHeading number={4} title="Road test" intro="Real-time maps are hard to fake. Tap a destination, or drag through the trip, and finish a ride for bonus XP." />
        <div className="max-w-4xl"><RideDemo onArrive={onArrive} /></div>
        <div className="mt-6 flex flex-wrap items-center gap-3">
            <PrimaryButton onClick={onContinue} className="w-full sm:w-auto">
                {arrived ? 'Next level' : 'Skip the road test'} <ArrowRight size={18} aria-hidden="true" />
            </PrimaryButton>
        </div>
    </div>
);

export const PathLevel = ({ onNotYet, onShip }) => {
    const [shipped, setShipped] = useState(false);

    return (
        <div>
            <LevelHeading number={5} title="Get it to the App Store" intro='Move through each stage. At "Ready?", you decide. Going back to Build earns polish XP, and shipping finishes the game.' />
            <ProjectFlow
                manual
                onDecision={(choice) => {
                    if (choice === 'not_yet') onNotYet();
                    if (choice === 'ship' && !shipped) {
                        setShipped(true);
                        onShip();
                    }
                }}
            />
            {shipped && (
                <p role="status" className="mt-4 flex items-center gap-2 font-semibold text-[#30D158]">
                    <Rocket size={18} aria-hidden="true" /> Submitted to the App Store…
                </p>
            )}
        </div>
    );
};
