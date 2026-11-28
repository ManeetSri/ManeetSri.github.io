import { ArrowRight, Award, CalendarClock, CheckCircle2, Circle, Code2, Compass, Flame, Hourglass, Layers, Sparkles, Target } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useCourse } from '../course/context.js';
import { readLastPath, useCourseSummaries } from '../ui/courseSummaries.js';
import { completion, isDone, isOnPath, projection } from '../engine/path.js';
import { planToday } from '../engine/today.js';
import { useCourseStore, useProfile } from '../store/store.js';
import { formatDate, formatMinutes, greeting } from '../ui/format.js';
import { useConsoleMeta, useNow, usePath, useStats } from '../ui/hooks.js';
import { ButtonLink, Card, Chip, ProgressBar, ProgressRing } from '../ui/primitives.jsx';

const PlanRow = ({ done, icon: Icon, to, title, detail, action }) => (
    <li>
        <Link to={to} className="group flex items-center gap-3 rounded-xl px-3 py-3 hover:bg-white/[0.04]">
            {done
                ? <CheckCircle2 size={22} aria-hidden="true" className="shrink-0 text-[#30D158]" />
                : <Circle size={22} aria-hidden="true" className="shrink-0 text-white/25" />}
            <span className="sr-only">{done ? 'Done:' : 'To do:'}</span>
            <Icon size={17} aria-hidden="true" className="shrink-0 text-muted" />
            <span className="min-w-0 flex-1">
                <span className={`block truncate font-medium ${done ? 'text-muted line-through decoration-white/30' : ''}`}>{title}</span>
                <span className="block truncate text-sm text-muted">{detail}</span>
            </span>
            {!done && action && <span className="hidden shrink-0 text-sm text-amber group-hover:underline sm:inline">{action}</span>}
            <ArrowRight size={16} aria-hidden="true" className="shrink-0 text-muted transition-transform group-hover:translate-x-0.5" />
        </Link>
    </li>
);

const Stat = ({ icon: Icon, label, value, children, tone = 'text-amber' }) => (
    <div className="rounded-2xl border border-line bg-surface p-4">
        <p className="flex items-center gap-1.5 font-mono text-xs text-muted"><Icon size={14} aria-hidden="true" className={tone} /> {label}</p>
        <p className="mt-1.5 font-display text-2xl font-semibold tracking-tight">{value}</p>
        {children}
    </div>
);

// The other courses at a glance, so their reviews don't pile up unseen
const OtherCourses = () => {
    const current = useCourse();
    const others = useCourseSummaries().filter((summary) => summary.course.id !== current.id);
    if (!others.length) return null;
    return others.map(({ course, progress, due, next }) => (
        <Link key={course.id} to={readLastPath(course)} className="block rounded-2xl border border-line bg-surface p-4 hover:border-white/25 sm:col-span-2 lg:col-span-1">
            <p className="flex items-center justify-between gap-2 text-xs text-muted">
                <span className="font-mono uppercase tracking-wider">Also learning</span>
                <span className="font-mono">{Math.round(progress.ratio * 100)}%</span>
            </p>
            <p className="mt-1 font-semibold">{course.title}</p>
            <p className="mt-1 text-sm text-muted">{due ? `${due} review${due === 1 ? '' : 's'} due` : 'No reviews due'}{next ? ` · next: ${next.title}` : ''}</p>
        </Link>
    ));
};

const TodayPage = () => {
    const course = useCourse();
    const { GOALS, moduleById, modules, partByNumber, DIFFICULTIES, links, onboarding } = course;
    useConsoleMeta('Today');
    const state = useCourseStore();
    const profile = useProfile();
    const path = usePath();
    const { xp, rank, streak } = useStats();
    const now = useNow();
    const plan = planToday({ path, lessons: state.lessons, problems: state.problems, cards: state.cards, minutesPerDay: profile.minutesPerDay, now, practiceById: course.practiceById, cardMinutes: course.cardMinutes });
    const progress = completion(path, state.lessons);
    const pace = projection({ path, progress: state.lessons, minutesPerDay: profile.minutesPerDay, daysPerWeek: profile.daysPerWeek, now });
    const next = plan.next;
    const nextModule = next && moduleById[next.module];
    const itemsDone = plan.lessons.filter((item) => item.done).length + plan.practice.filter((item) => item.done).length + (plan.reviews.planned === 0 && plan.reviews.doneToday > 0 ? 1 : 0);
    const itemsTotal = plan.lessons.length + plan.practice.length + (plan.reviews.planned + plan.reviews.doneToday > 0 ? 1 : 0);
    const behind = profile.targetDate && pace.finish > new Date(profile.targetDate).getTime();
    // The first module whose path lessons are all done but whose checkpoint isn't passed yet
    const checkpointDue = modules.find((module) => {
        const onPath = module.lessons.filter((lesson) => lesson.status === 'ready' && isOnPath(lesson, profile.goal, GOALS));
        return onPath.length > 0 && onPath.every((lesson) => isDone(lesson.id, state.lessons)) && !state.checkpoints[module.id]?.passedAt;
    });

    return (
        <div className="mx-auto max-w-5xl">
            <header className="mb-8 flex flex-wrap items-end justify-between gap-4">
                <div>
                    <p className="mb-2 font-mono text-sm text-swift">{formatDate(now, { weekday: 'long', day: 'numeric', month: 'long' })}</p>
                    <h1 className="font-display text-[clamp(2rem,5vw,3.25rem)] font-semibold leading-[1.05] tracking-tight">{greeting()}, Maneet.</h1>
                    <p className="mt-2 text-muted">
                        {GOALS[profile.goal]?.label} · {formatMinutes(profile.minutesPerDay)} a day, {profile.daysPerWeek} days a week ·{' '}
                        <Link to={links.settings} className="text-amber hover:underline">Change</Link>
                    </p>
                </div>
                <ProgressRing value={itemsTotal ? itemsDone / itemsTotal : 0} size={64} stroke={6} label={`${itemsDone} of ${itemsTotal} planned items done today`}>
                    <span className="font-mono text-xs">{itemsDone}/{itemsTotal}</span>
                </ProgressRing>
            </header>

            {!profile.onboardedAt && (
                <Card className="mb-6 flex flex-wrap items-center gap-4 border-amber/40 bg-amber/[0.06] p-5">
                    <Compass size={26} aria-hidden="true" className="shrink-0 text-amber" />
                    <div className="min-w-48 flex-1">
                        <p className="font-semibold">Set up your path first</p>
                        <p className="text-sm text-muted">{onboarding.setupPrompt}</p>
                    </div>
                    <ButtonLink to={links.start} variant="primary" size="sm">Set up <ArrowRight size={16} aria-hidden="true" /></ButtonLink>
                </Card>
            )}

            <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_300px]">
                <div className="space-y-6">
                    {next ? (
                        <Card className="relative overflow-hidden p-5 sm:p-6">
                            <div aria-hidden="true" className="swift-gradient absolute inset-x-0 top-0 h-1" />
                            <p className="font-mono text-xs text-muted">{state.lessons[next.id]?.openedAt ? 'Continue where you left off' : 'Up next on your path'} · {nextModule.code} {nextModule.title}</p>
                            <h2 className="mt-2 font-display text-2xl font-semibold tracking-tight sm:text-3xl">{next.title}</h2>
                            <p className="mt-2 text-sm text-muted">{formatMinutes(next.minutes)} · Part {next.part}: {partByNumber[next.part].title}</p>
                            {next.status === 'stub' ? (
                                <p className="mt-4 rounded-xl bg-white/[0.04] p-4 text-sm leading-relaxed text-paper/85">
                                    You’ve finished everything written so far. Part {next.part}’s lessons arrive in delivery phase {partByNumber[next.part].phase}.
                                    Meanwhile, keep your reviews going and revisit the practice problems.
                                </p>
                            ) : (
                                <ButtonLink to={links.lesson(next.id)} variant="primary" className="mt-5">
                                    {state.lessons[next.id]?.openedAt ? 'Continue lesson' : 'Start lesson'} <ArrowRight size={18} aria-hidden="true" />
                                </ButtonLink>
                            )}
                        </Card>
                    ) : (
                        <Card className="p-6"><p className="font-display text-2xl font-semibold">You’ve completed your whole path. Remarkable.</p></Card>
                    )}

                    <Card className="p-2 sm:p-3">
                        <div className="flex items-center justify-between px-3 pb-1 pt-2">
                            <h2 className="font-semibold">Today’s plan</h2>
                            <span className="font-mono text-xs text-muted">≈ {formatMinutes(plan.plannedMinutes)} of {formatMinutes(plan.budget)}</span>
                        </div>
                        <ul>
                            {(plan.reviews.planned > 0 || plan.reviews.doneToday > 0) && (
                                <PlanRow
                                    done={plan.reviews.planned === 0}
                                    icon={Layers}
                                    to={links.review}
                                    title={plan.reviews.planned > 0 ? `Review ${plan.reviews.planned} card${plan.reviews.planned === 1 ? '' : 's'}` : `Reviewed ${plan.reviews.doneToday} card${plan.reviews.doneToday === 1 ? '' : 's'}`}
                                    detail={plan.reviews.due > plan.reviews.planned ? `${plan.reviews.due} due in total` : 'Spaced repetition keeps it fresh'}
                                    action="Review"
                                />
                            )}
                            {plan.lessons.map(({ lesson, done }) => (
                                <PlanRow key={lesson.id} done={done} icon={Target} to={links.lesson(lesson.id)} title={lesson.title} detail={`${moduleById[lesson.module].code} · ${formatMinutes(lesson.minutes)}`} action="Learn" />
                            ))}
                            {checkpointDue && (
                                <PlanRow done={false} icon={Award} to={links.checkpoint(checkpointDue.id)} title={`Checkpoint: ${checkpointDue.title}`} detail={`${checkpointDue.code} · 12 questions · about 10 min`} action="Take it" />
                            )}
                            {plan.practice.map(({ problem, done }) => (
                                <PlanRow key={problem.id} done={done} icon={Code2} to={links.item(problem.id)} title={problem.title} detail={`${DIFFICULTIES[problem.difficulty].label} · ${formatMinutes(problem.minutes)}`} action="Solve" />
                            ))}
                            {itemsTotal === 0 && <li className="px-3 py-6 text-center text-sm text-muted">Nothing planned. Enjoy the day off, or open the path.</li>}
                        </ul>
                        {plan.comingSoon && plan.lessons.length === 0 && (
                            <p className="mx-3 mb-3 rounded-xl bg-white/[0.04] p-3 text-sm text-muted">
                                Next: <span className="text-paper">{plan.comingSoon.title}</span>, coming in phase {partByNumber[plan.comingSoon.part].phase}.
                            </p>
                        )}
                    </Card>
                </div>

                <aside className="grid content-start gap-3 sm:grid-cols-2 lg:grid-cols-1">
                    <Stat icon={Flame} label="Streak" value={`${streak} day${streak === 1 ? '' : 's'}`} tone="text-swift" />
                    <Stat icon={Sparkles} label={rank.title} value={`${xp.toLocaleString('en-GB')} XP`}>
                        {rank.next && (
                            <>
                                <ProgressBar value={rank.progress} label={`Progress to ${rank.next.title}`} className="mt-3" />
                                <p className="mt-1.5 text-xs text-muted">{(rank.next.min - xp).toLocaleString('en-GB')} XP to {rank.next.title}</p>
                            </>
                        )}
                    </Stat>
                    <Stat icon={Target} label="Your path" value={`${Math.round(progress.ratio * 100)}%`}>
                        <ProgressBar value={progress.ratio} label="Path completion" className="mt-3" />
                        <p className="mt-1.5 text-xs text-muted">{progress.done} of {progress.total} lessons</p>
                    </Stat>
                    <Stat icon={behind ? Hourglass : CalendarClock} label="At this pace" value={formatDate(pace.finish, { month: 'short', year: 'numeric' })} tone={behind ? 'text-[#FF9D96]' : 'text-amber'}>
                        <p className="mt-1.5 text-xs text-muted">
                            {formatMinutes(pace.minutesLeft)} of lessons left
                            {profile.targetDate && <> · target {formatDate(new Date(profile.targetDate).getTime())}{behind && <Chip tone="red" className="ml-1">behind</Chip>}</>}
                        </p>
                    </Stat>
                    <OtherCourses />
                </aside>
            </div>
        </div>
    );
};

export default TodayPage;
