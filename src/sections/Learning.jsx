import { ArrowUpRight, Binary, Waypoints } from 'lucide-react';
import { Link } from 'react-router-dom';

const courses = [
    { to: '/dsa', title: 'DSA in Swift', detail: 'Data structures, algorithms and coding interview practice.', Icon: Binary },
    { to: '/design', title: 'System Design', detail: 'iOS architecture, design trade-offs and Swift katas.', Icon: Waypoints },
];

const Learning = () => (
    <section id="learning" aria-labelledby="learning-title" className="relative bg-ink px-5 py-16 sm:px-10 lg:px-[5vw] lg:py-24">
        <div className="mb-8 sm:flex sm:items-end sm:justify-between sm:gap-4">
            <h2 id="learning-title" className="font-display text-[clamp(2.4rem,5vw,4.5rem)] font-semibold leading-none tracking-tight">Learning</h2>
            <p className="mt-3 text-sm text-muted">Private courses · Passphrase required</p>
        </div>
        <ul className="grid gap-3 sm:grid-cols-2">
            {courses.map(({ to, title, detail, Icon }) => (
                <li key={to}>
                    <Link to={to} className="group flex h-full items-start gap-4 rounded-2xl border border-line bg-surface p-5 transition-colors hover:border-amber/60 hover:bg-raised sm:p-6">
                        <span className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-amber/10 text-amber">
                            <Icon size={21} aria-hidden="true" />
                        </span>
                        <span className="min-w-0 flex-1">
                            <span className="block font-display text-xl font-semibold tracking-tight">{title}</span>
                            <span className="mt-1 block text-sm leading-relaxed text-muted">{detail}</span>
                        </span>
                        <ArrowUpRight size={18} aria-hidden="true" className="shrink-0 text-muted group-hover:text-amber" />
                    </Link>
                </li>
            ))}
        </ul>
    </section>
);

export default Learning;
