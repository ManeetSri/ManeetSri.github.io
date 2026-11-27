import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, ArrowRight, CheckCircle2, CircleX, Compass, GraduationCap, Rocket, Sprout } from 'lucide-react';
import { GOALS, lessons as allLessons, moduleById, partByNumber } from '../data/curriculum.js';
import { PLACEMENT_GROUPS } from '../data/placement.js';
import { pathFor, projection } from '../engine/path.js';
import Question from '../mdx/quiz/Question.jsx';
import { useActions, useProfile } from '../store/store.js';
import { formatDate, formatMinutes } from '../ui/format.js';
import { useConsoleMeta, useNow } from '../ui/hooks.js';
import { Button, Card, ProgressBar } from '../ui/primitives.jsx';

const STEPS = ['welcome', 'goal', 'pace', 'placement', 'summary'];
const MINUTE_OPTIONS = [15, 30, 45, 60, 90, 120];
const QUESTIONS = PLACEMENT_GROUPS.flatMap((group) => group.questions.map((question) => ({ ...question, group: group.id })));

const Choice = ({ selected, onSelect, title, detail, icon: Icon }) => (
    <button
        type="button"
        role="radio"
        aria-checked={selected}
        onClick={onSelect}
        className={`flex w-full items-start gap-3 rounded-2xl border p-4 text-left transition-colors ${selected ? 'border-amber bg-amber/10' : 'border-line hover:border-white/25'}`}
    >
        {Icon && <Icon size={20} aria-hidden="true" className={`mt-0.5 shrink-0 ${selected ? 'text-amber' : 'text-muted'}`} />}
        <span>
            <span className="block font-semibold">{title}</span>
            {detail && <span className="mt-0.5 block text-sm leading-relaxed text-muted">{detail}</span>}
        </span>
    </button>
);

const Pills = ({ label, options, value, onChange, format = (option) => option }) => (
    <div role="radiogroup" aria-label={label} className="flex flex-wrap gap-2">
        {options.map((option) => (
            <button
                key={option}
                type="button"
                role="radio"
                aria-checked={value === option}
                onClick={() => onChange(option)}
                className={`h-11 min-w-14 rounded-full px-4 font-mono text-sm ${value === option ? 'bg-amber/20 text-amber ring-1 ring-amber' : 'bg-white/[0.06] text-muted hover:text-paper'}`}
            >
                {format(option)}
            </button>
        ))}
    </div>
);

const groupLessons = (group) => group.modules.flatMap((id) => moduleById[id].lessons.map((lesson) => lesson.id));

// The optional placement check: one question at a time, first answers only
const Placement = ({ answers, setAnswers, onDone }) => {
    const [index, setIndex] = useState(() => Math.min(Object.keys(answers).length, QUESTIONS.length - 1));
    const question = QUESTIONS[index];
    const answered = question.id in answers;
    const last = index === QUESTIONS.length - 1;

    return (
        <div>
            <div className="mb-4 flex items-center justify-between gap-3 font-mono text-xs text-muted">
                <span>Question {index + 1} of {QUESTIONS.length} · {PLACEMENT_GROUPS.find((group) => group.id === question.group).title}</span>
                <button type="button" onClick={onDone} className="text-amber hover:underline">Skip the rest</button>
            </div>
            <ProgressBar value={(index + (answered ? 1 : 0)) / QUESTIONS.length} label="Placement progress" className="mb-5" />
            <Question
                key={question.id}
                question={question}
                allowRetry={false}
                onResult={(correct) => setAnswers((current) => (question.id in current ? current : { ...current, [question.id]: correct }))}
            />
            <div className="mt-5 flex justify-end">
                <Button variant="primary" disabled={!answered} onClick={() => (last ? onDone() : setIndex(index + 1))}>
                    {last ? 'See my results' : 'Next question'} <ArrowRight size={18} aria-hidden="true" />
                </Button>
            </div>
        </div>
    );
};

const OnboardingPage = () => {
    useConsoleMeta('Set up your path', '/dsa/start');
    const navigate = useNavigate();
    const profile = useProfile();
    const actions = useActions();
    const now = useNow();
    const [step, setStep] = useState(0);
    const [goal, setGoal] = useState(profile.goal);
    const [minutesPerDay, setMinutesPerDay] = useState(profile.minutesPerDay);
    const [daysPerWeek, setDaysPerWeek] = useState(profile.daysPerWeek);
    const [targetDate, setTargetDate] = useState(profile.targetDate ?? '');
    const [placementMode, setPlacementMode] = useState('zero');
    const [checking, setChecking] = useState(false);
    const [answers, setAnswers] = useState({});
    const [skipGroups, setSkipGroups] = useState(() => new Set());

    const passedGroups = PLACEMENT_GROUPS.filter((group) => group.questions.every((question) => answers[question.id] === true));
    const skippedLessons = new Set(PLACEMENT_GROUPS.filter((group) => skipGroups.has(group.id)).flatMap(groupLessons));
    const path = pathFor(goal, allLessons);
    const remainingPath = path.filter((lesson) => !skippedLessons.has(lesson.id));
    const pace = projection({ path: remainingPath, progress: {}, minutesPerDay, daysPerWeek, now });
    const firstLesson = remainingPath[0];
    const current = STEPS[step];

    const finishPlacement = () => {
        setChecking(false);
        setSkipGroups(new Set(PLACEMENT_GROUPS.filter((group) => group.questions.every((question) => answers[question.id] === true)).map((group) => group.id)));
        setStep(STEPS.indexOf('summary'));
    };

    const start = () => {
        const correct = Object.values(answers).filter(Boolean).length;
        actions.saveProfile({
            goal,
            minutesPerDay,
            daysPerWeek,
            targetDate: targetDate || null,
            onboardedAt: Date.now(),
            placement: placementMode === 'check' ? { answered: Object.keys(answers).length, correct, testedOut: [...skipGroups] } : null,
        });
        if (skippedLessons.size) actions.testOut([...skippedLessons]);
        navigate('/dsa');
    };

    const next = () => {
        if (current === 'placement' && placementMode === 'check') {
            setChecking(true);
            return;
        }
        setStep((value) => Math.min(STEPS.length - 1, value + 1));
    };

    return (
        <div className="mx-auto max-w-2xl">
            <div className="mb-8 flex items-center gap-3">
                {step > 0 && !checking && (
                    <button type="button" onClick={() => setStep(step - 1)} aria-label="Back" className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-white/8 hover:bg-white/12">
                        <ArrowLeft size={18} aria-hidden="true" />
                    </button>
                )}
                <div className="flex-1">
                    <p className="mb-1.5 font-mono text-xs text-muted">Step {step + 1} of {STEPS.length}</p>
                    <ProgressBar value={(step + 1) / STEPS.length} label="Setup progress" />
                </div>
            </div>

            {current === 'welcome' && (
                <section aria-labelledby="start-title">
                    <span className="swift-gradient mb-6 flex h-14 w-14 items-center justify-center rounded-2xl text-ink"><Compass size={26} aria-hidden="true" /></span>
                    <h1 id="start-title" className="font-display text-[clamp(2.2rem,6vw,3.5rem)] font-semibold leading-[1.05] tracking-tight">Let’s set up your path.</h1>
                    <p className="mt-4 text-lg leading-relaxed text-muted">Two minutes, four questions about you, and an optional quick check of what you already know.</p>
                    <ul className="mt-6 space-y-3">
                        {[
                            'Your goal decides which lessons form your main path.',
                            'Your pace sizes each day’s plan and predicts when you’ll finish.',
                            'The quick check lets you skip Swift topics you already know. Starting from zero is completely fine.',
                        ].map((text) => (
                            <li key={text} className="flex gap-3 text-paper/85"><CheckCircle2 size={20} aria-hidden="true" className="mt-0.5 shrink-0 text-[#30D158]" /> {text}</li>
                        ))}
                    </ul>
                </section>
            )}

            {current === 'goal' && (
                <section aria-labelledby="goal-title">
                    <h1 id="goal-title" className="font-display text-4xl font-semibold tracking-tight">What’s your goal?</h1>
                    <p className="mt-2 text-muted">You can change it any time in Settings, and your progress carries over.</p>
                    <div role="radiogroup" aria-labelledby="goal-title" className="mt-6 grid gap-2">
                        {Object.entries(GOALS).map(([key, value]) => (
                            <Choice key={key} selected={goal === key} onSelect={() => setGoal(key)} title={value.label} detail={`${value.detail} ${pathFor(key, allLessons).length} lessons.`} />
                        ))}
                    </div>
                </section>
            )}

            {current === 'pace' && (
                <section aria-labelledby="pace-title" className="space-y-6">
                    <div>
                        <h1 id="pace-title" className="font-display text-4xl font-semibold tracking-tight">How much time do you have?</h1>
                        <p className="mt-2 text-muted">Be realistic: a steady pace you can keep beats an ambitious one you can’t.</p>
                    </div>
                    <div>
                        <p className="mb-2 text-sm font-medium">Minutes a day</p>
                        <Pills label="Minutes a day" options={MINUTE_OPTIONS} value={minutesPerDay} onChange={setMinutesPerDay} />
                    </div>
                    <div>
                        <p className="mb-2 text-sm font-medium">Days a week</p>
                        <Pills label="Days a week" options={[3, 4, 5, 6, 7]} value={daysPerWeek} onChange={setDaysPerWeek} />
                    </div>
                    <label className="block text-sm font-medium">
                        Target date <span className="font-normal text-muted">(optional)</span>
                        <input type="date" value={targetDate} onChange={(event) => setTargetDate(event.target.value)} className="mt-2 block h-11 rounded-xl border border-line bg-surface px-3 text-paper outline-none [color-scheme:dark] focus:border-amber" />
                    </label>
                    <Card className="p-5" aria-live="polite">
                        <p className="font-mono text-xs text-muted">At this pace</p>
                        <p className="mt-1 font-display text-3xl font-semibold tracking-tight">{formatDate(pace.finish, { month: 'long', year: 'numeric' })}</p>
                        <p className="mt-1 text-sm text-muted">
                            {path.length} lessons, about {formatMinutes(pace.minutesLeft)} of study at {formatMinutes(minutesPerDay * daysPerWeek)} a week.
                            {targetDate && (pace.finish > new Date(targetDate).getTime()
                                ? ' That’s after your target date: add time, or pick a narrower goal.'
                                : ' That’s before your target date.')}
                        </p>
                    </Card>
                </section>
            )}

            {current === 'placement' && !checking && (
                <section aria-labelledby="placement-title">
                    <h1 id="placement-title" className="font-display text-4xl font-semibold tracking-tight">Where should you start?</h1>
                    <p className="mt-2 text-muted">Part I teaches Swift from the very beginning. If you already know some of it, a quick check can skip those modules.</p>
                    <div role="radiogroup" aria-labelledby="placement-title" className="mt-6 grid gap-2">
                        <Choice selected={placementMode === 'zero'} onSelect={() => setPlacementMode('zero')} icon={Sprout} title="Start from zero (recommended)" detail="Begin with your first Swift program. Nothing is assumed." />
                        <Choice selected={placementMode === 'check'} onSelect={() => setPlacementMode('check')} icon={GraduationCap} title={`Take a quick check (${QUESTIONS.length} questions, about 6 minutes)`} detail="Two questions per topic. Get both right and you can skip that topic’s lessons, which stay open whenever you want them." />
                    </div>
                </section>
            )}

            {current === 'placement' && checking && <Placement answers={answers} setAnswers={setAnswers} onDone={finishPlacement} />}

            {current === 'summary' && (
                <section aria-labelledby="summary-title" className="space-y-6">
                    <div>
                        <h1 id="summary-title" className="font-display text-4xl font-semibold tracking-tight">Your path is ready.</h1>
                        <p className="mt-2 text-muted">{GOALS[goal].label} · {formatMinutes(minutesPerDay)} a day, {daysPerWeek} days a week.</p>
                    </div>

                    {placementMode === 'check' && Object.keys(answers).length > 0 && (
                        <Card className="p-5">
                            <p className="font-semibold">Quick check: {Object.values(answers).filter(Boolean).length} of {Object.keys(answers).length} right</p>
                            <p className="mt-1 text-sm text-muted">Tick the topics to skip. Skipped lessons count as done on your path but don’t earn XP, and you can open them any time.</p>
                            <ul className="mt-4 space-y-2">
                                {PLACEMENT_GROUPS.map((group) => {
                                    const passed = passedGroups.includes(group);
                                    const count = groupLessons(group).length;
                                    return (
                                        <li key={group.id}>
                                            <label className={`flex items-center gap-3 rounded-xl border px-3 py-2.5 ${passed ? 'cursor-pointer border-line' : 'border-transparent opacity-60'}`}>
                                                <input
                                                    type="checkbox"
                                                    disabled={!passed}
                                                    checked={skipGroups.has(group.id)}
                                                    onChange={() => setSkipGroups((current) => {
                                                        const updated = new Set(current);
                                                        if (updated.has(group.id)) updated.delete(group.id);
                                                        else updated.add(group.id);
                                                        return updated;
                                                    })}
                                                    className="h-4 w-4 accent-[var(--color-amber)]"
                                                />
                                                <span className="flex-1 text-sm">{group.title} <span className="text-muted">· {count} lessons</span></span>
                                                {passed
                                                    ? <CheckCircle2 size={17} aria-label="Both right" className="text-[#30D158]" />
                                                    : <CircleX size={17} aria-label="Not both right" className="text-muted" />}
                                            </label>
                                        </li>
                                    );
                                })}
                            </ul>
                        </Card>
                    )}

                    <div className="grid gap-3 sm:grid-cols-3">
                        <Card className="p-4"><p className="font-mono text-xs text-muted">Lessons</p><p className="mt-1 font-display text-2xl font-semibold">{remainingPath.length}</p></Card>
                        <Card className="p-4"><p className="font-mono text-xs text-muted">Study time</p><p className="mt-1 font-display text-2xl font-semibold">{formatMinutes(pace.minutesLeft)}</p></Card>
                        <Card className="p-4"><p className="font-mono text-xs text-muted">Finish around</p><p className="mt-1 font-display text-2xl font-semibold">{formatDate(pace.finish, { month: 'short', year: 'numeric' })}</p></Card>
                    </div>
                    {firstLesson && (
                        <p className="text-muted">
                            First up: <span className="text-paper">{firstLesson.title}</span> ({moduleById[firstLesson.module].code}, Part {firstLesson.part}: {partByNumber[firstLesson.part].title}).
                        </p>
                    )}
                </section>
            )}

            {!checking && (
                <div className="mt-10 flex justify-end">
                    {current === 'summary' ? (
                        <Button variant="primary" onClick={start}><Rocket size={18} aria-hidden="true" /> Start learning</Button>
                    ) : (
                        <Button variant="primary" onClick={next}>
                            {current === 'placement' && placementMode === 'check' ? 'Start the check' : 'Continue'} <ArrowRight size={18} aria-hidden="true" />
                        </Button>
                    )}
                </div>
            )}
        </div>
    );
};

export default OnboardingPage;
