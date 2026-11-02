import { Compass, Sprout } from 'lucide-react';
import { Scene, Reveal, Ring } from './shared';

const RINGS = [
    { size: 190, color: '#63E6BE', to: 0.5, name: 'Move' },
    { size: 148, color: '#FFD166', to: 0.62, name: 'Nourish' },
    { size: 106, color: '#74C0FC', to: 0.42, name: 'Rest' },
];

const BodyIncScene = ({ p }) => (
    <Scene background="#0a1a16">
        <div className="flex h-full flex-col px-4">
            <p className="text-[22px] font-bold">Today</p>
            <div className="relative mx-auto my-4 flex h-[190px] w-[190px] items-center justify-center">
                {RINGS.map(({ size, color, to }, index) => (
                    <div key={color} className="absolute">
                        <Ring p={p} from={0.05 + index * 0.05} to={to + 0.1} size={size} width={15} color={color} />
                    </div>
                ))}
            </div>
            <div className="mb-3 flex justify-center gap-4 text-[12px] text-white/80">
                {RINGS.map(({ color, name }) => (
                    <span key={name} className="flex items-center gap-1.5">
                        <span className="h-2 w-2 rounded-full" style={{ background: color }} /> {name}
                    </span>
                ))}
            </div>
            <div className="space-y-2">
                <Reveal p={p} from={0.56} to={0.68} className="flex items-center gap-3 rounded-2xl bg-white/8 p-3">
                    <Sprout size={20} className="shrink-0 text-[#63E6BE]" />
                    <span>
                        <span className="block text-[14px] font-semibold">Your reset plan</span>
                        <span className="block text-[12px] text-white/70">Sample personalized guidance</span>
                    </span>
                </Reveal>
                <Reveal p={p} from={0.72} to={0.84} className="flex items-center gap-3 rounded-2xl bg-white/8 p-3">
                    <Compass size={20} className="shrink-0 text-[#63E6BE]" />
                    <span>
                        <span className="block text-[14px] font-semibold">Resources for you</span>
                        <span className="block text-[12px] text-white/70">Sample wellness articles</span>
                    </span>
                </Reveal>
            </div>
        </div>
    </Scene>
);

export default BodyIncScene;
