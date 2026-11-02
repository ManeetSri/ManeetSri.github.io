import { useEffect, useRef, useState } from 'react';
import { motion, useMotionValueEvent, useScroll, useSpring, useTransform } from 'framer-motion';
import Hero from './Hero';
import Journey from './Journey';
import Work from './Work';
import Phone from '../components/device/Phone';
import LockScreen from '../components/device/LockScreen';
import VersionScreen from '../components/device/VersionScreen';
import WorkScreens from '../components/device/WorkScreens';
import { activeIndexAt, segments } from '../data/workTimeline';

const DESKTOP_QUERY = '(min-width: 1024px)';

const useIsDesktop = () => {
    const [isDesktop, setIsDesktop] = useState(() => window.matchMedia(DESKTOP_QUERY).matches);

    useEffect(() => {
        const media = window.matchMedia(DESKTOP_QUERY);
        const onChange = (event) => setIsDesktop(event.matches);
        media.addEventListener('change', onChange);
        return () => media.removeEventListener('change', onChange);
    }, []);

    return isDesktop;
};

const Tint = ({ p, segment }) => {
    const { start, end, project } = segment;
    const fade = Math.min(0.14 * (end - start), 0.02);
    const opacity = useTransform(p, [start - fade, start + fade, end - fade, end + fade], [0, 1, 1, 0]);

    return (
        <motion.div
            style={{ opacity, background: `radial-gradient(70% 70% at 70% 45%, ${project.tint}33, transparent 75%)` }}
            className="absolute inset-0"
        />
    );
};

// A single phone stays pinned on desktop: locked in the hero, version history through the
// journey, then the home screen and apps through the work section.
const StagePhone = ({ heroP, journeyP, workP, active, onJump, ready }) => {
    const lockY = useTransform(heroP, [0.3, 0.8], ['0%', '-100%']);
    const versionOpacity = useTransform(journeyP, [0.93, 1], [1, 0]);
    const versionScale = useTransform(journeyP, [0.93, 1], [1, 0.2]);

    const tiltX = useSpring(0, { stiffness: 120, damping: 18 });
    const tiltY = useSpring(0, { stiffness: 120, damping: 18 });

    const onPointerMove = (event) => {
        if (!ready) return;
        tiltY.set((event.clientX / window.innerWidth - 0.5) * 12);
        tiltX.set((event.clientY / window.innerHeight - 0.5) * -8);
    };

    return (
        <div onPointerMove={onPointerMove} className="sticky top-0 h-svh self-start px-6 pb-20 pt-5 [perspective:1400px]">
            <motion.div style={{ rotateX: tiltX, rotateY: tiltY }} className="h-full w-full">
                <Phone>
                    <WorkScreens p={workP} active={active} onFocusScene={onJump} />
                    <motion.div style={{ opacity: versionOpacity, scale: versionScale }} className="absolute inset-0 origin-top-left">
                        <VersionScreen p={journeyP} />
                    </motion.div>
                    <motion.div style={{ y: lockY }} className="absolute inset-0">
                        <LockScreen ready={ready} />
                    </motion.div>
                </Phone>
            </motion.div>
        </div>
    );
};

const Stage = ({ ready }) => {
    const heroRef = useRef(null);
    const journeyRef = useRef(null);
    const workRef = useRef(null);
    const isDesktop = useIsDesktop();
    const [active, setActive] = useState(-1);

    const { scrollYProgress: heroP } = useScroll({ target: heroRef, offset: ['start start', 'end start'] });
    const { scrollYProgress: journeyP } = useScroll({ target: journeyRef, offset: ['start 60%', 'end 60%'] });
    const { scrollYProgress: workP } = useScroll({ target: workRef, offset: ['start start', 'end end'] });

    useMotionValueEvent(workP, 'change', (value) => {
        setActive(activeIndexAt(Math.min(value, 0.9999)));
    });

    const jumpToScene = (index) => {
        const section = workRef.current;
        const { start, end } = segments[index];
        const scrollable = section.offsetHeight - window.innerHeight;
        const sectionTop = section.getBoundingClientRect().top + window.scrollY;
        window.scrollTo({ top: sectionTop + ((start + end) / 2) * scrollable });
    };

    return (
        <div className="relative">
            <div aria-hidden="true" className="pointer-events-none fixed inset-0 -z-10">
                {segments.map((segment) => (
                    <Tint key={segment.project.id} p={workP} segment={segment} />
                ))}
            </div>

            <div className="lg:grid lg:grid-cols-[minmax(0,1fr)_minmax(380px,38vw)]">
                <div className="min-w-0">
                    <Hero ref={heroRef} ready={ready} showPhone={!isDesktop} />
                    <Journey ref={journeyRef} />
                    <Work ref={workRef} p={workP} active={active} onJump={jumpToScene} showPhone={!isDesktop} />
                </div>
                {isDesktop && (
                    <StagePhone heroP={heroP} journeyP={journeyP} workP={workP} active={active} onJump={jumpToScene} ready={ready} />
                )}
            </div>
        </div>
    );
};

export default Stage;
