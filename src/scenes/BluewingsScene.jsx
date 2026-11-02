import { motion, useTransform } from 'framer-motion';
import { BookOpen, CreditCard, MessageSquare } from 'lucide-react';
import { Scene, Reveal } from './shared';

const SKY = '#64D2FF';
const WEEKDAYS = ['M', 'T', 'W', 'T', 'F'];
const ABSENT_DAY = 8;
const DAYS = Array.from({ length: 20 }, (_, day) => day);

const Day = ({ p, day }) => {
    const from = 0.04 + (day / DAYS.length) * 0.4;
    const opacity = useTransform(p, [from, from + 0.03], [0.12, 1]);

    return (
        <motion.span
            style={{ opacity, background: day === ABSENT_DAY ? '#FF9F0A' : SKY }}
            className="h-[30px] rounded-lg"
        />
    );
};

const CARDS = [
    { icon: BookOpen, title: 'Homework posted', body: 'Sample class update', from: 0.46, to: 0.56 },
    { icon: MessageSquare, title: 'Message from teacher', body: 'Sample note', from: 0.6, to: 0.7 },
    { icon: CreditCard, title: 'Fee paid', body: 'Receipt ready', from: 0.74, to: 0.84 },
];

const BluewingsScene = ({ p }) => (
    <Scene background="#0a1820">
        <div className="px-4">
            <p className="text-[22px] font-bold">Attendance</p>
            <p className="mb-3 text-[13px] text-white/70">Sample student</p>
            <div className="grid grid-cols-5 gap-1.5 text-center text-[12px] text-white/60">
                {WEEKDAYS.map((day, index) => <span key={index}>{day}</span>)}
                {DAYS.map((day) => <Day key={day} p={p} day={day} />)}
            </div>
            <div className="mt-4 space-y-2">
                {CARDS.map(({ icon: Icon, title, body, from, to }) => (
                    <Reveal key={title} p={p} from={from} to={to} className="flex items-center gap-3 rounded-2xl bg-white/8 p-3">
                        <span className="flex h-9 w-9 items-center justify-center rounded-xl text-black" style={{ background: SKY }}>
                            <Icon size={18} />
                        </span>
                        <span>
                            <span className="block text-[14px] font-semibold">{title}</span>
                            <span className="block text-[12px] text-white/70">{body}</span>
                        </span>
                    </Reveal>
                ))}
            </div>
        </div>
    </Scene>
);

export default BluewingsScene;
