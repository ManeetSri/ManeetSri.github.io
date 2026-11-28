import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowLeft, Eye, LoaderCircle, RotateCcw } from 'lucide-react';
import { useCourse } from '../course/context.js';
import { useContent } from '../content/index.js';
import { critiqueScore, ratingFromCritique, ratingFromRubric, skillScores, statusFromCritique, statusFromRubric } from '../engine/exercises.js';
import { mdxComponents } from '../mdx/components.js';
import { DesignAnswerContext } from '../mdx/designContext.js';
import { cardId, useActions, useCourseStore, useStore } from '../store/store.js';
import { AutosaveTextarea } from '../ui/AutosaveTextarea.jsx';
import { formatDate, formatDuration, relativeDays } from '../ui/format.js';
import { useConsoleMeta, useNow } from '../ui/hooks.js';
import { RatingPicker, Stopwatch } from '../ui/PracticeControls.jsx';
import { Button, Card, Chip, EmptyState } from '../ui/primitives.jsx';

const LEVELS = ['Not yet', 'Getting there', 'Solid', 'Strong'];
const MARKS = [['found', 'Found'], ['partial', 'Partly'], ['missed', 'Missed']];
const SEVERITY_TONE = { high: 'red', medium: 'amber', low: 'neutral' };
const REVEAL_AFTER_WORDS = 150;

const wordCount = (text = '') => (text.trim() ? text.trim().split(/\s+/).length : 0);

// One box per section of the answer template, each saving on its own
const SectionedAnswer = ({ sections, answers, onSave, onInput }) => (
    <div className="space-y-5">
        {sections.map((section) => (
            <div key={section.id} id={`answer-${section.id}`}>
                <div className="mb-1 flex items-baseline justify-between gap-2">
                    <p className="font-medium">{section.title}</p>
                    <span className="font-mono text-[11px] text-muted">{wordCount(answers[section.id])} words</span>
                </div>
                <p className="mb-2 text-xs text-muted">{section.prompt}</p>
                <AutosaveTextarea
                    initial={answers[section.id]}
                    onSave={(text) => onSave(section.id, text)}
                    onInput={(text) => onInput(section.id, text)}
                    label={section.title}
                    rows={section.rows}
                />
            </div>
        ))}
    </div>
);

// Each criterion scored 1–4 against what a strong answer covers
const RubricScorer = ({ rubric, scores, onChange }) => (
    <div className="space-y-4">
        {rubric.map((criterion) => (
            <fieldset key={criterion.id} className="rounded-xl bg-white/[0.03] p-3">
                <legend className="sr-only">{criterion.label}</legend>
                <p className="font-medium">{criterion.label}</p>
                <ul className="mb-2.5 mt-1 list-disc space-y-0.5 pl-5 text-sm text-muted">
                    {criterion.look_for.map((point) => <li key={point}>{point}</li>)}
                </ul>
                <div className="grid grid-cols-4 gap-1.5">
                    {LEVELS.map((label, index) => (
                        <button key={label} type="button" aria-pressed={scores[criterion.id] === index + 1} onClick={() => onChange(criterion.id, index + 1)} className={`rounded-lg px-1 py-1.5 text-xs ${scores[criterion.id] === index + 1 ? 'bg-amber/20 text-amber ring-1 ring-amber' : 'bg-white/[0.05] text-muted hover:text-paper'}`}>
                            {label}
                        </button>
                    ))}
                </div>
            </fieldset>
        ))}
    </div>
);

// Each finding a strong review spots: did yours?
const FindingsChecklist = ({ findings, marks, onChange }) => (
    <div className="space-y-3">
        {findings.map((finding) => (
            <fieldset key={finding.id} className="rounded-xl bg-white/[0.03] p-3">
                <legend className="sr-only">{finding.title}</legend>
                <div className="flex flex-wrap items-center gap-2">
                    <Chip tone={SEVERITY_TONE[finding.severity]}>{finding.severity}</Chip>
                    {finding.lines && <span className="font-mono text-[11px] text-muted">line{finding.lines.includes('-') ? 's' : ''} {finding.lines.replace('-', '–')}</span>}
                </div>
                <p className="mt-1.5 font-medium">{finding.title}</p>
                <p className="mb-2.5 mt-1 text-sm text-muted">{finding.detail}</p>
                <div className="grid grid-cols-3 gap-1.5">
                    {MARKS.map(([value, label]) => (
                        <button key={value} type="button" aria-pressed={marks[finding.id] === value} onClick={() => onChange(finding.id, value)} className={`rounded-lg px-1 py-1.5 text-xs ${marks[finding.id] === value ? 'bg-amber/20 text-amber ring-1 ring-amber' : 'bg-white/[0.05] text-muted hover:text-paper'}`}>
                            {label}
                        </button>
                    ))}
                </div>
            </fieldset>
        ))}
    </div>
);

const Scoring = ({ item, data, answers, seconds, onLogged }) => {
    const { designs, cards } = useCourseStore();
    const actions = useActions();
    const now = useNow(15_000);
    const card = cards[cardId.design(item.id)];
    const [scores, setScores] = useState({});
    const [marks, setMarks] = useState({});
    const [rating, setRating] = useState(null);
    const isCritique = item.kind === 'critique';
    const rubric = data.rubric ?? [];
    const findings = data.findings ?? [];
    const complete = isCritique ? findings.every((finding) => marks[finding.id]) : rubric.every((criterion) => scores[criterion.id]);
    const critique = critiqueScore(marks, findings);
    const status = isCritique ? statusFromCritique(critique) : statusFromRubric(scores);
    const suggested = complete ? (isCritique ? ratingFromCritique(critique) : ratingFromRubric(scores, status)) : null;
    const chosen = rating ?? suggested;

    const log = () => {
        actions.logDesignAttempt(item.id, {
            kind: item.kind,
            seconds,
            rating: chosen,
            status,
            words: Object.values(answers).reduce((sum, text) => sum + wordCount(text), 0),
            answer: answers,
            ...(isCritique ? { marks } : { scores, skills: skillScores(scores, rubric) }),
        });
        onLogged();
    };

    const attempts = Object.values(designs[item.id]?.attempts ?? {}).sort((a, b) => b.at - a.at);

    return (
        <div className="space-y-4">
            <Card className="space-y-4 p-4">
                <div>
                    <p className="font-semibold">{isCritique ? 'Which of these did you find?' : 'Score your answer'}</p>
                    <p className="mt-1 text-sm text-muted">{isCritique ? 'Compare your list with each finding. Partly counts half.' : 'Compare with the model answer, criterion by criterion. Be honest: it decides when this comes back.'}</p>
                </div>
                {isCritique
                    ? <FindingsChecklist findings={findings} marks={marks} onChange={(id, value) => setMarks((current) => ({ ...current, [id]: value }))} />
                    : <RubricScorer rubric={rubric} scores={scores} onChange={(id, value) => setScores((current) => ({ ...current, [id]: value }))} />}
                {complete && isCritique && <p className="text-sm">You found <span className="font-semibold text-amber">{Math.round(critique * 100)}%</span>, weighted by severity.</p>}
                <RatingPicker card={card} value={chosen} onChange={setRating} now={now} legend={suggested ? `When should it come back? Suggested: ${suggested}` : 'When should it come back?'} />
                <Button variant="primary" className="w-full" onClick={log} disabled={!complete || !chosen}>Log this attempt</Button>
                <p aria-live="polite" className="text-center text-xs text-muted">{card ? `Next recall ${relativeDays(card.due, now)}.` : ''}</p>
            </Card>
            {attempts.length > 0 && (
                <Card className="p-4">
                    <p className="mb-2 text-sm font-medium">Attempts</p>
                    <ul className="space-y-1.5 text-sm">
                        {attempts.slice(0, 6).map((attempt) => (
                            <li key={attempt.at} className="flex justify-between gap-2 text-muted">
                                <span>{formatDate(attempt.at, { day: 'numeric', month: 'short' })} · {attempt.status}{attempt.source === 'mock' ? ' · mock' : ''}</span>
                                <span className="font-mono">{attempt.seconds ? formatDuration(attempt.seconds) : '–'}</span>
                            </li>
                        ))}
                    </ul>
                </Card>
            )}
        </div>
    );
};

const ExerciseView = ({ item }) => {
    const { DIFFICULTIES, PATTERNS, lessonById, links, kindLabels } = useCourse();
    useConsoleMeta(item.title, links.item(item.id));
    const content = useContent(item.kind, item.id);
    const { ready } = useStore();
    const { designs } = useCourseStore();
    const actions = useActions();
    const record = designs[item.id];
    const revealed = Boolean(record?.revealedAt);
    const [answers, setAnswers] = useState(null);
    const [seconds, setSeconds] = useState(0);
    const [running, setRunning] = useState(false);
    const [confirming, setConfirming] = useState(false);
    const [logged, setLogged] = useState(false);
    const [showTopics, setShowTopics] = useState(false);

    // The stored draft, taken once when progress has loaded; after that, typing is the source of truth
    if (answers === null && ready) setAnswers(record?.draft ?? record?.lastAnswer ?? {});

    useEffect(() => {
        if (!running) return undefined;
        const timer = setInterval(() => setSeconds((value) => value + 1), 1000);
        return () => clearInterval(timer);
    }, [running]);

    const data = content.status === 'ready' ? content.data : null;
    const sections = useMemo(() => data?.workspace?.sections ?? [], [data]);
    const words = Object.values(answers ?? {}).reduce((sum, text) => sum + wordCount(text), 0);

    const reveal = () => {
        if (!confirming && (words < REVEAL_AFTER_WORDS || running)) {
            setConfirming(true);
            return;
        }
        setRunning(false);
        setConfirming(false);
        actions.setRevealed(item.id, item.kind, true);
    };

    const startOver = () => {
        actions.startDesignOver(item.id, item.kind);
        setAnswers({});
        setSeconds(0);
        setLogged(false);
    };

    const context = useMemo(() => ({ revealed, answers: answers ?? {}, sections }), [revealed, answers, sections]);

    return (
        <div className="mx-auto max-w-7xl">
            <Link to={links.practice} className="mb-4 inline-flex min-h-11 items-center gap-1.5 text-sm text-amber hover:underline"><ArrowLeft size={16} aria-hidden="true" /> All practice</Link>
            <div className="grid grid-cols-1 gap-8 xl:grid-cols-[minmax(0,1.1fr)_minmax(0,1fr)]">
                <article className="min-w-0 max-w-3xl">
                    <p className="font-mono text-xs uppercase tracking-wider text-muted">{kindLabels?.[item.kind] ?? item.kind}</p>
                    <h1 className="mt-1 font-display text-[clamp(2rem,5vw,3rem)] font-semibold leading-[1.08] tracking-tight">{item.title}</h1>
                    <div className="mt-4 flex flex-wrap items-center gap-2">
                        <Chip tone={item.difficulty === 'medium' ? 'amber' : item.difficulty === 'hard' || item.difficulty === 'challenge' ? 'red' : 'green'}>{DIFFICULTIES[item.difficulty].label}</Chip>
                        <Chip>~{item.minutes} min</Chip>
                        {showTopics
                            ? item.patterns.map((key) => <Chip key={key} tone="amber">{PATTERNS[key]}</Chip>)
                            : <button type="button" onClick={() => setShowTopics(true)} className="inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 font-mono text-xs text-muted hover:bg-white/8"><Eye size={12} aria-hidden="true" /> Show topics</button>}
                    </div>
                    <p className="mt-3 text-sm text-muted">
                        From {item.lessons.map((id, index) => (
                            <span key={id}>{index > 0 && ', '}<Link to={links.lesson(id)} className="text-amber hover:underline">{lessonById[id]?.title}</Link></span>
                        ))}
                    </p>
                    <div className="mt-6">
                        {content.status === 'loading' && <p className="flex items-center gap-2 text-muted" role="status"><LoaderCircle size={18} aria-hidden="true" className="animate-spin" /> Loading…</p>}
                        {content.status === 'missing' && <EmptyState title="Coming soon" />}
                        {content.status === 'error' && <EmptyState title="It didn’t load">Check your connection and open it again.</EmptyState>}
                        {content.status === 'ready' && (
                            <DesignAnswerContext.Provider value={context}>
                                <content.Content components={mdxComponents} />
                            </DesignAnswerContext.Provider>
                        )}
                    </div>
                </article>

                <aside className="min-w-0 xl:sticky xl:top-20 xl:max-h-[calc(100svh-6rem)] xl:self-start xl:overflow-y-auto">
                    {(answers === null || !data) && <p className="flex items-center gap-2 text-muted" role="status"><LoaderCircle size={18} aria-hidden="true" className="animate-spin" /> Loading your answer…</p>}
                    {answers !== null && data && !revealed && (
                        <div className="space-y-4">
                            <Card className="space-y-3 p-4">
                                <Stopwatch seconds={seconds} running={running} target={data.workspace?.minutes} onToggle={() => setRunning((value) => !value)} onReset={() => { setRunning(false); setSeconds(0); }} />
                                <p className="text-sm text-muted">Write as if explaining it to a colleague. Notes and bullet points are fine. Everything saves as you type.</p>
                            </Card>
                            <Card className="p-4">
                                <SectionedAnswer
                                    sections={sections}
                                    answers={answers}
                                    onInput={(id, text) => setAnswers((current) => ({ ...current, [id]: text }))}
                                    onSave={(id, text) => actions.saveDesignDraft(item.id, item.kind, id, text)}
                                />
                            </Card>
                            <Card className="space-y-2 p-4">
                                {confirming && (
                                    <p className="rounded-xl bg-amber/10 p-3 text-sm" role="alert">
                                        {running ? 'The timer is still running. ' : ''}{words < REVEAL_AFTER_WORDS ? `You’ve written ${words} words. ` : ''}Reveal anyway? Seeing the answer first makes the exercise much less useful.
                                    </p>
                                )}
                                <Button variant="primary" className="w-full" onClick={reveal}>{confirming ? 'Yes, reveal it' : 'I’m done: show the model answer'}</Button>
                                {confirming && <Button variant="ghost" className="w-full" onClick={() => setConfirming(false)}>Keep writing</Button>}
                            </Card>
                        </div>
                    )}
                    {answers !== null && data && revealed && (
                        <div className="space-y-4">
                            {logged
                                ? <Card className="p-4 text-sm"><p className="font-semibold">Logged.</p><p className="mt-1 text-muted">It’ll come back for recall on schedule. Start over any time to write it again from scratch.</p></Card>
                                : <Scoring item={item} data={data} answers={answers} seconds={seconds} onLogged={() => setLogged(true)} />}
                            <Card className="p-4">
                                <Button className="w-full" onClick={startOver}><RotateCcw size={15} aria-hidden="true" /> Start over</Button>
                                <p className="mt-2 text-xs text-muted">Keeps this answer as your last one, and gives you a blank page.</p>
                            </Card>
                            <Card className="p-4">
                                <p className="mb-2 text-sm font-medium">Notes</p>
                                <AutosaveTextarea initial={record?.notes} onSave={(text) => actions.saveDesignNotes(item.id, item.kind, text)} label="Notes on this exercise" placeholder="What you missed, what to remember next time." rows={3} />
                            </Card>
                        </div>
                    )}
                </aside>
            </div>
        </div>
    );
};

const DesignExercisePage = ({ item }) => <ExerciseView key={item.id} item={item} />;

export default DesignExercisePage;
