import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { ArrowRight, CheckCircle2, Circle, CircleDot, Code2, Search, Shuffle } from 'lucide-react';
import { lessonById } from '../data/curriculum.js';
import { DIFFICULTIES, LISTS, PATTERNS, problems } from '../data/problems.js';
import { isDue } from '../engine/srs.js';
import { cardId, useStore } from '../store/store.js';
import { useConsoleMeta, useNow } from '../ui/hooks.js';
import { Button, Chip, EmptyState, PageHeader } from '../ui/primitives.jsx';

const STATUS = {
    solved: { icon: CheckCircle2, className: 'text-[#30D158]', label: 'Solved' },
    helped: { icon: CheckCircle2, className: 'text-amber', label: 'Solved with help' },
    attempted: { icon: CircleDot, className: 'text-amber', label: 'Attempted' },
    new: { icon: Circle, className: 'text-white/25', label: 'Not tried' },
};

const Select = ({ label, value, onChange, options }) => (
    <label className="flex min-w-0 flex-col gap-1 text-xs text-muted">
        {label}
        <select value={value} onChange={(event) => onChange(event.target.value)} className="h-10 rounded-xl border border-line bg-surface px-3 text-sm text-paper outline-none focus:border-amber">
            <option value="">Any</option>
            {Object.entries(options).map(([key, text]) => <option key={key} value={key}>{text}</option>)}
        </select>
    </label>
);

const PracticePage = () => {
    useConsoleMeta('Practice', '/dsa/practice');
    const navigate = useNavigate();
    const { problems: records, cards, lessons } = useStore();
    const [query, setQuery] = useState('');
    const [difficulty, setDifficulty] = useState('');
    const [pattern, setPattern] = useState('');
    const [status, setStatus] = useState('');
    const [list, setList] = useState('');
    const now = useNow();

    const statusOf = (id) => records[id]?.status ?? 'new';
    const due = (id) => cards[cardId.problem(id)] && isDue(cards[cardId.problem(id)], now);

    const filtered = problems.filter((problem) => {
        if (query && !problem.title.toLowerCase().includes(query.toLowerCase())) return false;
        if (difficulty && problem.difficulty !== difficulty) return false;
        if (pattern && !problem.patterns.includes(pattern)) return false;
        if (list && !(problem.lists ?? []).includes(list)) return false;
        if (status === 'due') return due(problem.id);
        if (status && (records[problem.id]?.status ?? 'new') !== status) return false;
        return true;
    });

    // A random unsolved problem from lessons already finished, so it's fair game
    const randomFromLearned = () => {
        const candidates = problems.filter((problem) => statusOf(problem.id) !== 'solved' && problem.lessons.some((id) => lessons[id]?.completedAt));
        const pool = candidates.length ? candidates : problems.filter((problem) => statusOf(problem.id) !== 'solved');
        if (pool.length) navigate(`/dsa/practice/${pool[Math.floor(Math.random() * pool.length)].id}`);
    };

    const solved = problems.filter((problem) => statusOf(problem.id) === 'solved').length;

    return (
        <div className="mx-auto max-w-5xl">
            <PageHeader eyebrow={`${solved} of ${problems.length} solved`} title="Practice">
                Every problem has hints, several approaches and tests you run in the companion Swift package. More arrive with each part.
            </PageHeader>

            <div className="mb-6 grid gap-3 sm:grid-cols-2 lg:grid-cols-[minmax(0,1.4fr)_repeat(4,minmax(0,1fr))]">
                <label className="flex flex-col gap-1 text-xs text-muted sm:col-span-2 lg:col-span-1">
                    Search
                    <span className="relative">
                        <Search size={16} aria-hidden="true" className="absolute left-3 top-1/2 -translate-y-1/2 text-muted" />
                        <input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Problem name" className="h-10 w-full rounded-xl border border-line bg-surface pl-9 pr-3 text-sm text-paper outline-none focus:border-amber" />
                    </span>
                </label>
                <Select label="Difficulty" value={difficulty} onChange={setDifficulty} options={Object.fromEntries(Object.entries(DIFFICULTIES).map(([key, value]) => [key, value.label]))} />
                <Select label="Pattern" value={pattern} onChange={setPattern} options={PATTERNS} />
                <Select label="Status" value={status} onChange={setStatus} options={{ new: 'Not tried', attempted: 'Attempted', helped: 'Solved with help', solved: 'Solved', due: 'Due for a re-solve' }} />
                <Select label="List" value={list} onChange={setList} options={LISTS} />
            </div>

            <div className="mb-4 flex justify-end">
                <Button size="sm" onClick={randomFromLearned}><Shuffle size={15} aria-hidden="true" /> Random from what I’ve learned</Button>
            </div>

            {filtered.length === 0 ? (
                <EmptyState icon={Code2} title="No problems match">Try clearing a filter.</EmptyState>
            ) : (
                <ul className="divide-y divide-line overflow-hidden rounded-2xl border border-line bg-surface">
                    {filtered.map((problem) => {
                        const { icon: Icon, className, label } = STATUS[statusOf(problem.id)];
                        return (
                            <li key={problem.id}>
                                <Link to={`/dsa/practice/${problem.id}`} className="flex items-center gap-3 px-4 py-3.5 hover:bg-white/[0.03]">
                                    <Icon size={20} aria-hidden="true" className={`shrink-0 ${className}`} />
                                    <span className="sr-only">{label}:</span>
                                    <span className="min-w-0 flex-1">
                                        <span className="block font-medium">{problem.title}</span>
                                        <span className="block truncate text-xs text-muted">{problem.lessons.map((id) => lessonById[id]?.title).join(' · ')}</span>
                                    </span>
                                    {due(problem.id) && <Chip tone="amber">due</Chip>}
                                    <span className="hidden gap-1.5 md:flex">{problem.patterns.map((key) => <Chip key={key}>{PATTERNS[key]}</Chip>)}</span>
                                    <Chip tone={problem.difficulty === 'hard' || problem.difficulty === 'challenge' ? 'red' : problem.difficulty === 'medium' ? 'amber' : 'green'}>{DIFFICULTIES[problem.difficulty].label}</Chip>
                                    <ArrowRight size={16} aria-hidden="true" className="shrink-0 text-muted" />
                                </Link>
                            </li>
                        );
                    })}
                </ul>
            )}
        </div>
    );
};

export default PracticePage;
