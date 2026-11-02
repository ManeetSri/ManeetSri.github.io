import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { GitBranch, Truck } from 'lucide-react';
import AppIcon from './AppIcon';
import { projects } from '../../data/projects';

const NOTIFICATIONS = [
    { id: 'rating', project: projects.find((project) => project.id === 'alyte'), app: 'Alyte', title: '4.7 ★ from 854 ratings', body: 'App Store India, Nov 2026' },
    { id: 'role', icon: Truck, color: '#F05138', app: 'Now', title: 'At Mahindra Logistics', body: 'Building enterprise mobility apps' },
    { id: 'oss', icon: GitBranch, color: '#FDB03A', app: 'Open source', title: 'CountryPicker_SwiftUI', body: 'A SwiftUI Swift Package' },
];

const LockScreen = ({ ready = true }) => {
    const [now, setNow] = useState(() => new Date());

    useEffect(() => {
        const timer = setInterval(() => setNow(new Date()), 15000);
        return () => clearInterval(timer);
    }, []);

    return (
        <div aria-hidden="true" className="absolute inset-0 flex flex-col items-center bg-[radial-gradient(120%_70%_at_50%_0%,#7a2a18_0%,#2a1410_45%,#0a0b0f_100%)] px-3 pt-16">
            <p className="text-[15px] font-medium text-white/85">
                {now.toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric' })}
            </p>
            <p className="font-display text-[76px] font-semibold leading-none">
                {now.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit', hour12: false })}
            </p>

            <div className="mt-auto mb-12 w-full space-y-2">
                {NOTIFICATIONS.map(({ id, project, icon: Icon, color, app, title, body }, index) => (
                    <motion.div
                        key={id}
                        initial={{ opacity: 0, y: 24, scale: 0.96 }}
                        animate={ready ? { opacity: 1, y: 0, scale: 1 } : {}}
                        transition={{ type: 'spring', stiffness: 220, damping: 22, delay: 0.25 + index * 0.18 }}
                        className="flex items-center gap-2.5 rounded-[20px] bg-white/12 p-2.5"
                    >
                        {project ? (
                            <span className="shrink-0"><AppIcon project={project} size={36} /></span>
                        ) : (
                            <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-[9px]" style={{ background: color }}>
                                <Icon size={18} className="text-black" />
                            </span>
                        )}
                        <span className="min-w-0">
                            <span className="block text-[11px] text-white/65">{app}</span>
                            <span className="block truncate text-[13px] font-semibold">{title}</span>
                            <span className="block truncate text-[12px] text-white/75">{body}</span>
                        </span>
                    </motion.div>
                ))}
            </div>
            <div className="absolute bottom-2 h-[5px] w-28 rounded-full bg-white/80" />

            {/* The screen stays dark until the loader lands on the Dynamic Island */}
            <motion.div
                initial={false}
                animate={{ opacity: ready ? 0 : 1 }}
                transition={{ duration: 0.7, ease: 'easeOut' }}
                className="pointer-events-none absolute inset-0 bg-black"
            />
        </div>
    );
};

export default LockScreen;
