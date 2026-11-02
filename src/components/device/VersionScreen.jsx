import { motion, useTransform } from 'framer-motion';
import { career } from '../../data/career';

const Row = ({ entry, index, p }) => {
    const from = index / career.length;
    const to = (index + 1) / career.length;
    const opacity = useTransform(p, [from - 0.08, from, to, to + 0.08], [0.4, 1, 1, index === career.length - 1 ? 1 : 0.4]);

    return (
        <motion.div style={{ opacity }} className="border-b border-white/10 py-3">
            <div className="flex items-baseline justify-between">
                <span className="text-[15px] font-semibold">Version {entry.version}</span>
                <span className="text-[12px] text-white/60">{entry.period.split(' – ')[0]}</span>
            </div>
            <p className="mt-0.5 text-[13px] font-medium text-[#FDB03A]">{entry.shortName}</p>
            <p className="mt-0.5 text-[12px] leading-snug text-white/75">{entry.label}</p>
        </motion.div>
    );
};

// The phone's view of the Journey section: an App Store version history for "Maneet"
const VersionScreen = ({ p }) => {
    const y = useTransform(p, [0, 1], [0, -120]);

    return (
        <div aria-hidden="true" className="absolute inset-0 flex flex-col bg-[#111216] px-4 pt-14">
            <div className="flex items-center gap-3 pb-4">
                <span className="swift-gradient flex h-14 w-14 items-center justify-center rounded-[13px] text-lg font-bold text-black">MS</span>
                <div>
                    <p className="text-[17px] font-semibold">Maneet</p>
                    <p className="text-[12px] text-white/60">iOS & mobile engineering</p>
                </div>
            </div>
            <p className="pb-1 text-[20px] font-bold">Version History</p>
            <div className="min-h-0 flex-1 overflow-hidden">
                <motion.div style={{ y }}>
                    {career.map((entry, index) => (
                        <Row key={entry.id} entry={entry} index={index} p={p} />
                    ))}
                </motion.div>
            </div>
        </div>
    );
};

export default VersionScreen;
