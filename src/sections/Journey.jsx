import { useRef } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';
import { career } from '../data/career';

// Each job is a feature branch off main that merges back, except the current one, which is still open
const MERGED_BRANCH = 'M 10 0 C 10 7, 26 5, 26 12 L 26 88 C 26 95, 10 93, 10 100';
const OPEN_BRANCH = 'M 10 0 C 10 7, 26 5, 26 12 L 26 100';

const VersionEntry = ({ entry, isCurrent }) => {
    const ref = useRef(null);
    const { scrollYProgress } = useScroll({ target: ref, offset: ['start 80%', 'end 55%'] });
    // A clip rather than pathLength, which breaks on a stretched non-scaling stroke
    const clipPath = useTransform(scrollYProgress, [0, 1], ['inset(0 0 100% 0)', 'inset(0 0 0% 0)']);

    return (
        <motion.li
            ref={ref}
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-12% 0px' }}
            transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
            className="relative pb-14 pl-14 sm:pl-16"
        >
            <svg aria-hidden="true" viewBox="0 0 36 100" preserveAspectRatio="none" className="absolute left-0 top-0 h-full w-9">
                <path d="M 10 0 L 10 100" fill="none" stroke="var(--color-line)" strokeWidth="2" vectorEffect="non-scaling-stroke" />
            </svg>
            <motion.svg aria-hidden="true" viewBox="0 0 36 100" preserveAspectRatio="none" style={{ clipPath }} className="absolute left-0 top-0 h-full w-9">
                <path
                    d={isCurrent ? OPEN_BRANCH : MERGED_BRANCH}
                    fill="none"
                    stroke={isCurrent ? 'var(--color-amber)' : 'var(--color-swift)'}
                    strokeWidth="3"
                    vectorEffect="non-scaling-stroke"
                />
            </motion.svg>

            <p className="font-mono text-sm">
                <span className={isCurrent ? 'text-amber' : 'text-swift'}>v{entry.version}</span>
                <span className="text-muted"> · {entry.period} · {entry.location}</span>
            </p>
            <h3 className="mt-2 font-display text-3xl font-semibold tracking-tight sm:text-4xl">{entry.company}</h3>
            <p className="mt-1 text-paper/85">{entry.role}</p>
            <p className="mt-4 font-mono text-sm text-amber">{entry.label}</p>
            <ul className="mt-2 max-w-xl space-y-1.5 leading-relaxed text-muted">
                {entry.notes.map((note) => (
                    <li key={note} className="flex gap-2.5"><span aria-hidden="true" className="text-paper/40">–</span><span>{note}</span></li>
                ))}
            </ul>
        </motion.li>
    );
};

const Journey = ({ ref }) => (
    <section ref={ref} id="journey" className="px-5 pb-16 pt-24 sm:px-10 lg:pl-[max(2.5rem,5vw)] lg:pr-4">
        <p className="mb-3 font-mono text-sm text-swift">What's new</p>
        <h2 className="mb-14 font-display text-[clamp(2.4rem,5vw,4.5rem)] font-semibold leading-none tracking-tight">Release notes for a career.</h2>
        <ol>
            {career.map((entry, index) => (
                <VersionEntry key={entry.id} entry={entry} isCurrent={index === career.length - 1} />
            ))}
        </ol>
    </section>
);

export default Journey;
