import { useState } from 'react';
import { motion } from 'framer-motion';
import { career } from '../data/career';
import { skillTracks, toolbox } from '../data/skills';

const toMonths = ([year, month]) => year * 12 + month;

const now = new Date();
const NOW = [now.getFullYear(), now.getMonth() + 1];
const TIMELINE_START = toMonths(career[0].start);
const TIMELINE_LENGTH = toMonths(NOW) - TIMELINE_START;

const place = (role) => {
    const left = (toMonths(role.start) - TIMELINE_START) / TIMELINE_LENGTH;
    const width = (toMonths(role.end ?? NOW) - toMonths(role.start)) / TIMELINE_LENGTH;
    return { left: `${left * 100}%`, width: `${Math.max(width * 100, 1.5)}%` };
};

const rolesById = Object.fromEntries(career.map((role) => [role.id, role]));
const years = Array.from({ length: NOW[0] - 2022 }, (_, index) => 2023 + index);

const Track = ({ track, index, onInspect }) => (
    <li className="grid grid-cols-[92px_minmax(0,1fr)] items-center gap-2 border-t border-line py-1.5 sm:grid-cols-[150px_minmax(0,1fr)] lg:grid-cols-[190px_minmax(0,1fr)] lg:gap-4 lg:py-2.5">
        <span className="text-[13px] font-medium leading-tight sm:text-sm">{track.name}</span>
        <span className="relative block h-9 rounded bg-white/[0.04] lg:h-7">
            {track.roles.map((id) => {
                const role = rolesById[id];
                const description = `${track.name}: ${role.shortName}, ${role.period}`;
                return (
                    <motion.button
                        key={id}
                        type="button"
                        aria-label={description}
                        onMouseEnter={() => onInspect(description)}
                        onFocus={() => onInspect(description)}
                        onClick={() => onInspect(description)}
                        initial={{ scaleX: 0 }}
                        whileInView={{ scaleX: 1 }}
                        viewport={{ once: true, margin: '-8% 0px' }}
                        transition={{ duration: 0.8, delay: index * 0.05, ease: [0.16, 1, 0.3, 1] }}
                        style={place(role)}
                        className="trace absolute inset-y-0 origin-left rounded"
                    />
                );
            })}
        </span>
    </li>
);

const Instruments = () => {
    const [inspected, setInspected] = useState('');

    return (
        <section id="skills" className="relative bg-ink px-5 py-16 sm:px-10 lg:px-[5vw] lg:py-24">
            <p className="mb-3 font-mono text-sm text-swift">Instruments</p>
            <h2 className="font-display text-[clamp(2.4rem,5vw,4.5rem)] font-semibold leading-none tracking-tight">No percentages. Just a trace of where each skill ran.</h2>
            <p className="mt-5 max-w-2xl text-lg leading-relaxed text-muted">Each track is plotted against my real career timeline, from what each role's description names.</p>

            <div className="mt-8 rounded-2xl border border-line bg-surface p-4 sm:p-6 lg:mt-12">
                <p aria-live="polite" className="mb-4 min-h-5 font-mono text-sm text-amber">{inspected || 'Hover or tap a trace'}</p>

                <p aria-hidden="true" className="mb-3 flex flex-wrap gap-x-3 font-mono text-xs leading-relaxed text-muted sm:hidden">
                    {career.map((role) => (
                        <span key={role.id} className="whitespace-nowrap"><span className="text-amber">{role.shortName[0]}</span> {role.shortName}</span>
                    ))}
                </p>

                <div className="grid grid-cols-[92px_minmax(0,1fr)] gap-2 sm:grid-cols-[150px_minmax(0,1fr)] lg:grid-cols-[190px_minmax(0,1fr)] lg:gap-4">
                    <span />
                    <div className="relative h-7">
                        {career.map((role) => (
                            <span key={role.id} style={place(role)} className="absolute inset-y-0 truncate border-l border-paper/30 pl-1 font-mono text-xs text-muted">
                                <span className="hidden sm:inline">{role.shortName}</span>
                                <span className="sm:hidden" aria-hidden="true">{role.shortName[0]}</span>
                            </span>
                        ))}
                    </div>
                </div>

                <ul>
                    {skillTracks.map((track, index) => (
                        <Track key={track.name} track={track} index={index} onInspect={setInspected} />
                    ))}
                </ul>

                <div className="grid grid-cols-[92px_minmax(0,1fr)] gap-2 border-t border-line pt-2 sm:grid-cols-[150px_minmax(0,1fr)] lg:grid-cols-[190px_minmax(0,1fr)] lg:gap-4">
                    <span />
                    <div aria-hidden="true" className="relative h-5 font-mono text-xs text-muted">
                        {years.map((year) => (
                            <span key={year} className="absolute" style={{ left: `${((year * 12 + 1 - TIMELINE_START) / TIMELINE_LENGTH) * 100}%` }}>{year}</span>
                        ))}
                    </div>
                </div>
            </div>

            <h3 className="mb-3 mt-10 font-mono text-sm text-muted">Also in the toolbox</h3>
            <ul className="flex flex-wrap gap-2">
                {toolbox.map((tool) => (
                    <li key={tool} className="rounded-full border border-line bg-white/5 px-3.5 py-1.5 text-sm">{tool}</li>
                ))}
            </ul>
        </section>
    );
};

export default Instruments;
