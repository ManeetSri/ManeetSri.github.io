import { useCallback, useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, Clock3, LoaderCircle, Mic, RotateCcw } from 'lucide-react';
import { useCourse } from '../course/context.js';
import { useContent } from '../content/index.js';
import { isDone } from '../engine/path.js';
import { mdxComponents } from '../mdx/components.js';
import { DesignAnswerContext } from '../mdx/designContext.js';
import { useActions, useCourseStore } from '../store/store.js';
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

// A coding mock, as DSA has always had; a course can bring its own (course.mock), such as design interviews
const PROBLEM_MOCK = {
    kind: 'problem',
    durations: DURATIONS,
    criteria: CRITERIA,
    eligible: (item) => (item.kind ?? 'problem') === 'problem',
    intro: 'A random problem from topics you’ve finished, a timer, and no hints. Afterwards you score yourself against the same rubric interviewers use.',
    empty: 'Finish a few lessons with practice problems first: mocks only use topics you’ve learned.',
    noun: 'problem',
};

const HIDDEN_ANSWERS = { revealed: false, answers: {}, sections: [] };
const ANSWER_KEY = 'maneet-mock-answer:';

// What you write during a design mock stays in this tab until it's scored, then goes with the attempt
const readAnswer = (id) => {
    try {
        return JSON.parse(sessionStorage.getItem(ANSWER_KEY + id)) ?? {};
    } catch {
        return {};
    }
};
const writeAnswer = (id, answer) => {
    try {
        sessionStorage.setItem(ANSWER_KEY + id, JSON.stringify(answer));
    } catch {
        // Storage is blocked: the answer still lives in memory until the mock is saved
    }
};

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

// The brief of a design exercise, with its model answer kept hidden, and boxes for each part of the answer
const DesignMock = ({ item, answer, onChange }) => {
    const content = useContent(item.kind, item.id);
    if (content.status === 'loading') return <p className="flex items-center gap-2 text-muted"><LoaderCircle size={18} aria-hidden="true" className="animate-spin" /> Loading…</p>;
    if (content.status !== 'ready') return <EmptyState title="The brief didn’t load" />;
    const sections = content.data.workspace?.sections ?? [];
    return (
        <>
            <DesignAnswerContext.Provider value={HIDDEN_ANSWERS}>
                <content.Content components={mdxComponents} />
            </DesignAnswerContext.Provider>
            <Card className="mt-8 space-y-5 p-4">
                {sections.map((section) => (
                    <label key={section.id} className="block">
                        <span className="font-medium">{section.title}</span>
                        <span className="mb-2 block text-xs text-muted">{section.prompt}</span>
                        <textarea value={answer[section.id] ?? ''} onChange={(event) => onChange({ ...answer, [section.id]: event.target.value })} rows={section.rows} className="w-full rounded-xl border border-line bg-white/[0.04] p-3 text-sm leading-relaxed outline-none focus:border-amber" />
                    </label>
                ))}
            </Card>
        </>
    );
};

const Rubric = ({ problem, seconds, onSaved, mock, answer }) => {
    const course = useCourse();
    const { recordMock } = useActions();
    const [status, setStatus] = useState('solved');
    const [scores, setScores] = useState(() => Object.fromEntries(mock.criteria.map((criterion) => [criterion.id, 0])));
    const [notes, setNotes] = useState('');
    const complete = Object.values(scores).every((value) => value > 0);

    const save = () => {
        if (mock.kind === 'problem') recordMock({ problemId: problem.id, seconds, status, scores, notes: notes.trim() });
        else recordMock({ course: course.id, kind: mock.kind, itemId: problem.id, seconds, status, scores, notes: notes.trim(), answer });
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
                    {(mock.kind === 'problem'
                        ? [['solved', 'Solved it'], ['helped', 'Solved with a nudge'], ['attempted', 'Didn’t finish']]
                        : [['solved', 'Covered it well'], ['helped', 'Got there with gaps'], ['attempted', 'Ran out of time or ideas']]).map(([value, label]) => (
                        <button key={value} type="button" aria-pressed={status === value} onClick={() => setStatus(value)} className={`h-10 rounded-full px-4 text-sm ${status === value ? 'bg-amber/20 text-amber ring-1 ring-amber' : 'bg-white/[0.06] text-muted hover:text-paper'}`}>{label}</button>
                    ))}
                </div>
            </fieldset>
            {mock.criteria.map((criterion) => (
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
    const course = useCourse();
    const { DIFFICULTIES, practice, practiceById, links } = course;
    const mock = course.mock ?? PROBLEM_MOCK;
    useConsoleMeta('Mock interview', links.mock);
    const { lessons, problems: problemRecords, designs, mocks } = useCourseStore();
    const records = mock.kind === 'problem' ? problemRecords : designs;
    const [duration, setDuration] = useState(45);
    const [answer, setAnswer] = useState({});
    const [difficulty, setDifficulty] = useState('any');
    const [stage, setStage] = useState('setup');
    const [session, setSession] = useState(null);

    const learned = useMemo(() => practice.filter((item) => mock.eligible(item) && item.lessons.some((id) => isDone(id, lessons))), [practice, mock, lessons]);
    const pool = learned.filter((problem) => difficulty === 'any' || problem.difficulty === difficulty);
    const history = Object.values(mocks).sort((a, b) => b.at - a.at);

    const start = () => {
        // Prefer problems not already solved, so the mock is a real test
        const fresh = pool.filter((problem) => records[problem.id]?.status !== 'solved');
        const choices = fresh.length ? fresh : pool;
        const problem = choices[Math.floor(Math.random() * choices.length)];
        setAnswer(mock.kind === 'problem' ? {} : readAnswer(problem.id));
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
                {mock.kind === 'problem' ? (
                    <>
                        <p className="mt-2 text-sm text-muted">Talk through your approach out loud before you write code. Hints and solutions are hidden until you finish.</p>
                        <div className="mt-6"><Statement problem={session.problem} /></div>
                        <Card className="mt-8 p-4">
                            <SolutionEditor problem={session.problem} />
                            <p className="mt-3 text-sm text-muted">Write it as you would in an interview, then press “I’m done”. Test it with <code className="font-mono text-amber">swift test --filter {session.problem.swiftTest}</code> afterwards, not during.</p>
                        </Card>
                    </>
                ) : (
                    <>
                        <p className="mt-2 text-sm text-muted">Talk it through out loud as you write: clarify, sketch the big picture, then go deep. The model answer stays hidden until you’ve scored yourself.</p>
                        <div className="mt-6"><DesignMock item={session.problem} answer={answer} onChange={(next) => { setAnswer(next); writeAnswer(session.problem.id, next); }} /></div>
                    </>
                )}
            </div>
        );
    }

    if (stage === 'rubric' && session) {
        return <div className="mx-auto max-w-2xl"><Rubric problem={session.problem} seconds={session.seconds} mock={mock} answer={answer} onSaved={() => { writeAnswer(session.problem.id, {}); setStage('saved'); }} /></div>;
    }

    return (
        <div className="mx-auto max-w-3xl">
            <PageHeader eyebrow="Practise under interview conditions" title="Mock interview">
                {mock.intro}
            </PageHeader>

            {stage === 'saved' && (
                <Card className="mb-6 flex flex-wrap items-center gap-3 border-[#30D158]/40 p-5">
                    <p className="flex-1">{mock.kind === 'problem' ? 'Saved, and the problem is scheduled for a re-solve. Now read the full solutions with fresh eyes.' : 'Saved, with your answer. Open the exercise to compare it with the model answer.'}</p>
                    <Link to={links.item(session.problem.id)} className="inline-flex items-center gap-1 text-amber hover:underline">Open {session.problem.title} <ArrowRight size={15} aria-hidden="true" /></Link>
                </Card>
            )}

            <Card className="space-y-5 p-5 sm:p-6">
                <div>
                    <p className="mb-2 text-sm font-medium">Time limit</p>
                    <div className="flex gap-2">
                        {mock.durations.map((minutes) => (
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
                <p className="text-sm text-muted">{pool.length} {mock.noun}{pool.length === 1 ? '' : 's'} to draw from, all from lessons you’ve finished.</p>
                <Button variant="primary" disabled={!pool.length} onClick={start}>{stage === 'saved' ? <><RotateCcw size={16} aria-hidden="true" /> Start another</> : 'Start the mock'}</Button>
                {!pool.length && <p className="text-sm text-muted">{mock.empty}</p>}
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
                                        <Link to={links.item(mock.problemId ?? mock.itemId)} className="flex-1 hover:text-amber">{practiceById[mock.problemId ?? mock.itemId]?.title ?? mock.problemId ?? mock.itemId}</Link>
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
