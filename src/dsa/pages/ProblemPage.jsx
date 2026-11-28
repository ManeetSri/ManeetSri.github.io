import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ArrowLeft, Eye, LoaderCircle, Pause, Play, RotateCcw, TerminalSquare } from 'lucide-react';
import { useCourse } from '../course/context.js';
import { useContent } from '../content/index.js';
import { reviewCard, RATINGS } from '../engine/srs.js';
import { CopyButton } from '../mdx/CodeBlock.jsx';
import { mdxComponents } from '../mdx/components.js';
import { cardId, useActions, useStore } from '../store/store.js';
import { AutosaveTextarea } from '../ui/AutosaveTextarea.jsx';
import { SolutionEditor } from '../ui/SolutionEditor.jsx';
import { formatDate, formatDuration, relativeDays } from '../ui/format.js';
import { useConsoleMeta, useNow } from '../ui/hooks.js';
import { Button, Card, Chip, EmptyState } from '../ui/primitives.jsx';
import ConsoleNotFound from './ConsoleNotFound.jsx';

const OUTCOMES = [
    { id: 'attempted', label: 'Didn’t finish' },
    { id: 'helped', label: 'Solved with help' },
    { id: 'solved', label: 'Solved' },
];

const RATING_LABELS = { again: 'Again', hard: 'Hard', good: 'Good', easy: 'Easy' };

const intervalLabel = (card) => (card.interval === 0 ? '<10m' : `${card.interval}d`);

const Stopwatch = ({ seconds, running, onToggle, onReset }) => (
    <div className="flex items-center gap-2">
        <span className="min-w-16 font-mono text-2xl tabular-nums" aria-label={`Timer ${formatDuration(seconds)}`}>{formatDuration(seconds)}</span>
        <Button size="sm" onClick={onToggle} aria-label={running ? 'Pause the timer' : 'Start the timer'}>
            {running ? <Pause size={15} aria-hidden="true" /> : <Play size={15} aria-hidden="true" />} {running ? 'Pause' : 'Start'}
        </Button>
        <Button size="sm" variant="ghost" onClick={onReset} aria-label="Reset the timer"><RotateCcw size={15} aria-hidden="true" /></Button>
    </div>
);

const Workspace = ({ problem }) => {
    const { swift } = useCourse();
    const { problems, cards } = useStore();
    const actions = useActions();
    const record = problems[problem.id];
    const card = cards[cardId.problem(problem.id)];
    const [seconds, setSeconds] = useState(0);
    const [running, setRunning] = useState(false);
    const [outcome, setOutcome] = useState('solved');
    const [rating, setRating] = useState(null);
    const [logged, setLogged] = useState(false);
    const now = useNow(15_000);

    useEffect(() => {
        if (!running) return undefined;
        const timer = setInterval(() => setSeconds((value) => value + 1), 1000);
        return () => clearInterval(timer);
    }, [running]);

    const save = () => {
        actions.logAttempt(problem.id, { status: outcome, seconds, rating });
        setRunning(false);
        setSeconds(0);
        setRating(null);
        setLogged(true);
    };

    const attempts = Object.values(record?.attempts ?? {}).sort((a, b) => b.at - a.at);
    const preview = card ?? { ease: 2.5, interval: 0, reps: 0, lapses: 0 };

    return (
        <div className="space-y-4">
            <Card className="p-4">
                <SolutionEditor problem={problem} />
            </Card>

            <Card className="p-4">
                <p className="mb-2 flex items-center gap-2 font-semibold"><TerminalSquare size={17} aria-hidden="true" className="text-amber" /> Run the tests</p>
                <p className="mb-3 text-sm text-muted">
                    {import.meta.env.DEV
                        ? <>Save to package puts your code in <code className="font-mono text-amber">Sources/Exercises</code>. Then, in <code className="font-mono text-amber">{swift.dir}</code>, run:</>
                        : <>Your code is saved here. To test it, put it in the matching file in <code className="font-mono text-amber">{swift.dir}/Sources/Exercises</code> (Download names it for you), then run:</>}
                </p>
                <div className="flex items-center gap-1 rounded-xl bg-[#101217] py-1 pl-3 pr-1">
                    <code className="min-w-0 flex-1 overflow-x-auto whitespace-nowrap font-mono text-[12px]">swift test --filter {problem.swiftTest}</code>
                    <CopyButton text={`swift test --filter ${problem.swiftTest}`} />
                </div>
            </Card>

            <Card className="space-y-4 p-4">
                <Stopwatch seconds={seconds} running={running} onToggle={() => setRunning((value) => !value)} onReset={() => { setRunning(false); setSeconds(0); }} />
                <fieldset>
                    <legend className="mb-2 text-sm font-medium">How did it go?</legend>
                    <div className="flex flex-wrap gap-2">
                        {OUTCOMES.map((item) => (
                            <button key={item.id} type="button" aria-pressed={outcome === item.id} onClick={() => setOutcome(item.id)} className={`h-9 rounded-full px-3.5 text-sm ${outcome === item.id ? 'bg-white/15 font-medium text-paper' : 'bg-white/[0.05] text-muted'}`}>{item.label}</button>
                        ))}
                    </div>
                </fieldset>
                <fieldset>
                    <legend className="mb-2 text-sm font-medium">When should it come back?</legend>
                    <div className="grid grid-cols-4 gap-1.5">
                        {RATINGS.map((key) => (
                            <button key={key} type="button" aria-pressed={rating === key} aria-label={`${RATING_LABELS[key]}, back in ${intervalLabel(reviewCard(preview, key, now))}`} onClick={() => setRating(key)} className={`rounded-xl px-1 py-2 text-center text-sm ${rating === key ? 'bg-amber/20 text-amber ring-1 ring-amber' : 'bg-white/[0.05] text-muted hover:text-paper'}`}>
                                <span className="block font-medium">{RATING_LABELS[key]}</span>
                                <span className="block font-mono text-[11px] opacity-80">{intervalLabel(reviewCard(preview, key, now))}</span>
                            </button>
                        ))}
                    </div>
                </fieldset>
                <Button variant="primary" className="w-full" onClick={save} disabled={!rating}>Log this attempt</Button>
                <p aria-live="polite" className="text-center text-xs text-muted">
                    {logged && card ? `Saved. Next re-solve ${relativeDays(card.due, now)}.` : card ? `Next re-solve ${relativeDays(card.due, now)}.` : ''}
                </p>
            </Card>

            {attempts.length > 0 && (
                <Card className="p-4">
                    <p className="mb-2 text-sm font-medium">Attempts</p>
                    <ul className="space-y-1.5 text-sm">
                        {attempts.slice(0, 6).map((attempt) => (
                            <li key={attempt.at} className="flex justify-between gap-2 text-muted">
                                <span>{formatDate(attempt.at, { day: 'numeric', month: 'short' })} · {OUTCOMES.find((item) => item.id === attempt.status)?.label}</span>
                                <span className="font-mono">{attempt.seconds ? formatDuration(attempt.seconds) : '–'}</span>
                            </li>
                        ))}
                    </ul>
                </Card>
            )}

            <Card className="p-4">
                <p className="mb-2 text-sm font-medium">Notes</p>
                <AutosaveTextarea initial={record?.notes} onSave={(text) => actions.saveProblemText(problem.id, 'notes', text)} label="Notes on this problem" placeholder="The key insight, the mistake you made, what to remember." rows={3} />
            </Card>
        </div>
    );
};

const ProblemView = ({ problem }) => {
    const { DIFFICULTIES, PATTERNS, lessonById, links } = useCourse();
    useConsoleMeta(problem.title, links.item(problem.id));
    const content = useContent('problem', problem.id);
    const [showPatterns, setShowPatterns] = useState(false);
    const { Content } = content;

    return (
        <div className="mx-auto max-w-7xl">
            <Link to={links.practice} className="mb-4 inline-flex min-h-11 items-center gap-1.5 text-sm text-amber hover:underline"><ArrowLeft size={16} aria-hidden="true" /> All problems</Link>
            {/* Wide screens put the statement and your code side by side */}
            <div className="grid grid-cols-1 gap-8 xl:grid-cols-[minmax(0,1.1fr)_minmax(0,1fr)]">
                <article className="min-w-0 max-w-3xl">
                    <h1 className="font-display text-[clamp(2rem,5vw,3rem)] font-semibold leading-[1.08] tracking-tight">{problem.title}</h1>
                    <div className="mt-4 flex flex-wrap items-center gap-2">
                        <Chip tone={problem.difficulty === 'medium' ? 'amber' : problem.difficulty === 'hard' || problem.difficulty === 'challenge' ? 'red' : 'green'}>{DIFFICULTIES[problem.difficulty].label}</Chip>
                        <Chip>~{problem.minutes} min</Chip>
                        {showPatterns
                            ? problem.patterns.map((key) => <Chip key={key} tone="amber">{PATTERNS[key]}</Chip>)
                            : <button type="button" onClick={() => setShowPatterns(true)} className="inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 font-mono text-xs text-muted hover:bg-white/8"><Eye size={12} aria-hidden="true" /> Show pattern</button>}
                    </div>
                    <p className="mt-3 text-sm text-muted">
                        From {problem.lessons.map((id, index) => (
                            <span key={id}>{index > 0 && ', '}<Link to={links.lesson(id)} className="text-amber hover:underline">{lessonById[id]?.title}</Link></span>
                        ))}
                        {problem.similar && <> · Similar: <a href={problem.similar.url} target="_blank" rel="noopener noreferrer" className="text-amber hover:underline">{problem.similar.label}</a></>}
                    </p>
                    <div className="mt-6">
                        {content.status === 'loading' && <p className="flex items-center gap-2 text-muted" role="status"><LoaderCircle size={18} aria-hidden="true" className="animate-spin" /> Loading…</p>}
                        {content.status === 'missing' && <EmptyState title="Statement coming soon" />}
                        {content.status === 'error' && <EmptyState title="The problem didn’t load">Check your connection and open it again.</EmptyState>}
                        {content.status === 'ready' && <Content components={mdxComponents} />}
                    </div>
                </article>
                <aside className="min-w-0 xl:sticky xl:top-20 xl:max-h-[calc(100svh-6rem)] xl:self-start xl:overflow-y-auto">
                    <Workspace problem={problem} />
                </aside>
            </div>
        </div>
    );
};

const ProblemPage = () => {
    const { practiceById } = useCourse();
    const { problemId } = useParams();
    const problem = practiceById[problemId];
    if (!problem) return <ConsoleNotFound />;
    return <ProblemView key={problem.id} problem={problem} />;
};

export default ProblemPage;
