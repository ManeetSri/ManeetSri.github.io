import { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { BookOpen, Check, ChevronDown } from 'lucide-react';
import { useCourse } from '../course/context.js';
import { readLastPath, useCourseSummaries } from './courseSummaries.js';
import { ProgressRing } from './primitives.jsx';

const CourseRows = ({ onNavigate }) => {
    const current = useCourse();
    const summaries = useCourseSummaries();
    return (
        <ul className="space-y-1">
            {summaries.map(({ course, progress, due }) => {
                const active = course.id === current.id;
                return (
                    <li key={course.id}>
                        <Link
                            to={active ? course.links.today : readLastPath(course)}
                            onClick={onNavigate}
                            aria-current={active ? 'page' : undefined}
                            className={`flex items-center gap-3 rounded-xl px-3 py-2.5 ${active ? 'bg-white/10' : 'hover:bg-white/[0.06]'}`}
                        >
                            <ProgressRing value={progress.ratio} size={28} stroke={3} label={`${progress.done} of ${progress.total} lessons on your path`} />
                            <span className="min-w-0 flex-1">
                                <span className="block truncate font-medium">{course.title}</span>
                                <span className="block font-mono text-[11px] text-muted">{Math.round(progress.ratio * 100)}% of your path{due ? ` · ${due} due` : ''}</span>
                            </span>
                            {active && <Check size={16} aria-hidden="true" className="shrink-0 text-amber" />}
                        </Link>
                    </li>
                );
            })}
        </ul>
    );
};

// The top bar's brand, which opens a menu of courses
export const CourseSwitcher = () => {
    const { brand, title } = useCourse();
    const [open, setOpen] = useState(false);
    const container = useRef(null);

    useEffect(() => {
        if (!open) return undefined;
        const close = (event) => {
            if (event.type === 'keydown' ? event.key === 'Escape' : !container.current?.contains(event.target)) setOpen(false);
        };
        window.addEventListener('pointerdown', close);
        window.addEventListener('keydown', close);
        return () => {
            window.removeEventListener('pointerdown', close);
            window.removeEventListener('keydown', close);
        };
    }, [open]);

    return (
        <div ref={container} className="relative mr-2 hidden sm:block">
            <button
                type="button"
                onClick={() => setOpen((value) => !value)}
                aria-expanded={open}
                aria-haspopup="true"
                aria-label={`${title}: switch course`}
                className="flex h-10 items-center gap-2 rounded-full px-2 font-display text-lg font-semibold tracking-tight hover:bg-white/[0.06]"
            >
                <BookOpen size={18} aria-hidden="true" className="text-swift" /> {brand.lead} {brand.joiner && <span className="text-muted">{brand.joiner}</span>} <span className="swift-gradient-text">{brand.accent}</span>
                <ChevronDown size={16} aria-hidden="true" className={`text-muted transition-transform ${open ? 'rotate-180' : ''}`} />
            </button>
            {open && (
                <div className="absolute left-0 top-12 z-50 w-80 rounded-2xl border border-line bg-raised p-2 shadow-2xl">
                    <p className="px-3 pb-1.5 pt-1 font-mono text-[11px] uppercase tracking-wider text-muted">Courses</p>
                    <CourseRows onNavigate={() => setOpen(false)} />
                </div>
            )}
        </div>
    );
};

// The same choice inside the mobile modules sheet
export const CourseList = ({ onNavigate }) => (
    <div>
        <p className="px-3 pb-1.5 font-mono text-[11px] uppercase tracking-wider text-muted">Courses</p>
        <CourseRows onNavigate={onNavigate} />
    </div>
);
