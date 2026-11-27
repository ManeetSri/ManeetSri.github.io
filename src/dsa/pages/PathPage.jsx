import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Award, CheckCircle2, ChevronDown, Circle, CircleDot, Clock3, SkipForward } from 'lucide-react';
import { GOALS, LEVELS, modulesInPart, parts, TRACKS } from '../data/curriculum.js';
import { completion, isOnPath, lessonState, moduleCompletion, nextOnPath } from '../engine/path.js';
import { useProfile, useStore } from '../store/store.js';
import { formatMinutes } from '../ui/format.js';
import { useConsoleMeta, usePath } from '../ui/hooks.js';
import { Chip, PageHeader, ProgressBar, ProgressRing } from '../ui/primitives.jsx';

const STATE_ICONS = {
    done: { icon: CheckCircle2, className: 'text-[#30D158]', label: 'Done' },
    skipped: { icon: SkipForward, className: 'text-[#30D158]/60', label: 'Tested out' },
    started: { icon: CircleDot, className: 'text-amber', label: 'Started' },
    todo: { icon: Circle, className: 'text-white/30', label: 'Not started' },
    stub: { icon: Clock3, className: 'text-white/20', label: 'Coming soon' },
};

const ModuleRow = ({ module, progress, goal, showAll, open, onToggle, nextId, mastered }) => {
    const { done, total, ratio } = moduleCompletion(module, progress, goal);
    const visible = showAll ? module.lessons : module.lessons.filter((lesson) => isOnPath(lesson, goal));
    const minutes = visible.reduce((sum, lesson) => sum + lesson.minutes, 0);
    if (visible.length === 0) return null;

    return (
        <li className="rounded-2xl border border-line bg-surface">
            <button type="button" onClick={onToggle} aria-expanded={open} className="flex w-full items-center gap-3 px-4 py-3.5 text-left">
                <ProgressRing value={ratio} size={36} stroke={3.5} label={`${done} of ${total} lessons done`}>
                    <span className="font-mono text-[10px]">{module.code.slice(1)}</span>
                </ProgressRing>
                <span className="min-w-0 flex-1">
                    <span className="flex items-center gap-2 font-semibold">{module.title}{mastered && <Chip tone="amber"><Award size={12} aria-hidden="true" /> Mastered</Chip>}</span>
                    <span className="block truncate text-sm text-muted">{module.summary}</span>
                </span>
                <span className="hidden shrink-0 text-right font-mono text-xs text-muted sm:block">
                    {visible.length} lessons<br />{formatMinutes(minutes)}
                </span>
                <ChevronDown size={18} aria-hidden="true" className={`shrink-0 text-muted transition-transform ${open ? 'rotate-180' : ''}`} />
            </button>
            {open && (
                <ol className="border-t border-line px-2 py-2">
                    {visible.map((lesson, index) => {
                        const state = lessonState(lesson, progress);
                        const { icon: Icon, className, label } = STATE_ICONS[state];
                        const offPath = !isOnPath(lesson, goal);
                        return (
                            <li key={lesson.id}>
                                <Link to={`/dsa/learn/${lesson.id}`} className={`flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white/[0.04] ${lesson.id === nextId ? 'bg-amber/[0.07]' : ''}`}>
                                    <Icon size={18} aria-hidden="true" className={`shrink-0 ${className}`} />
                                    <span className="sr-only">{label}:</span>
                                    <span className="w-6 shrink-0 font-mono text-xs text-muted">{index + 1}</span>
                                    <span className={`min-w-0 flex-1 ${state === 'stub' ? 'text-muted' : ''}`}>{lesson.title}</span>
                                    {lesson.id === nextId && <Chip tone="amber">next</Chip>}
                                    {offPath && <Chip>{lesson.tracks.map((track) => TRACKS[track]).join(' · ')}</Chip>}
                                    <span className="hidden shrink-0 font-mono text-xs text-muted sm:inline">{LEVELS[lesson.level]} · {lesson.minutes}m</span>
                                </Link>
                            </li>
                        );
                    })}
                    {module.lessons.some((lesson) => lesson.status === 'ready') && (
                        <li>
                            <Link to={`/dsa/checkpoint/${module.id}`} className="mt-1 flex items-center gap-3 rounded-xl px-3 py-2.5 text-amber hover:bg-white/[0.04]">
                                <Award size={18} aria-hidden="true" className="shrink-0" />
                                <span className="flex-1">{mastered ? 'Retake the checkpoint' : 'Module checkpoint'}</span>
                                <span className="font-mono text-xs text-muted">12 questions</span>
                            </Link>
                        </li>
                    )}
                </ol>
            )}
        </li>
    );
};

const PathPage = () => {
    useConsoleMeta('Path', '/dsa/path');
    const { lessons: progress, checkpoints } = useStore();
    const { goal } = useProfile();
    const path = usePath();
    const next = nextOnPath(path, progress);
    const [showAll, setShowAll] = useState(false);
    const [openModules, setOpenModules] = useState(() => new Set(next ? [next.module] : []));
    const overall = completion(path, progress);

    const toggle = (id) => setOpenModules((current) => {
        const updated = new Set(current);
        if (updated.has(id)) updated.delete(id);
        else updated.add(id);
        return updated;
    });

    return (
        <div className="mx-auto max-w-4xl">
            <PageHeader eyebrow={`Goal: ${GOALS[goal].label}`} title="Your learning path">
                {overall.done} of {overall.total} lessons done. Lessons marked with a track are side quests outside your goal.
            </PageHeader>

            <div className="mb-8 flex flex-wrap items-center gap-3">
                <div role="group" aria-label="Show" className="flex rounded-full bg-white/8 p-1">
                    <button type="button" aria-pressed={!showAll} onClick={() => setShowAll(false)} className={`h-9 rounded-full px-4 text-sm ${!showAll ? 'bg-white/15 font-medium' : 'text-muted'}`}>My path</button>
                    <button type="button" aria-pressed={showAll} onClick={() => setShowAll(true)} className={`h-9 rounded-full px-4 text-sm ${showAll ? 'bg-white/15 font-medium' : 'text-muted'}`}>Everything</button>
                </div>
                <Link to="/dsa/settings" className="text-sm text-amber hover:underline">Change goal</Link>
            </div>

            <ol className="space-y-12">
                {parts.map((part) => {
                    const partLessons = path.filter((lesson) => lesson.part === part.number);
                    const partProgress = completion(partLessons, progress);
                    return (
                        <li key={part.number}>
                            <div className="mb-4 flex flex-wrap items-end justify-between gap-3">
                                <div>
                                    <p className="font-mono text-xs text-muted">Part {part.number} · phase {part.phase}</p>
                                    <h2 className="font-display text-2xl font-semibold tracking-tight">{part.title}</h2>
                                    <p className="mt-1 max-w-2xl text-sm text-muted">{part.summary}</p>
                                </div>
                                <div className="w-full sm:w-44">
                                    <ProgressBar value={partProgress.ratio} label={`Part ${part.number} completion`} />
                                    <p className="mt-1 text-right font-mono text-xs text-muted">{partProgress.done}/{partProgress.total}</p>
                                </div>
                            </div>
                            <ul className="space-y-2">
                                {modulesInPart(part.number).map((module) => (
                                    <ModuleRow
                                        key={module.id}
                                        module={module}
                                        progress={progress}
                                        goal={goal}
                                        showAll={showAll}
                                        open={openModules.has(module.id)}
                                        onToggle={() => toggle(module.id)}
                                        nextId={next?.id}
                                        mastered={Boolean(checkpoints[module.id]?.passedAt)}
                                    />
                                ))}
                            </ul>
                        </li>
                    );
                })}
            </ol>
        </div>
    );
};

export default PathPage;
