import { motion } from 'framer-motion';
import { ArrowDown, ArrowRight, FileText, Github } from 'lucide-react';
import Phone from '../components/device/Phone';
import LockScreen from '../components/device/LockScreen';
import { getYearsOfExperience } from '../data/career';

const rise = (ready, delay) => ({
    initial: { opacity: 0, y: 26 },
    animate: ready ? { opacity: 1, y: 0 } : {},
    transition: { duration: 0.7, delay, ease: [0.16, 1, 0.3, 1] },
});

const Hero = ({ ref, ready, showPhone }) => (
    <section ref={ref} id="top" className="flex min-h-svh flex-col justify-center px-5 pb-24 pt-14 sm:px-10 lg:pl-[max(2.5rem,5vw)] lg:pr-4">
        <motion.p {...rise(ready, 0)} className="mb-5 flex items-center gap-2 font-mono text-sm text-muted">
            <span className="relative flex h-2.5 w-2.5">
                <span className="absolute inset-0 animate-ping rounded-full bg-[#30D158] opacity-60 motion-reduce:animate-none" />
                <span className="relative h-2.5 w-2.5 rounded-full bg-[#30D158]" />
            </span>
            Running on iPhone
        </motion.p>

        <motion.h1 {...rise(ready, 0.08)} className="font-display text-[clamp(2.7rem,6.4vw,6rem)] font-semibold leading-[0.98] tracking-tight">
            <span className="swift-gradient-text">iPhone apps</span> for getting around, shopping, school and prayer.
        </motion.h1>

        <motion.p {...rise(ready, 0.16)} className="mt-6 max-w-2xl text-lg leading-relaxed text-paper/85">
            I'm <strong className="font-semibold text-paper">Maneet Srivastav</strong>, Assistant Manager – IT (Mobile Applications) at Mahindra Logistics.
            For {getYearsOfExperience()}+ years I've been shipping production apps with Swift, SwiftUI, UIKit and React Native.
        </motion.p>

        <motion.div {...rise(ready, 0.24)} className="mt-8 flex flex-wrap gap-3">
            <a href="#work" className="swift-gradient inline-flex h-12 items-center gap-2 rounded-full px-6 font-semibold text-ink transition-transform hover:scale-[1.03]">
                See the apps <ArrowRight size={18} aria-hidden="true" />
            </a>
            <a href="/resume.pdf" target="_blank" rel="noopener noreferrer" className="inline-flex h-12 items-center gap-2 rounded-full border border-line bg-white/5 px-5 font-medium transition-colors hover:bg-white/10">
                <FileText size={18} aria-hidden="true" /> Resume
            </a>
            <a href="https://github.com/ManeetSri" target="_blank" rel="noopener noreferrer" className="inline-flex h-12 items-center gap-2 rounded-full border border-line bg-white/5 px-5 font-medium transition-colors hover:bg-white/10">
                <Github size={18} aria-hidden="true" /> GitHub
            </a>
        </motion.div>

        {showPhone ? (
            <div className="mx-auto mt-12 h-[600px] w-full max-w-sm">
                <Phone><LockScreen ready={ready} /></Phone>
            </div>
        ) : (
            <motion.p {...rise(ready, 0.34)} className="mt-12 flex items-center gap-2 font-mono text-sm text-muted">
                <ArrowDown size={16} aria-hidden="true" className="animate-bounce" /> Scroll to unlock
            </motion.p>
        )}
    </section>
);

export default Hero;
