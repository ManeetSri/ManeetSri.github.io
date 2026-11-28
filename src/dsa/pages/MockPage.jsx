import { useCallback, useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, Clock3, LoaderCircle, Mic, RotateCcw } from 'lucide-react';
import { useCourse } from '../course/context.js';
import { useContent } from '../content/index.js';
import { isDone } from '../engine/path.js';
import { mdxComponents } from '../mdx/components.js';
import { useActions, useStore } from '../store/store.js';
import { formatDate, formatDuration } from '../ui/format.js';
import { useConsoleMeta } from '../ui/hooks.js';
import { Button, Card, Chip, EmptyState, PageHeader } from '../ui/primitives.jsx';
import { SolutionEditor } from '../ui/SolutionEditor.jsx';

const DURATIONS = [30, 45, 60];
const CRITERIA = [
    { id: 'understanding', label: 'Understanding', detail: 'Restated the problem and asked about edge cases before coding' },
    { id: 'approach', label: 'Approach', detail: 'Started from brute force and reasoned towards something better' },
    { id: 'correctness', label: 'Correctness', detail: 'The code works, including the edge cases' },
    { id: 'complexity', label: 'Complexity', detail: 'Stated the time and space cost, and why' },
    { id: 'communication', label: 'Communication', detail: 'Explained the thinking out loud as you went' },
];
const LEVELS = ['Not yet', 'Getting there', 'Solid', 'Strong'];

// During a mock the statement shows, but hints and solutions don't
const HiddenSection = () => null;
const Heading = mdxComponents.h2;
const SolutionsHeading = ({ children, ...props }) => (String(children) === 'Solutions' ? null : <Heading {...props}>{children}</Heading>);
const mockComponents = { ...mdxComponents, Hints: HiddenSection, Approach: HiddenSection, h2: SolutionsHeading };

const Countdown = ({ endsAt, onEnd }) => {
    const [left, setLeft] = useState(() => Math.max(0, Math.round((endsAt - Date.now()) / 1000)));
    useEffect(() => {
        const timer = setInterval(() => {
            const remaining = Math.max(0, Math.round((endsAt - Date.now()) / 1000));
            setLeft(remaining);
            if (remaining === 0) onEnd();
        }, 1000);
        return () => clearInterval(timer);
    }, [endsAt, onEnd]);
    return <span className={`font-mono text-2xl tabular-nums ${left < 300 ? 'text-[#FF9D96]' : ''}`} aria-live="off">{formatDuration(left)}</span>;
};

const Statement = ({ problem }) => {
    const content = useContent('problem', problem.id);
    const { Content } = content;
    if (content.status === 'loading') return <p className="flex items-center gap-2 text-muted"><LoaderCircle size={18} aria-hidden="true" className="animate-spin" /> Loading…</p>;
    if (content.status !== 'ready') return <EmptyState title="The statement didn’t load" />;
    return <Content components={mockComponents} />;
};

const Rubric = ({ problem, seconds, onSaved }) => {
    const { recordMock } = useActions();
    const [status, setStatus] = useState('solved');
    const [scores, setScores] = useState(() => Object.fromEntries(CRITERIA.map((criterion) => [criterion.id, 0])));
    const [notes, setNotes] = useState('');
    const complete = Object.values(scores).every((value) => value > 0);

    const save = () => {
        recordMock({ problemId: problem.id, seconds, status, scores, notes: notes.trim() });
        onSaved();
    };

    return (
        <div className="space-y-5">
            <PageHeader eyebrow={`${problem.title} · ${formatDuration(seconds)} used`} title="Score yourself honestly">
                The rubric is how interviewers think. Rate each part as it really went: the point is to see what to practise next.
            </PageHeader>
            <fieldset>
                <legend className="mb-2 font-medium">Outcome</legend>
                <div className="flex flex-wrap gap-2">
                    {[['solved', 'Solved it'], ['helped', 'Solved with a nudge'], ['attempted', 'Didn’t finish']].map(([value, label]) => (
                        <button key={value} type="button" aria-pressed={status === value} onClick={() => setStatus(value)} className={`h-10 rounded-full px-4 text-sm ${status === value ? 'bg-amber/20 text-amber ring-1 ring-amber' : 'bg-white/[0.06] text-muted hover:text-paper'}`}>{label}</button>
                    ))}
                </div>
            </fieldset>
            {CRITERIA.map((criterion) => (
                <fieldset key={criterion.id}>
                    <legend className="font-medium">{criterion.label}</legend>
                    <p className="mb-2 text-sm text-muted">{criterion.detail}</p>
                    <div className="grid grid-cols-2 gap-2 sm:grid-cols-4">
                        {LEVELS.map((label, index) => (
                            <button key={label} type="button" aria-pressed={scores[criterion.id] === index + 1} onClick={() => setScores((current) => ({ ...current, [criterion.id]: index + 1 }))} className={`h-10 rounded-xl px-2 text-sm ${scores[criterion.id] === index + 1 ? 'bg-amber/20 text-amber ring-1 ring-amber' : 'bg-white/[0.06] text-muted hover:text-paper'}`}>
                                {label}
                            </button>
                        ))}
                    </div>
                </fieldset>
            ))}
            <label className="block">
                <span className="font-medium">What to practise next</span>
                <textarea value={notes} onChange={(event) => setNotes(event.target.value)} rows={3} placeholder="The one thing that would have made this go better." className="mt-2 w-full rounded-xl border border-line bg-white/[0.04] p-3 text-sm outline-none focus:border-amber" />
            </label>
            <Button variant="primary" disabled={!complete} onClick={save}>Save this mock</Button>
        </div>
    );
};

const MockPage = () => {
    const { DIFFICULTIES, problemById, problems, links } = useCourse();
    useConsoleMeta('Mock interview', links.mock);
    const { lessons, problems: records, mocks } = useStore();
    const [duration, setDuration] = useState(45);
    const [difficulty, setDifficulty] = useState('any');
    const [stage, setStage] = useState('setup');
    const [session, setSession] = useState(null);

    const learned = useMemo(() => problems.filter((problem) => problem.lessons.some((id) => isDone(id, lessons))), [problems, lessons]);
    const pool = learned.filter((problem) => difficulty === 'any' || problem.difficulty === difficulty);
    const history = Object.values(mocks).sort((a, b) => b.at - a.at);

    const start = () => {
        // Prefer problems not already solved, so the mock is a real test
        const fresh = pool.filter((problem) => records[problem.id]?.status !== 'solved');
        const choices = fresh.length ? fresh : pool;
        const problem = choices[Math.floor(Math.random() * choices.length)];
        setSession({ problem, startedAt: Date.now(), endsAt: Date.now() + duration * 60_000, seconds: 0 });
        setStage('running');
    };

    const finish = useCallback(() => {
        setSession((current) => ({ ...current, seconds: Math.round((Date.now() - current.startedAt) / 1000) }));
        setStage('rubric');
    }, []);

    if (stage === 'running' && session) {
        return (
            <div className="mx-auto max-w-4xl">
                <div className="sticky top-14 z-10 -mx-4 mb-6 flex items-center gap-3 border-b border-line bg-ink/90 px-4 py-3 backdrop-blur sm:-mx-8 sm:px-8">
                    <Mic size={18} aria-hidden="true" className="text-swift" />
                    <span className="font-medium">Mock interview</span>
                    <Chip>{DIFFICULTIES[session.problem.difficulty].label}</Chip>
                    <span className="ml-auto flex items-center gap-2"><Clock3 size={16} aria-hidden="true" className="text-muted" /><Countdown endsAt={session.endsAt} onEnd={finish} /></span>
                    <Button size="sm" variant="primary" onClick={finish}>I’m done</Button>
                </div>
                <h1 className="font-display text-[clamp(2rem,5vw,3rem)] font-semibold leading-tight tracking-tight">{session.problem.title}</h1>
                <p className="mt-2 text-sm text-muted">Talk through your approach out loud before you write code. Hints and solutions are hidden until you finish.</p>
                <div className="mt-6"><Statement problem={session.problem} /></div>
                <Card className="mt-8 p-4">
                    <SolutionEditor problem={session.problem} />
                    <p className="mt-3 text-sm text-muted">Write it as you would in an interview, then press “I’m done”. Test it with <code className="font-mono text-amber">swift test --filter {session.problem.swiftTest}</code> afterwards, not during.</p>
                </Card>
            </div>
        );
    }

    if (stage === 'rubric' && session) {
        return <div className="mx-auto max-w-2xl"><Rubric problem={session.problem} seconds={session.seconds} onSaved={() => setStage('saved')} /></div>;
    }

    return (
        <div className="mx-auto max-w-3xl">
            <PageHeader eyebrow="Practise under interview conditions" title="Mock interview">
                A random problem from topics you’ve finished, a timer, and no hints. Afterwards you score yourself against the same rubric interviewers use.
            </PageHeader>

            {stage === 'saved' && (
                <Card className="mb-6 flex flex-wrap items-center gap-3 border-[#30D158]/40 p-5">
                    <p className="flex-1">Saved, and the problem is scheduled for a re-solve. Now read the full solutions with fresh eyes.</p>
                    <Link to={links.item(session.problem.id)} className="inline-flex items-center gap-1 text-amber hover:underline">Open {session.problem.title} <ArrowRight size={15} aria-hidden="true" /></Link>
                </Card>
            )}

            <Card className="space-y-5 p-5 sm:p-6">
                <div>
                    <p className="mb-2 text-sm font-medium">Time limit</p>
                    <div className="flex gap-2">
                        {DURATIONS.map((minutes) => (
                            <button key={minutes} type="button" aria-pressed={duration === minutes} onClick={() => setDuration(minutes)} className={`h-10 rounded-full px-4 font-mono text-sm ${duration === minutes ? 'bg-amber/20 text-amber ring-1 ring-amber' : 'bg-white/[0.06] text-muted hover:text-paper'}`}>{minutes} min</button>
                        ))}
                    </div>
                </div>
                <div>
                    <p className="mb-2 text-sm font-medium">Difficulty</p>
                    <div className="flex flex-wrap gap-2">
                        {['any', 'easy', 'medium', 'hard'].map((value) => (
                            <button key={value} type="button" aria-pressed={difficulty === value} onClick={() => setDifficulty(value)} className={`h-10 rounded-full px-4 text-sm ${difficulty === value ? 'bg-amber/20 text-amber ring-1 ring-amber' : 'bg-white/[0.06] text-muted hover:text-paper'}`}>{value === 'any' ? 'Any' : DIFFICULTIES[value].label}</button>
                        ))}
                    </div>
                </div>
                <p className="text-sm text-muted">{pool.length} problem{pool.length === 1 ? '' : 's'} to draw from, all from lessons you’ve finished.</p>
                <Button variant="primary" disabled={!pool.length} onClick={start}>{stage === 'saved' ? <><RotateCcw size={16} aria-hidden="true" /> Start another</> : 'Start the mock'}</Button>
                {!pool.length && <p className="text-sm text-muted">Finish a few lessons with practice problems first: mocks only use topics you’ve learned.</p>}
            </Card>

            {history.length > 0 && (
                <section className="mt-8">
                    <h2 className="mb-3 font-display text-2xl font-semibold tracking-tight">Past mocks</h2>
                    <ul className="divide-y divide-line rounded-2xl border border-line bg-surface">
                        {history.map((mock) => {
                            const values = Object.values(mock.scores ?? {});
                            const average = values.length ? values.reduce((sum, value) => sum + value, 0) / values.length : 0;
                            return (
                                <li key={mock.at} className="px-4 py-3 text-sm">
                                    <div className="flex flex-wrap items-center gap-3">
                                        <span className="font-mono text-xs text-muted">{formatDate(mock.at)}</span>
                                        <Link to={links.item(mock.problemId)} className="flex-1 hover:text-amber">{problemById[mock.problemId]?.title ?? mock.problemId}</Link>
                                        <span className="font-mono text-xs text-muted">{formatDuration(mock.seconds)}</span>
                                        <Chip tone={average >= 3 ? 'green' : average >= 2 ? 'amber' : 'red'}>{average.toFixed(1)} / 4</Chip>
                                    </div>
                                    {mock.notes && <p className="mt-1.5 text-muted"><span className="font-medium text-paper">Practise next:</span> {mock.notes}</p>}
                                </li>
                            );
                        })}
                    </ul>
                </section>
            )}
        </div>
    );
};

export default MockPage;
