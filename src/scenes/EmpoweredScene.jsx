import { motion, useTransform } from 'framer-motion';
import { Sparkles, LifeBuoy } from 'lucide-react';
import { Scene, Reveal, Ring } from './shared';

const PINK = '#FF6FA8';
const MOODS = ['#FF6FA8', '#FFC2D9', '#FDB03A', '#FF6FA8', '#7FD1AE', '#7FD1AE', '#FFC2D9'];
const DAYS = Array.from({ length: 28 }, (_, day) => MOODS[(day * 3 + (day % 5)) % MOODS.length]);

const Day = ({ p, day, color }) => {
    const from = 0.04 + (day / DAYS.length) * 0.5;
    const opacity = useTransform(p, [from, from + 0.03], [0.1, 1]);
    const scale = useTransform(p, [from, from + 0.03], [0.6, 1]);

    return <motion.span style={{ opacity, scale, background: color }} className="h-[30px] rounded-lg" />;
};

const EmpoweredScene = ({ p }) => {
    const points = useTransform(p, [0.08, 0.8], [0, 240]);
    const label = useTransform(points, (value) => `${Math.round(value)} pts`);

    return (
        <Scene background="linear-gradient(180deg,#34122a,#160a14)">
            <div className="flex h-full flex-col px-4">
                <div className="flex items-center gap-3">
                    <Ring p={p} from={0.1} to={0.8} size={76} width={7} color={PINK}>
                        <span className="flex h-14 w-14 items-center justify-center rounded-full bg-white/10 text-2xl">
                            <svg width="34" height="34" viewBox="0 0 34 34" fill="none">
                                <circle cx="11" cy="14" r="2.5" fill="#fff" />
                                <circle cx="23" cy="14" r="2.5" fill="#fff" />
                                <path d="M9 22c3 4 13 4 16 0" stroke="#fff" strokeWidth="2.5" strokeLinecap="round" />
                            </svg>
                        </span>
                    </Ring>
                    <div>
                        <p className="text-[18px] font-bold">My avatar</p>
                        <motion.p className="text-[14px] font-medium" style={{ color: PINK }}>{label}</motion.p>
                        <Reveal p={p} from={0.56} to={0.64} y={6} className="mt-0.5 flex items-center gap-1 text-[12px] text-white/75">
                            <Sparkles size={12} /> Avatar evolved
                        </Reveal>
                    </div>
                </div>

                <p className="mb-2 mt-5 text-[15px] font-semibold">Mood this month</p>
                <div className="grid grid-cols-7 gap-1.5">
                    {DAYS.map((color, day) => (
                        <Day key={day} p={p} day={day} color={color} />
                    ))}
                </div>

                <Reveal p={p} from={0.6} to={0.7} className="mt-4 rounded-2xl bg-white/8 p-3 text-[13px]">
                    <p className="font-semibold">Quiz complete</p>
                    <p className="text-white/70">Wellness reward earned</p>
                </Reveal>

                <Reveal p={p} from={0.76} to={0.88} className="mt-auto mb-2">
                    <div className="flex items-center justify-center gap-2 rounded-2xl py-3 text-[14px] font-semibold text-black" style={{ background: PINK }}>
                        <LifeBuoy size={17} /> Need help? Talk to someone
                    </div>
                </Reveal>
            </div>
        </Scene>
    );
};

export default EmpoweredScene;
