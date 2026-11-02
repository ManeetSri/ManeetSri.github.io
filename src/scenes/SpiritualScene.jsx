import { motion, useTransform } from 'framer-motion';
import { Check, Users } from 'lucide-react';
import { Scene, Reveal, Ring } from './shared';

const GOLD = '#F5C451';
const ITEMS = ['Family', 'Health', 'Community', 'Gratitude'];

const PrayerItem = ({ p, label, index }) => {
    const from = 0.12 + index * 0.15;
    const done = useTransform(p, [from, from + 0.06], [0, 1]);

    return (
        <div className="flex items-center gap-3 rounded-2xl bg-white/8 px-3.5 py-3">
            <span className="relative h-6 w-6 rounded-full border-2 border-white/30">
                <motion.span style={{ opacity: done, scale: done, background: GOLD }} className="absolute -inset-[2px] flex items-center justify-center rounded-full">
                    <Check size={14} className="text-black" />
                </motion.span>
            </span>
            <span className="text-[15px]">{label}</span>
        </div>
    );
};

const SpiritualScene = ({ p }) => {
    const days = useTransform(p, [0.1, 0.8], [0, 21]);
    const label = useTransform(days, (value) => Math.round(value));

    return (
        <Scene background="linear-gradient(180deg,#1c1b4b,#0d0d24)">
            <div className="flex h-full flex-col px-4">
                <div className="flex justify-center py-2">
                    <Ring p={p} from={0.1} to={0.8} size={136} width={13} color={GOLD}>
                        <div className="text-center">
                            <motion.p className="text-[34px] font-bold leading-none">{label}</motion.p>
                            <p className="mt-1 text-[12px] text-white/70">day habit</p>
                        </div>
                    </Ring>
                </div>
                <p className="mb-2 mt-3 text-[17px] font-bold">My prayer list</p>
                <div className="space-y-2">
                    {ITEMS.map((item, index) => (
                        <PrayerItem key={item} p={p} label={item} index={index} />
                    ))}
                </div>
                <Reveal p={p} from={0.78} to={0.9} className="mt-auto mb-2 flex items-center gap-2.5 rounded-2xl p-3 text-[13px] font-semibold text-black" >
                    <span className="flex w-full items-center justify-center gap-2 rounded-2xl py-3" style={{ background: GOLD }}>
                        <Users size={17} /> Share with your community
                    </span>
                </Reveal>
            </div>
        </Scene>
    );
};

export default SpiritualScene;
