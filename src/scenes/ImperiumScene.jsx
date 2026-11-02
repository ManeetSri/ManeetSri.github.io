import { motion, useTransform } from 'framer-motion';
import { Sparkles, UserRound } from 'lucide-react';
import { Scene, Reveal } from './shared';

const PURPLE = '#BF8CFF';
const CARDS = [
    { id: 'c', color: '#2c2240', depth: 2, from: 0.5, to: 0.62, direction: 1 },
    { id: 'b', color: '#3a2a57', depth: 1, from: 0.3, to: 0.42, direction: -1 },
    { id: 'a', color: '#4a3470', depth: 0, from: 0.08, to: 0.2, direction: 1 },
];

const JobCard = ({ p, card }) => {
    const { color, depth, from, to, direction } = card;
    const x = useTransform(p, [from, to], [0, direction * 340]);
    const rotate = useTransform(p, [from, to], [0, direction * 18]);

    return (
        <motion.div
            style={{ x, rotate, background: color, top: depth * 10, left: 16 + depth * 6, right: 16 + depth * 6 }}
            className="absolute bottom-16 flex flex-col rounded-[24px] p-5"
        >
            <span className="flex w-fit items-center gap-1 rounded-full bg-black/30 px-2.5 py-1 text-[12px] font-medium" style={{ color: PURPLE }}>
                <Sparkles size={12} /> AI match
            </span>
            <div className="mt-auto">
                <p className="text-[21px] font-bold">Sample role</p>
                <p className="text-[14px] text-white/75">Swipe right to apply</p>
            </div>
        </motion.div>
    );
};

const ImperiumScene = ({ p }) => {
    const seconds = useTransform(p, [0.68, 1], [0, 28]);
    const timer = useTransform(seconds, (value) => `00:${String(Math.round(value)).padStart(2, '0')}`);

    return (
        <Scene background="#120d1c">
            <p className="px-5 text-[22px] font-bold">Discover</p>

            <Reveal p={p} from={0.6} to={0.68} y={0} className="absolute inset-x-4 bottom-16 top-10 overflow-hidden rounded-[24px] bg-[#1d1730]">
                <div className="flex h-full flex-col items-center justify-center">
                    <UserRound size={120} strokeWidth={1} className="text-white/35" />
                    <p className="mt-3 text-[16px] font-semibold">Record your video intro</p>
                </div>
                <div className="absolute left-4 top-4 flex items-center gap-1.5 rounded-full bg-black/60 px-2.5 py-1 text-[13px] font-semibold">
                    <span className="h-2.5 w-2.5 rounded-full bg-[#FF453A]" />
                    <motion.span>{timer}</motion.span>
                </div>
                <span className="absolute bottom-5 left-1/2 flex h-14 w-14 -translate-x-1/2 items-center justify-center rounded-full border-[3px] border-white">
                    <span className="h-6 w-6 rounded-md bg-[#FF453A]" />
                </span>
            </Reveal>

            <div className="absolute inset-x-0 top-10 bottom-0">
                {CARDS.map((card) => (
                    <JobCard key={card.id} p={p} card={card} />
                ))}
            </div>
        </Scene>
    );
};

export default ImperiumScene;
