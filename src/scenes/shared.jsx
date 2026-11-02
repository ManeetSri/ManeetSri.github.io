import { motion, useTransform } from 'framer-motion';

export const Scene = ({ background, children, interactive = false }) => (
    <div aria-hidden={interactive ? undefined : 'true'} className="absolute inset-0 flex flex-col overflow-hidden" style={{ background }}>
        <div className="flex h-12 shrink-0 items-center justify-between px-7 text-[13px] font-semibold">
            <span>9:41</span>
            <span className="text-white/70">5G</span>
        </div>
        <div className="relative min-h-0 flex-1">{children}</div>
        <p className="shrink-0 pb-1.5 pt-1 text-center text-[10px] text-white/55">Illustrative recreation</p>
    </div>
);

// Fades and lifts its content in over part of a scene's scroll progress
export const Reveal = ({ p, from, to, y = 14, className = '', children }) => {
    const opacity = useTransform(p, [from, to], [0, 1]);
    const translateY = useTransform(p, [from, to], [y, 0]);

    return (
        <motion.div style={{ opacity, y: translateY }} className={className}>
            {children}
        </motion.div>
    );
};

export const Ring = ({ p, from, to, size, width = 12, color, children }) => {
    const pathLength = useTransform(p, [from, to], [0, 1]);
    const radius = (size - width) / 2;

    return (
        <div className="relative" style={{ width: size, height: size }}>
            <svg width={size} height={size} className="-rotate-90">
                <circle cx={size / 2} cy={size / 2} r={radius} fill="none" stroke="rgba(255,255,255,0.1)" strokeWidth={width} />
                <motion.circle
                    cx={size / 2}
                    cy={size / 2}
                    r={radius}
                    fill="none"
                    stroke={color}
                    strokeWidth={width}
                    strokeLinecap="round"
                    style={{ pathLength }}
                />
            </svg>
            {children && <div className="absolute inset-0 flex items-center justify-center">{children}</div>}
        </div>
    );
};
