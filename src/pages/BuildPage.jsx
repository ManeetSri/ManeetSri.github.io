import { useEffect, useRef, useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { ArrowLeft, ArrowRight, Check, RotateCcw, Share2, Sparkles, X } from 'lucide-react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import AppIcon from '../components/device/AppIcon';
import { features, platforms, services } from '../data/services';
import { usePageMeta } from '../hooks/usePageMeta';
import { track } from '../analytics';
import { FeaturesLevel, IntroLevel, MissionLevel, PathLevel, PlatformLevel, PrimaryButton, RideLevel } from '../game/Levels';
import { proofFor, stackFor, useFocusOnMount } from '../game/gameData';

const LEVELS = ['intro', 'mission', 'platform', 'features', 'ride', 'path', 'result'];
const PLAYABLE_LEVELS = 5;
const NEXT_LEVEL_DELAY_MS = 450;
const SHIP_DELAY_MS = 1100;

const XP = { mission: 100, platform: 100, feature: 50, ride: 200, polish: 50, ship: 300 };

const rankFor = (xp) => {
    if (xp >= 1100) return 'Ship Captain';
    if (xp >= 800) return 'App Maker';
    return 'Weekend Builder';
};

// Fixed positions, so the burst looks scattered without any randomness at render time
const CONFETTI = Array.from({ length: 36 }, (_, index) => ({
    x: Math.sin(index * 12.9898) * 320,
    y: -120 - Math.abs(Math.cos(index * 78.233)) * 300,
    rotate: (index * 47) % 360,
    delay: (index % 6) * 0.03,
    color: ['#F05138', '#FDB03A', '#F2F0EB', '#30D158'][index % 4],
}));

const Confetti = () => (
    <div aria-hidden="true" className="pointer-events-none absolute left-1/2 top-40 z-10 motion-reduce:hidden">
        {CONFETTI.map(({ x, y, rotate, delay, color }, index) => (
            <motion.span
                key={index}
                initial={{ x: 0, y: 0, opacity: 1, rotate: 0 }}
                animate={{ x, y: [0, y, y + 460], opacity: [1, 1, 0], rotate: rotate + 360 }}
                transition={{ duration: 1.9, delay, ease: 'easeOut' }}
                className="absolute h-2.5 w-1.5 rounded-sm"
                style={{ background: color }}
            />
        ))}
    </div>
);

const ResultScreen = ({ name, platform, selected, version, xp, onTalk, onReplay }) => {
    const [shareLabel, setShareLabel] = useState('Share the game');
    const headingRef = useFocusOnMount();
    const appName = name.trim() || 'My App';
    const chosen = features.filter((feature) => selected.includes(feature.id));
    const proof = proofFor(selected);
    const platformLabel = platforms.find((item) => item.id === platform).label;

    const share = async () => {
        const url = `${window.location.origin}/build`;
        track('game_share');
        try {
            if (navigator.share) {
                await navigator.share({ title: 'Ship your app', url });
            } else {
                await navigator.clipboard.writeText(url);
                setShareLabel('Link copied');
            }
        } catch {
            // The visitor closed the share sheet, or the browser refused
        }
    };

    return (
        <div className="relative mx-auto max-w-3xl">
            <Confetti />
            <p className="mb-2 flex items-center gap-2 font-mono text-sm text-[#30D158]">
                <Check size={16} strokeWidth={3} aria-hidden="true" /> Build succeeded · Shipped
            </p>
            <h2 ref={headingRef} tabIndex={-1} className="font-display text-[clamp(2.4rem,6vw,4.5rem)] font-semibold leading-none tracking-tight focus:outline-none">
                You shipped it.
            </h2>

            <motion.div
                initial={{ opacity: 0, y: 24, scale: 0.96 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                transition={{ type: 'spring', stiffness: 240, damping: 24, delay: 0.15 }}
                className="mt-6 overflow-hidden rounded-[2rem] border border-line bg-surface"
            >
                <div className="flex items-center gap-4 p-5">
                    <span className="swift-gradient flex h-20 w-20 shrink-0 items-center justify-center rounded-[20px] font-display text-3xl font-bold text-ink">
                        {appName[0].toUpperCase()}
                    </span>
                    <div className="min-w-0">
                        <p className="truncate font-display text-3xl font-semibold tracking-tight">{appName}</p>
                        <p className="text-muted">{platformLabel} · Version 1.{version}</p>
                    </div>
                </div>

                <dl className="grid grid-cols-2 border-y border-line text-center">
                    <div className="border-r border-line p-3">
                        <dt className="font-mono text-xs text-muted">XP</dt>
                        <dd className="font-display text-3xl font-semibold swift-gradient-text">{xp}</dd>
                    </div>
                    <div className="p-3">
                        <dt className="font-mono text-xs text-muted">Rank</dt>
                        <dd className="pt-1 font-display text-xl font-semibold sm:text-2xl">{rankFor(xp)}</dd>
                    </div>
                </dl>

                <div className="space-y-4 p-5">
                    <div>
                        <h3 className="mb-1.5 font-semibold">What's in it</h3>
                        <p className="text-sm leading-relaxed text-muted">{chosen.map((feature) => feature.label).join(' · ')}</p>
                    </div>
                    <div>
                        <h3 className="mb-1.5 font-semibold">Built with</h3>
                        <p className="text-sm leading-relaxed text-muted">{stackFor(platform, selected).join(' · ')}</p>
                    </div>
                    {proof.length > 0 && (
                        <div>
                            <h3 className="mb-2 font-semibold">Maneet has built this for real in</h3>
                            <ul className="flex flex-wrap gap-2">
                                {proof.map((project) => (
                                    <li key={project.id} className="flex items-center gap-1.5 rounded-full bg-white/8 py-1 pl-1 pr-3 text-[13px]">
                                        <AppIcon project={project} size={24} /> {project.title}
                                    </li>
                                ))}
                            </ul>
                        </div>
                    )}
                </div>
            </motion.div>

            <p className="mt-6 text-lg leading-relaxed text-paper/85">That was the game version. Want to build the real one?</p>
            <PrimaryButton onClick={onTalk} className="mt-3 w-full sm:w-auto">
                Talk to Maneet about {appName} <ArrowRight size={18} aria-hidden="true" />
            </PrimaryButton>
            <div className="mt-3 flex flex-wrap gap-2">
                <button type="button" onClick={onReplay} className="inline-flex h-11 items-center gap-2 rounded-full bg-white/8 px-4 text-sm font-medium hover:bg-white/12">
                    <RotateCcw size={16} aria-hidden="true" /> Play again
                </button>
                <button type="button" onClick={share} className="inline-flex h-11 items-center gap-2 rounded-full bg-white/8 px-4 text-sm font-medium hover:bg-white/12">
                    <Share2 size={16} aria-hidden="true" /> {shareLabel}
                </button>
                <Link to="/" data-event="game_exit" data-event-level="result" className="inline-flex h-11 items-center gap-2 rounded-full bg-white/8 px-4 text-sm font-medium hover:bg-white/12">
                    See the portfolio
                </Link>
            </div>
        </div>
    );
};

// A separate page: five levels from an idea to a shipped app
const BuildPage = () => {
    usePageMeta({
        title: 'Ship Your App: A Mobile App Building Game | Maneet Srivastav',
        description: 'Plan an iOS or Android app in five quick levels: choose a mission, pick a platform, add features, test a ride and take it to the App Store.',
        path: '/build',
    });

    const navigate = useNavigate();
    const [searchParams] = useSearchParams();
    const startingMission = services.find((service) => service.id === searchParams.get('mission'));

    const [levelIndex, setLevelIndex] = useState(0);
    const [name, setName] = useState('');
    const [mission, setMission] = useState(startingMission?.id ?? null);
    const [platform, setPlatform] = useState(startingMission?.platform ?? 'ios');
    const [selected, setSelected] = useState(startingMission?.features ?? []);
    const [version, setVersion] = useState(0);
    const [xp, setXp] = useState(0);
    const [xpPop, setXpPop] = useState(null);
    const [rideDone, setRideDone] = useState(false);
    const earned = useRef(new Set());
    const timers = useRef([]);
    const startedAt = useRef(null);

    const level = LEVELS[levelIndex];
    const playableNumber = levelIndex;
    const isPlaying = level !== 'intro' && level !== 'result';

    useEffect(() => {
        const pending = timers.current;
        return () => pending.forEach(clearTimeout);
    }, []);

    useEffect(() => {
        window.scrollTo({ top: 0, behavior: 'instant' });
    }, [levelIndex]);

    const earn = (key, amount) => {
        if (earned.current.has(key)) return;
        earned.current.add(key);
        setXp((value) => value + amount);
        setXpPop({ id: key, amount });
    };

    const goNext = () => {
        setLevelIndex((index) => {
            track('game_level', { level: LEVELS[index + 1] });
            return index + 1;
        });
    };

    const goNextSoon = (delay = NEXT_LEVEL_DELAY_MS) => {
        timers.current.push(setTimeout(goNext, delay));
    };

    const start = () => {
        track('game_start', { from_mission: Boolean(startingMission) });
        startedAt.current = performance.now();
        goNext();
    };

    const pickMission = (service) => {
        track('builder_preset', { service: service.id });
        setMission(service.id);
        setPlatform(service.platform);
        setSelected(service.features);
        earn('mission', XP.mission);
        goNextSoon();
    };

    const pickPlatform = (id) => {
        track('builder_platform', { platform: id });
        setPlatform(id);
        earn('platform', XP.platform);
        goNextSoon();
    };

    const toggleFeature = (id) => {
        track('builder_feature', { feature: id, on: !selected.includes(id) });
        setSelected((current) => (current.includes(id) ? current.filter((item) => item !== id) : [...current, id]));
        earn(`feature-${id}`, XP.feature);
    };

    const onRideArrive = () => {
        setRideDone(true);
        earn('ride', XP.ride);
    };

    const onNotYet = () => {
        setVersion((value) => value + 1);
        setXp((value) => value + XP.polish);
        setXpPop({ id: `polish-${performance.now()}`, amount: XP.polish });
    };

    const onShip = () => {
        earn('ship', XP.ship);
        track('game_complete', {
            platform,
            feature_count: selected.length,
            xp: xp + XP.ship,
            seconds: startedAt.current ? Math.round((performance.now() - startedAt.current) / 1000) : 0,
        });
        goNextSoon(SHIP_DELAY_MS);
    };

    const replay = () => {
        track('game_replay');
        earned.current = new Set();
        setXp(0);
        setXpPop(null);
        setVersion(0);
        setRideDone(false);
        setMission(null);
        setSelected([]);
        setPlatform('ios');
        startedAt.current = performance.now();
        setLevelIndex(1);
    };

    const talk = () => {
        const appName = name.trim() || 'an app';
        const list = features.filter((feature) => selected.includes(feature.id)).map((feature) => feature.label.toLowerCase()).join(', ');
        const platformLabel = platforms.find((item) => item.id === platform).label;
        track('builder_cta', { platform, feature_count: selected.length, features: selected.join(','), source: 'game' });
        navigate('/#contact', {
            state: { prefill: `Hi Maneet, I just played your game and I'd like to talk about ${appName}, for ${platformLabel}${list ? `, with ${list}` : ''}. Here's the idea: ` },
        });
    };

    return (
        <div className="relative min-h-svh overflow-x-clip bg-[radial-gradient(90%_50%_at_50%_0%,rgba(240,81,56,0.13),transparent_70%)]">
            <header className="sticky top-0 z-30 border-b border-line bg-ink/85 backdrop-blur-md">
                <div className="mx-auto flex h-14 max-w-6xl items-center gap-3 px-3 sm:px-6">
                    <Link
                        to="/"
                        aria-label="Exit the game and go back to the portfolio"
                        data-event="game_exit"
                        data-event-level={level}
                        className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-white/8 hover:bg-white/12"
                    >
                        <X size={20} aria-hidden="true" />
                    </Link>
                    {isPlaying && playableNumber > 1 && (
                        <button
                            type="button"
                            onClick={() => setLevelIndex((index) => index - 1)}
                            aria-label="Back to the previous level"
                            className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-white/8 hover:bg-white/12"
                        >
                            <ArrowLeft size={20} aria-hidden="true" />
                        </button>
                    )}

                    <div className="min-w-0 flex-1">
                        <p className="mb-1 truncate font-mono text-xs text-muted">
                            {level === 'intro' && 'Ship your app'}
                            {isPlaying && `Level ${playableNumber} of ${PLAYABLE_LEVELS}`}
                            {level === 'result' && 'Finished'}
                        </p>
                        <div className="h-1.5 overflow-hidden rounded-full bg-white/10">
                            <motion.div
                                initial={false}
                                animate={{ scaleX: Math.min(levelIndex / (LEVELS.length - 1), 1) }}
                                transition={{ type: 'spring', stiffness: 120, damping: 20 }}
                                className="swift-gradient h-full origin-left"
                            />
                        </div>
                    </div>

                    <div className="relative shrink-0 rounded-full bg-white/8 px-3 py-1.5 font-mono text-sm" aria-live="polite">
                        <span className="sr-only">Experience points: </span>
                        <span className="text-amber"><Sparkles size={14} aria-hidden="true" className="-mt-0.5 mr-1 inline" />{xp}</span>
                        <AnimatePresence>
                            {xpPop && (
                                <motion.span
                                    key={xpPop.id}
                                    aria-hidden="true"
                                    initial={{ opacity: 0, y: 8 }}
                                    animate={{ opacity: [0, 1, 1, 0], y: [8, 26, 34, 44] }}
                                    transition={{ duration: 1.1 }}
                                    className="absolute right-2 top-full font-semibold text-[#30D158]"
                                >
                                    +{xpPop.amount}
                                </motion.span>
                            )}
                        </AnimatePresence>
                    </div>
                </div>
            </header>

            <main className="mx-auto max-w-6xl px-5 pb-20 pt-8 sm:px-6 lg:pt-12">
                <AnimatePresence mode="wait" initial={false}>
                    <motion.div
                        key={level}
                        initial={{ opacity: 0, x: 40 }}
                        animate={{ opacity: 1, x: 0 }}
                        exit={{ opacity: 0, x: -40 }}
                        transition={{ duration: 0.24, ease: 'easeOut' }}
                    >
                        {level === 'intro' && <IntroLevel name={name} setName={setName} onStart={start} hasMission={Boolean(startingMission)} />}
                        {level === 'mission' && <MissionLevel mission={mission} onPick={pickMission} />}
                        {level === 'platform' && <PlatformLevel platform={platform} onPick={pickPlatform} />}
                        {level === 'features' && <FeaturesLevel name={name} platform={platform} selected={selected} onToggle={toggleFeature} onContinue={goNext} />}
                        {level === 'ride' && <RideLevel arrived={rideDone} onArrive={onRideArrive} onContinue={goNext} />}
                        {level === 'path' && <PathLevel onNotYet={onNotYet} onShip={onShip} />}
                        {level === 'result' && <ResultScreen name={name} platform={platform} selected={selected} version={version} xp={xp} onTalk={talk} onReplay={replay} />}
                    </motion.div>
                </AnimatePresence>
            </main>
        </div>
    );
};

export default BuildPage;
