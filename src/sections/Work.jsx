import { motion, useTransform } from 'framer-motion';
import ProjectPanel from './ProjectPanel';
import Phone from '../components/device/Phone';
import WorkScreens from '../components/device/WorkScreens';
import { CLOSE, LAUNCH, segments, totalUnits } from '../data/workTimeline';

const INTRO_END = segments[0].start;

const PanelLayer = ({ p, range, isActive, onFocus, children }) => {
    const [from, in1, out1, to] = range;
    const opacity = useTransform(p, [from, in1, out1, to], [0, 1, 1, 0]);
    const y = useTransform(p, [from, in1, out1, to], [28, 0, 0, -28]);

    return (
        <motion.div
            style={{ opacity, y, pointerEvents: isActive ? 'auto' : 'none' }}
            onFocus={onFocus}
            className="absolute inset-0 flex flex-col justify-start lg:justify-center"
        >
            {children}
        </motion.div>
    );
};

const IntroLayer = ({ p, isActive, onSkip }) => {
    const opacity = useTransform(p, [INTRO_END * 0.6, INTRO_END], [1, 0]);
    const y = useTransform(p, [INTRO_END * 0.6, INTRO_END], [0, -28]);

    return (
        <motion.div style={{ opacity, y, pointerEvents: isActive ? 'auto' : 'none' }} className="absolute inset-0 flex flex-col justify-start lg:justify-center">
            <p className="font-mono text-sm text-swift lg:mb-3">The work</p>
            <h2 className="font-display text-[clamp(1.9rem,5vw,4.5rem)] font-semibold leading-[1.02] tracking-tight">Eight apps. Keep scrolling to open them.</h2>
            <p className="mt-2 max-w-xl text-sm text-muted lg:mt-5 lg:text-lg">Ride-hailing, wellbeing, retail, jobs, faith, school and an open-source package.</p>
            <a href="#skills" onClick={onSkip} className="mt-3 w-fit font-mono text-sm text-muted underline underline-offset-4 hover:text-paper lg:mt-6">Skip apps</a>
        </motion.div>
    );
};

const Work = ({ ref, p, active, onJump, showPhone }) => (
    <section ref={ref} id="work" style={{ height: `${(totalUnits + 1) * 100}svh` }} className="relative">
        <div className="sticky top-0 flex h-svh flex-col gap-3 overflow-hidden px-5 pb-20 pt-5 sm:px-10 lg:flex-row lg:items-center lg:py-0 lg:pl-[max(2.5rem,5vw)] lg:pr-4">
            {showPhone && (
                <div className="min-h-0 flex-1">
                    <Phone>
                        <WorkScreens p={p} active={active} onFocusScene={onJump} />
                    </Phone>
                </div>
            )}

            <div className="flex w-full shrink-0 items-center gap-4 lg:h-full lg:flex-1">
                <div aria-hidden="true" className="hidden flex-col gap-2 lg:flex">
                    {segments.map(({ project }, index) => (
                        <span
                            key={project.id}
                            className="h-2 w-2 rounded-full transition-all duration-300"
                            style={{ background: active === index ? project.tint : 'var(--color-line)', transform: active === index ? 'scale(1.5)' : 'none' }}
                        />
                    ))}
                </div>

                <div className="relative h-[196px] min-w-0 flex-1 lg:h-[82svh]">
                    <IntroLayer
                        p={p}
                        isActive={active === -1}
                        onSkip={(event) => {
                            event.preventDefault();
                            document.getElementById('skills')?.scrollIntoView();
                        }}
                    />
                    {segments.map(({ project, start, end }, index) => (
                        <PanelLayer
                            key={project.id}
                            p={p}
                            range={[start, start + LAUNCH * 0.7, end - CLOSE * 0.7, end]}
                            isActive={active === index}
                            onFocus={() => active !== index && onJump(index)}
                        >
                            <article><ProjectPanel project={project} /></article>
                        </PanelLayer>
                    ))}
                </div>
            </div>
        </div>
    </section>
);

export default Work;
