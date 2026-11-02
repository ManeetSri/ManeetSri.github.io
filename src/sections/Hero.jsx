import { motion } from 'framer-motion';
import { ArrowDown, ArrowRight, FileText, Github } from 'lucide-react';
import Phone from '../components/device/Phone';
import LockScreen from '../components/device/LockScreen';
import AppIcon from '../components/device/AppIcon';
import { getYearsOfExperience } from '../data/career';
import { projects } from '../data/projects';

const rise = (ready, delay) => ({
    initial: { opacity: 0, y: 26 },
    animate: ready ? { opacity: 1, y: 0 } : {},
    transition: { duration: 0.7, delay, ease: [0.16, 1, 0.3, 1] },
});

const secondaryButton = 'inline-flex h-12 items-center justify-center gap-2 rounded-full border border-line bg-white/5 px-5 font-medium transition-colors hover:bg-white/10';

const Hero = ({ ref, ready, showPhone }) => (
    <section ref={ref} id="top" className="flex min-h-svh flex-col justify-center px-5 pb-24 pt-16 sm:px-10 lg:pl-[max(2.5rem,5vw)] lg:pr-4 lg:pt-8">
        <motion.p {...rise(ready, 0)} className="mb-4 flex items-center gap-2 font-mono text-sm text-muted">
            <span className="relative flex h-2.5 w-2.5">
                <span className="absolute inset-0 animate-ping rounded-full bg-[#30D158] opacity-60 motion-reduce:animate-none" />
                <span className="relative h-2.5 w-2.5 rounded-full bg-[#30D158]" />
            </span>
            iOS & Android developer
        </motion.p>

        <motion.h1 {...rise(ready, 0.08)} className="font-display text-[clamp(2.7rem,6vw,5.6rem)] font-semibold leading-[0.98] tracking-tight">
            <span className="swift-gradient-text">iPhone apps</span> for getting around, shopping, school and prayer.
        </motion.h1>

        <motion.p {...rise(ready, 0.16)} className="mt-5 max-w-2xl text-lg leading-relaxed text-paper/85">
            I'm <strong className="font-semibold text-paper">Maneet Srivastav</strong>, a mobile app developer with {getYearsOfExperience()}+ years shipping production apps
            in Swift, SwiftUI, UIKit and React Native. Currently at Mahindra Logistics.
        </motion.p>

        <motion.div {...rise(ready, 0.24)} className="mt-6 grid grid-cols-2 gap-3 sm:flex sm:flex-wrap">
            <a href="#work" data-event="cta_click" data-event-cta="see_apps" className="swift-gradient col-span-2 inline-flex h-12 items-center justify-center gap-2 rounded-full px-6 font-semibold text-ink transition-transform hover:scale-[1.03]">
                See the apps <ArrowRight size={18} aria-hidden="true" />
            </a>
            <a href="/resume.pdf" target="_blank" rel="noopener noreferrer" data-event="resume_open" data-event-source="hero" className={secondaryButton}>
                <FileText size={18} aria-hidden="true" /> Resume
            </a>
            <a href="https://github.com/ManeetSri" target="_blank" rel="noopener noreferrer" data-event="profile_click" data-event-profile="github" data-event-source="hero" className={secondaryButton}>
                <Github size={18} aria-hidden="true" /> GitHub
            </a>
        </motion.div>

        <motion.a {...rise(ready, 0.32)} href="#work" data-event="cta_click" data-event-cta="app_icons" aria-label="Open the apps I've worked on" className="mt-7 block w-fit">
            <span className="flex flex-wrap gap-1.5 sm:gap-2">
                {projects.map((project) => (
                    <AppIcon key={project.id} project={project} size={36} />
                ))}
            </span>
        </motion.a>

        {showPhone ? (
            <div className="mx-auto mt-10 h-[520px] w-full max-w-sm">
                <Phone><LockScreen ready={ready} /></Phone>
            </div>
        ) : (
            <motion.p {...rise(ready, 0.4)} className="mt-7 flex items-center gap-2 font-mono text-sm text-muted">
                <ArrowDown size={16} aria-hidden="true" className="animate-bounce" /> Scroll to unlock
            </motion.p>
        )}
    </section>
);

export default Hero;
