import { motion, useTransform } from 'framer-motion';
import { Car, MapPin, Star } from 'lucide-react';
import { Scene, Reveal } from './shared';

const ROUTE = 'M 58 400 C 58 340, 110 330, 110 280 S 60 200, 130 170 S 250 180, 240 110 S 220 60, 226 40';
const STREETS = [
    'M -10 120 C 80 150, 200 90, 310 130',
    'M -10 300 C 90 260, 200 340, 310 280',
    'M 60 -10 C 40 120, 110 280, 70 520',
    'M 230 -10 C 260 120, 170 300, 240 520',
    'M -10 430 C 90 400, 200 460, 310 410',
];

const AlyteScene = ({ p }) => {
    const pathLength = useTransform(p, [0.05, 0.9], [0, 1]);
    const offsetDistance = useTransform(p, [0.05, 0.9], ['0%', '100%']);
    const eta = useTransform(p, (value) => (value >= 0.9 ? 'Arrived' : `${Math.max(1, Math.ceil(12 * (1 - value / 0.9)))} min`));

    return (
        <Scene background="#10161a">
            <div className="map-grid absolute inset-0">
                <svg viewBox="0 0 300 560" className="absolute inset-0 h-full w-full" preserveAspectRatio="xMidYMin slice">
                    {STREETS.map((street) => (
                        <path key={street} d={street} fill="none" stroke="rgba(255,255,255,0.13)" strokeWidth="9" />
                    ))}
                    <path d={ROUTE} fill="none" stroke="rgba(48,209,88,0.2)" strokeWidth="6" strokeLinecap="round" />
                    <motion.path d={ROUTE} fill="none" stroke="#30D158" strokeWidth="6" strokeLinecap="round" style={{ pathLength }} />
                </svg>
                <motion.div
                    className="absolute left-0 top-0 flex h-8 w-8 items-center justify-center rounded-full bg-white shadow-lg"
                    style={{ offsetPath: `path('${ROUTE}')`, offsetDistance, offsetRotate: '0deg' }}
                >
                    <Car size={18} className="text-black" />
                </motion.div>
                <MapPin size={28} className="absolute text-[#30D158]" style={{ left: 212, top: 12 }} />
            </div>

            <div className="absolute left-3 top-1 rounded-full bg-black/85 px-3 py-1.5 text-[13px] font-semibold">
                <span className="text-white/70">ETA </span>
                <motion.span className="text-[#30D158]">{eta}</motion.span>
            </div>

            <Reveal p={p} from={0.02} to={0.14} y={50} className="absolute inset-x-2 bottom-1 rounded-[22px] bg-[#1b2126] p-3.5">
                <div className="flex items-center gap-3">
                    <span className="flex h-11 w-11 items-center justify-center rounded-full bg-white/10"><Car size={20} /></span>
                    <div className="min-w-0 flex-1">
                        <p className="text-[14px] font-semibold">Your driver</p>
                        <p className="flex items-center gap-1 text-[12px] text-white/70">
                            <Star size={11} className="fill-current" /> Sample trip
                        </p>
                    </div>
                    <span className="rounded-full bg-[#30D158] px-3 py-1.5 text-[12px] font-semibold text-black">Live</span>
                </div>
                <Reveal p={p} from={0.86} to={0.94} y={6}>
                    <p className="mt-2.5 rounded-xl bg-white/10 py-2 text-center text-[13px] font-medium">Payment complete</p>
                </Reveal>
            </Reveal>
        </Scene>
    );
};

export default AlyteScene;
