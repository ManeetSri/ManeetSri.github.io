import { useState } from 'react';
import { motion, useMotionValueEvent, useScroll } from 'framer-motion';
import { career } from '../../data/career';

const Row = ({ entry, state }) => (
    <motion.div
        initial={false}
        animate={{ opacity: state === 'active' ? 1 : state === 'past' ? 0.6 : 0.35 }}
        transition={{ duration: 0.35 }}
        className="relative border-b border-white/10 py-2.5 pl-3"
    >
        <motion.span
            initial={false}
            animate={{ scaleY: state === 'active' ? 1 : 0 }}
            transition={{ type: 'spring', stiffness: 400, damping: 30 }}
            className="swift-gradient absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-full"
        />
        <div className="flex items-baseline justify-between">
            <span className="text-[15px] font-semibold">Version {entry.version}</span>
            <span className="text-[12px] text-white/60">{entry.period.split(' – ')[0]}</span>
        </div>
        <p className="mt-0.5 text-[13px] font-medium text-[#FDB03A]">{entry.shortName}</p>
        <p className="mt-0.5 truncate text-[12px] leading-snug text-white/75">{entry.label}</p>
    </motion.div>
);

// The phone's view of the Journey section: an App Store version history for "Maneet".
// The highlighted row is the latest release note to reach the middle of the page, worked out
// from the scroll position so it stays right after a jump from the tab bar.
const VersionScreen = () => {
    const [activeIndex, setActiveIndex] = useState(0);
    const { scrollY } = useScroll();

    useMotionValueEvent(scrollY, 'change', () => {
        const notes = [...document.querySelectorAll('#journey ol > li')];
        const reached = notes.filter((note) => note.getBoundingClientRect().top <= window.innerHeight * 0.475);
        setActiveIndex(Math.max(0, reached.length - 1));
    });

    return (
        <div aria-hidden="true" className="absolute inset-0 bg-[#111216] px-4 pt-14">
            <div className="flex items-center gap-3 pb-3">
                <span className="swift-gradient flex h-14 w-14 items-center justify-center rounded-[13px] text-lg font-bold text-black">MS</span>
                <div>
                    <p className="text-[17px] font-semibold">Maneet</p>
                    <p className="text-[12px] text-white/60">iOS & mobile engineering</p>
                </div>
            </div>
            <p className="pb-1 text-[20px] font-bold">Version History</p>
            {career.map((entry, index) => {
                const state = index === activeIndex ? 'active' : index < activeIndex ? 'past' : 'next';
                return <Row key={entry.id} entry={entry} state={state} />;
            })}
        </div>
    );
};

export default VersionScreen;
