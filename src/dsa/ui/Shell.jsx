import { useEffect, useMemo, useRef, useState } from 'react';
import { Link, NavLink, useLocation, useNavigate } from 'react-router-dom';
import {
    BarChart3, BookOpen, ChevronDown, Code2, Flame, Layers, ListTree, Map as MapIcon, Mic, NotebookPen,
    ScrollText, Search, Settings, Sparkles, Sun, X,
} from 'lucide-react';
import { useCourse } from '../course/context.js';
import { moduleCompletion } from '../engine/path.js';
import { useProfile, useStore } from '../store/store.js';
import { useStats, useStudyTimer } from './hooks.js';
import { Kbd, ProgressRing } from './primitives.jsx';

// The console's pages for a course, built once per course
const navs = new WeakMap();
const navFor = (course) => {
    if (navs.has(course)) return navs.get(course);
    const { links } = course;
    const nav = [
        { to: links.today, label: 'Today', icon: Sun, end: true },
        { to: links.path, label: 'Path', icon: MapIcon },
        { to: links.practice, label: 'Practice', icon: Code2 },
        { to: links.review, label: 'Review', icon: Layers },
        { to: links.mock, label: 'Mock interview', icon: Mic },
        { to: links.progress, label: 'Progress', icon: BarChart3 },
        { to: links.notes, label: 'Notes', icon: NotebookPen },
        { to: links.sheets, label: 'Cheat sheets', icon: ScrollText },
        { to: links.settings, label: 'Settings', icon: Settings },
    ];
    const tabs = [nav[0], nav[1], nav[2], nav[3], { to: links.progress, label: 'Me', icon: BarChart3 }];
    navs.set(course, { nav, tabs });
    return navs.get(course);
};

const SYNC = {
    synced: { label: 'Synced', className: 'bg-[#30D158]' },
    pending: { label: 'Saving…', className: 'bg-amber animate-pulse' },
    offline: { label: 'Offline: saved on this device', className: 'bg-muted' },
    local: { label: 'Local dev data', className: 'bg-sky-400' },
};

const currentLessonId = (pathname, base) => (pathname.startsWith(`${base}/learn/`) ? pathname.slice(base.length + 7).split('/')[0] : null);

const ModuleTree = ({ onNavigate }) => {
    const { lessons, parts, modulesInPart, GOALS, links, base } = useCourse();
    const { pathname } = useLocation();
    const { lessons: progress } = useStore();
    const { goal } = useProfile();
    const activeLesson = lessons.find((lesson) => lesson.id === currentLessonId(pathname, base));
    const [openParts, setOpenParts] = useState(() => new Set([activeLesson?.part ?? 0]));
    const [openModule, setOpenModule] = useState(activeLesson?.module ?? null);
    const [followedLesson, setFollowedLesson] = useState(activeLesson?.id);

    // Opening a different lesson reveals it in the tree (adjusting state while rendering, as React suggests)
    if (activeLesson && activeLesson.id !== followedLesson) {
        setFollowedLesson(activeLesson.id);
        setOpenModule(activeLesson.module);
        setOpenParts((current) => new Set(current).add(activeLesson.part));
    }

    const togglePart = (number) => setOpenParts((current) => {
        const next = new Set(current);
        if (next.has(number)) next.delete(number);
        else next.add(number);
        return next;
    });

    return (
        <nav aria-label="Modules" className="space-y-1">
            {parts.map((part) => {
                const open = openParts.has(part.number);
                return (
                    <div key={part.number}>
                        <button
                            type="button"
                            onClick={() => togglePart(part.number)}
                            aria-expanded={open}
                            className="flex w-full items-center gap-2 rounded-lg px-2 py-2 text-left text-xs font-semibold uppercase tracking-wider text-muted hover:bg-white/5 hover:text-paper"
                        >
                            <ChevronDown size={14} aria-hidden="true" className={`shrink-0 transition-transform ${open ? '' : '-rotate-90'}`} />
                            <span className="font-mono">{part.number}</span>
                            <span className="truncate">{part.title}</span>
                        </button>
                        {open && (
                            <ul className="mb-2 space-y-0.5">
                                {modulesInPart(part.number).map((module) => {
                                    const { ratio, done, total } = moduleCompletion(module, progress, goal, GOALS);
                                    const expanded = openModule === module.id;
                                    return (
                                        <li key={module.id}>
                                            <button
                                                type="button"
                                                onClick={() => setOpenModule(expanded ? null : module.id)}
                                                aria-expanded={expanded}
                                                className="flex w-full items-center gap-2.5 rounded-lg px-2 py-1.5 text-left text-sm hover:bg-white/5"
                                            >
                                                <ProgressRing value={ratio} size={20} stroke={2.5} label={`${done} of ${total} lessons done`} />
                                                <span className="font-mono text-[11px] text-muted">{module.code}</span>
                                                <span className="min-w-0 flex-1 truncate">{module.title}</span>
                                            </button>
                                            {expanded && (
                                                <ul className="mb-1 ml-[19px] border-l border-line pl-3">
                                                    {module.lessons.map((lesson) => {
                                                        const isDone = Boolean(progress[lesson.id]?.completedAt);
                                                        return (
                                                            <li key={lesson.id}>
                                                                <NavLink
                                                                    to={links.lesson(lesson.id)}
                                                                    onClick={onNavigate}
                                                                    className={({ isActive }) => `flex items-center gap-2 rounded-md px-2 py-1 text-[13px] leading-snug ${isActive ? 'bg-white/10 text-paper' : 'text-muted hover:text-paper'} ${lesson.status === 'stub' ? 'opacity-60' : ''}`}
                                                                >
                                                                    <span aria-hidden="true" className={`h-1.5 w-1.5 shrink-0 rounded-full ${isDone ? 'bg-[#30D158]' : lesson.status === 'stub' ? 'bg-white/20' : 'bg-amber'}`} />
                                                                    <span className="min-w-0 flex-1">{lesson.title}</span>
                                                                    {isDone && <span className="sr-only">(done)</span>}
                                                                    {lesson.status === 'stub' && <span className="sr-only">(coming soon)</span>}
                                                                </NavLink>
                                                            </li>
                                                        );
                                                    })}
                                                </ul>
                                            )}
                                        </li>
                                    );
                                })}
                            </ul>
                        )}
                    </div>
                );
            })}
        </nav>
    );
};

const PrimaryNav = ({ onNavigate }) => (
    <nav aria-label="Console" className="space-y-0.5">
        {navFor(useCourse()).nav.map(({ to, label, icon: Icon, end }) => (
            <NavLink
                key={to}
                to={to}
                end={end}
                onClick={onNavigate}
                className={({ isActive }) => `flex h-10 items-center gap-3 rounded-xl px-3 text-sm font-medium ${isActive ? 'bg-white/10 text-paper' : 'text-muted hover:bg-white/5 hover:text-paper'}`}
            >
                <Icon size={18} aria-hidden="true" /> {label}
            </NavLink>
        ))}
    </nav>
);

// A full-screen sheet on phones and a centred panel on larger screens, built on <dialog> so focus,
// Escape and the backdrop come from the browser
const Sheet = ({ open, onClose, label, children, className = '' }) => {
    const ref = useRef(null);
    useEffect(() => {
        const dialog = ref.current;
        if (open && !dialog.open) dialog.showModal();
        if (!open && dialog.open) dialog.close();
    }, [open]);

    return (
        <dialog
            ref={ref}
            aria-label={label}
            onClose={onClose}
            onClick={(event) => event.target === ref.current && onClose()}
            className={`m-0 h-full max-h-none w-full max-w-none bg-transparent p-0 text-paper backdrop:bg-black/60 backdrop:backdrop-blur-sm sm:m-auto sm:h-auto ${className}`}
        >
            {open && children}
        </dialog>
    );
};

// Everything the palette can find in a course, built once per course
const indexes = new WeakMap();
const searchIndexFor = (course) => {
    if (indexes.has(course)) return indexes.get(course);
    const { modules, moduleById, lessons, practice, sheets, links } = course;
    const index = [
        ...navFor(course).nav.map((item) => ({ id: `page-${item.to}`, label: item.label, detail: 'Page', to: item.to })),
        ...modules.map((module) => ({ id: `module-${module.id}`, label: module.title, detail: `${module.code} · Module`, to: links.lesson(module.lessons[0].id), keywords: module.summary })),
        ...lessons.map((lesson) => ({ id: `lesson-${lesson.id}`, label: lesson.title, detail: `${moduleById[lesson.module].code} · Lesson${lesson.status === 'stub' ? ' · soon' : ''}`, to: links.lesson(lesson.id) })),
        ...practice.map((item) => ({ id: `practice-${item.id}`, label: item.title, detail: course.kindLabels?.[item.kind] ?? 'Problem', to: links.item(item.id) })),
        ...sheets.map((sheet) => ({ id: `sheet-${sheet.id}`, label: sheet.title, detail: 'Cheat sheet', to: links.sheet(sheet.id), keywords: sheet.keywords })),
    ];
    indexes.set(course, index);
    return index;
};

// Every word of the query has to appear, and titles that start with the query rank first
const search = (searchIndex, query) => {
    const words = query.toLowerCase().split(/\s+/).filter(Boolean);
    if (!words.length) return searchIndex.slice(0, 8);
    return searchIndex
        .map((item) => {
            const text = `${item.label} ${item.keywords ?? ''}`.toLowerCase();
            if (!words.every((word) => text.includes(word))) return null;
            const label = item.label.toLowerCase();
            const score = (label.startsWith(words[0]) ? 0 : 1) + (label.includes(words.join(' ')) ? 0 : 1);
            return { item, score };
        })
        .filter(Boolean)
        .sort((a, b) => a.score - b.score)
        .slice(0, 12)
        .map(({ item }) => item);
};

// Mounted only while the palette is open, so every opening starts with an empty search
const PaletteBody = ({ onClose }) => {
    const course = useCourse();
    const navigate = useNavigate();
    const [query, setQuery] = useState('');
    const [active, setActive] = useState(0);
    const results = useMemo(() => search(searchIndexFor(course), query), [course, query]);

    const go = (item) => {
        onClose();
        navigate(item.to);
    };

    const onKeyDown = (event) => {
        if (event.key === 'ArrowDown') {
            event.preventDefault();
            setActive((index) => Math.min(results.length - 1, index + 1));
        } else if (event.key === 'ArrowUp') {
            event.preventDefault();
            setActive((index) => Math.max(0, index - 1));
        } else if (event.key === 'Enter' && results[active]) {
            event.preventDefault();
            go(results[active]);
        }
    };

    return (
        <div className="flex h-full flex-col overflow-hidden bg-raised sm:h-auto sm:rounded-2xl sm:border sm:border-line">
            <div className="flex items-center gap-3 border-b border-line px-4">
                <Search size={18} aria-hidden="true" className="shrink-0 text-muted" />
                <input
                    autoFocus
                    value={query}
                    onChange={(event) => {
                        setQuery(event.target.value);
                        setActive(0);
                    }}
                    onKeyDown={onKeyDown}
                    role="combobox"
                    aria-expanded="true"
                    aria-controls="dsa-search-results"
                    aria-activedescendant={results[active] ? `dsa-result-${results[active].id}` : undefined}
                    aria-label="Search lessons, modules and problems"
                    placeholder="Search lessons, modules, problems…"
                    className="h-14 min-w-0 flex-1 bg-transparent text-base outline-none placeholder:text-muted"
                />
                <button type="button" onClick={onClose} aria-label="Close search" className="flex h-9 w-9 items-center justify-center rounded-full text-muted hover:bg-white/8 sm:hidden">
                    <X size={18} aria-hidden="true" />
                </button>
            </div>
            <ul id="dsa-search-results" role="listbox" aria-label="Results" className="max-h-[60vh] flex-1 overflow-y-auto p-2">
                {results.length === 0 && <li className="px-3 py-6 text-center text-sm text-muted">Nothing matches “{query}”.</li>}
                {results.map((item, index) => (
                    <li
                        key={item.id}
                        id={`dsa-result-${item.id}`}
                        role="option"
                        aria-selected={index === active}
                        onMouseEnter={() => setActive(index)}
                        onClick={() => go(item)}
                        className={`flex cursor-pointer items-center justify-between gap-3 rounded-xl px-3 py-2.5 ${index === active ? 'bg-white/10' : ''}`}
                    >
                        <span className="min-w-0 truncate">{item.label}</span>
                        <span className="shrink-0 font-mono text-xs text-muted">{item.detail}</span>
                    </li>
                ))}
            </ul>
        </div>
    );
};

const CommandPalette = ({ open, onClose }) => (
    <Sheet open={open} onClose={onClose} label="Search the console" className="sm:mt-[12vh] sm:max-w-xl">
        <PaletteBody onClose={onClose} />
    </Sheet>
);

const TopBar = ({ onSearch, onModules }) => {
    const { brand, links } = useCourse();
    const { sync } = useStore();
    const { xp, rank, streak } = useStats();
    const status = SYNC[sync] ?? SYNC.synced;

    return (
        <header className="sticky top-0 z-40 border-b border-line bg-ink/85 backdrop-blur-md">
            <div className="flex h-14 items-center gap-2 px-3 sm:px-5">
                {/* A full page load, so the portfolio starts fresh without the console in memory */}
                <a href="/" aria-label="Leave the console and go back to the portfolio" className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-white/8 hover:bg-white/12">
                    <X size={18} aria-hidden="true" />
                </a>
                <button type="button" onClick={onModules} aria-label="Browse modules" className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-white/8 hover:bg-white/12 lg:hidden">
                    <ListTree size={18} aria-hidden="true" />
                </button>
                <Link to={links.today} className="mr-2 hidden items-center gap-2 font-display text-lg font-semibold tracking-tight sm:flex">
                    <BookOpen size={18} aria-hidden="true" className="text-swift" /> {brand.lead} {brand.joiner && <span className="text-muted">{brand.joiner}</span>} <span className="swift-gradient-text">{brand.accent}</span>
                </Link>

                <button
                    type="button"
                    onClick={onSearch}
                    aria-label="Search lessons, modules and problems (⌘K)"
                    className="flex h-10 min-w-0 flex-1 items-center gap-2 rounded-full bg-white/6 px-3.5 text-left text-sm text-muted hover:bg-white/10 sm:max-w-md"
                >
                    <Search size={16} aria-hidden="true" className="shrink-0" />
                    <span className="truncate">Search</span>
                    <span className="ml-auto hidden sm:inline"><Kbd>⌘K</Kbd></span>
                </button>

                <div className="ml-auto flex shrink-0 items-center gap-1.5">
                    <span className="flex h-9 items-center gap-1 rounded-full bg-white/8 px-2.5 font-mono text-sm" title={`${streak}-day streak`}>
                        <Flame size={15} aria-hidden="true" className={streak > 0 ? 'text-swift' : 'text-muted'} />
                        <span className="sr-only">Streak:</span> {streak}
                    </span>
                    <Link to={links.progress} className="hidden h-9 items-center gap-1 rounded-full bg-white/8 px-2.5 font-mono text-sm text-amber hover:bg-white/12 sm:flex" title={rank.title}>
                        <Sparkles size={14} aria-hidden="true" />
                        <span className="sr-only">Experience points:</span> {xp.toLocaleString('en-GB')}
                    </Link>
                    <span className="flex h-9 w-9 items-center justify-center" title={status.label}>
                        <span aria-hidden="true" className={`h-2.5 w-2.5 rounded-full ${status.className}`} />
                        <span className="sr-only">{status.label}</span>
                    </span>
                </div>
            </div>
        </header>
    );
};

const MobileTabs = () => (
    <nav aria-label="Console" className="fixed inset-x-0 bottom-0 z-40 border-t border-line bg-ink/90 pb-[env(safe-area-inset-bottom)] backdrop-blur-md lg:hidden">
        <ul className="mx-auto grid max-w-lg grid-cols-5">
            {navFor(useCourse()).tabs.map(({ to, label, icon: Icon, end }) => (
                <li key={label}>
                    <NavLink
                        to={to}
                        end={end}
                        className={({ isActive }) => `flex h-14 flex-col items-center justify-center gap-0.5 text-[11px] ${isActive ? 'text-amber' : 'text-muted'}`}
                    >
                        <Icon size={20} aria-hidden="true" /> {label}
                    </NavLink>
                </li>
            ))}
        </ul>
    </nav>
);

const Shell = ({ children }) => {
    const [searchOpen, setSearchOpen] = useState(false);
    const [modulesOpen, setModulesOpen] = useState(false);
    const { pathname } = useLocation();
    useStudyTimer();

    useEffect(() => {
        const onKeyDown = (event) => {
            const typing = ['INPUT', 'TEXTAREA', 'SELECT'].includes(document.activeElement?.tagName);
            if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'k') {
                event.preventDefault();
                setSearchOpen(true);
            } else if (event.key === '/' && !typing) {
                event.preventDefault();
                setSearchOpen(true);
            }
        };
        window.addEventListener('keydown', onKeyDown);
        return () => window.removeEventListener('keydown', onKeyDown);
    }, []);

    useEffect(() => {
        window.scrollTo({ top: 0, behavior: 'instant' });
    }, [pathname]);

    return (
        <div className="min-h-svh bg-[radial-gradient(80%_40%_at_50%_0%,rgba(240,81,56,0.08),transparent_70%)]">
            <a href="#dsa-main" className="sr-only focus:not-sr-only focus:fixed focus:left-3 focus:top-3 focus:z-50 focus:rounded-full focus:bg-amber focus:px-4 focus:py-2 focus:text-ink">Skip to content</a>
            <TopBar onSearch={() => setSearchOpen(true)} onModules={() => setModulesOpen(true)} />
            <div className="lg:grid lg:grid-cols-[288px_minmax(0,1fr)]">
                <aside className="sticky top-14 hidden h-[calc(100svh-3.5rem)] overflow-y-auto overscroll-contain border-r border-line px-3 py-4 lg:block">
                    <PrimaryNav />
                    <div className="my-4 border-t border-line" />
                    <ModuleTree />
                </aside>
                <main id="dsa-main" tabIndex={-1} className="min-w-0 px-4 pb-28 pt-6 focus:outline-none sm:px-8 lg:pb-16 lg:pt-10">
                    {children}
                </main>
            </div>
            <MobileTabs />
            <CommandPalette open={searchOpen} onClose={() => setSearchOpen(false)} />
            <Sheet open={modulesOpen} onClose={() => setModulesOpen(false)} label="Modules" className="sm:max-w-md">
                <div className="flex h-full flex-col bg-raised sm:max-h-[80vh] sm:rounded-2xl sm:border sm:border-line">
                    <div className="flex items-center justify-between border-b border-line px-4 py-3">
                        <p className="font-semibold">Modules</p>
                        <button type="button" onClick={() => setModulesOpen(false)} aria-label="Close modules" className="flex h-9 w-9 items-center justify-center rounded-full hover:bg-white/8">
                            <X size={18} aria-hidden="true" />
                        </button>
                    </div>
                    <div className="flex-1 overflow-y-auto px-3 py-3">
                        <PrimaryNav onNavigate={() => setModulesOpen(false)} />
                        <div className="my-4 border-t border-line" />
                        <ModuleTree onNavigate={() => setModulesOpen(false)} />
                    </div>
                </div>
            </Sheet>
        </div>
    );
};

export default Shell;
