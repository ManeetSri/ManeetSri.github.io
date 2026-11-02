import { motion, useTransform } from 'framer-motion';
import { Check, Search, ShoppingCart } from 'lucide-react';
import { Scene, Reveal } from './shared';

const BLUE = '#409CFF';
const TILES = ['#1f3f66', '#2d2f52', '#23474a', '#47324f'];
const STEPS = ['Order placed', 'Packed', 'Out for delivery', 'Delivered'];

const Step = ({ p, label, index }) => {
    const from = 0.62 + index * 0.09;
    const fill = useTransform(p, [from, from + 0.05], [0, 1]);

    return (
        <div className="flex items-center gap-3 py-1.5">
            <span className="relative flex h-6 w-6 items-center justify-center rounded-full bg-white/10">
                <motion.span style={{ opacity: fill, scale: fill, background: BLUE }} className="absolute inset-0 flex items-center justify-center rounded-full">
                    <Check size={14} className="text-black" />
                </motion.span>
            </span>
            <span className="text-[14px]">{label}</span>
        </div>
    );
};

const BestScene = ({ p }) => {
    const flyX = useTransform(p, [0.1, 0.3], [0, 196]);
    const flyY = useTransform(p, [0.1, 0.3], [0, -116]);
    const flyScale = useTransform(p, [0.1, 0.3], [1, 0.12]);
    const flyOpacity = useTransform(p, [0.1, 0.12, 0.29, 0.3], [0, 1, 1, 0]);
    const badge = useTransform(p, [0.29, 0.33], [0, 1]);
    const sheetY = useTransform(p, [0.36, 0.48], ['100%', '0%']);

    return (
        <Scene background="#0d1420">
            <div className="flex items-center justify-between px-4 pb-3">
                <p className="text-[22px] font-bold">Shop</p>
                <span className="relative">
                    <ShoppingCart size={23} />
                    <motion.span style={{ scale: badge, background: BLUE }} className="absolute -right-2 -top-2 flex h-4 w-4 items-center justify-center rounded-full text-[10px] font-bold text-black">1</motion.span>
                </span>
            </div>
            <div className="mx-4 mb-3 flex items-center gap-2 rounded-xl bg-white/10 px-3 py-2 text-[14px] text-white/65">
                <Search size={15} /> Search products
            </div>
            <div className="relative grid grid-cols-2 gap-2.5 px-4">
                {TILES.map((color, index) => (
                    <div key={color} className="rounded-2xl p-2.5" style={{ background: color }}>
                        <div className="h-[82px] rounded-xl bg-white/10" />
                        <p className="mt-2 text-[13px] font-medium">Sample item {index + 1}</p>
                        <p className="text-[12px] text-white/70">Add to cart</p>
                    </div>
                ))}
                <motion.div
                    style={{ x: flyX, y: flyY, scale: flyScale, opacity: flyOpacity, background: BLUE }}
                    className="absolute left-[26px] top-[10px] h-[82px] w-[106px] rounded-xl"
                />
            </div>

            <motion.div style={{ y: sheetY }} className="absolute inset-x-0 bottom-0 rounded-t-[26px] bg-[#1a2230] p-5">
                <p className="text-[18px] font-bold">Checkout</p>
                <Reveal p={p} from={0.46} to={0.54} y={8}>
                    <p className="mt-2 flex items-center gap-2 rounded-xl bg-white/10 p-3 text-[13px]">
                        <Check size={15} style={{ color: BLUE }} /> Secure payment confirmed
                    </p>
                </Reveal>
                <Reveal p={p} from={0.56} to={0.62} y={8} className="mt-3">
                    <p className="pb-1 text-[15px] font-semibold">Track order</p>
                    {STEPS.map((label, index) => (
                        <Step key={label} p={p} label={label} index={index} />
                    ))}
                </Reveal>
            </motion.div>
        </Scene>
    );
};

export default BestScene;
