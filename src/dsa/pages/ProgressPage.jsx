import { Award, Clock3, Code2, Flame, Layers, Lock, Radar, Sparkles, Target } from 'lucide-react';
import { useCourse } from '../course/context.js';
import { addDays, dayKey, startOfDay } from '../engine/dates.js';
import { completion } from '../engine/path.js';
import { minutesOn, RANKS } from '../engine/stats.js';
import { badgesFor, longestStreak, masteryByPart } from '../engine/badges.js';
import MasteryRadar from '../ui/MasteryRadar.jsx';
import { useCourseStore, useProfile } from '../store/store.js';
import { formatDate, formatMinutes } from '../ui/format.js';
import { useConsoleMeta, useNow, usePath, useStats } from '../ui/hooks.js';
import { Card, PageHeader, ProgressBar } from '../ui/primitives.jsx';

const WEEKS = 26;

const Tile = ({ icon: Icon, label, value, detail }) => (
    <Card className="p-4">
        <p className="flex items-center gap-1.5 font-mono text-xs text-muted"><Icon size={14} aria-hidden="true" className="text-amber" /> {label}</p>
        <p className="mt-1.5 font-display text-2xl font-semibold tracking-tight">{value}</p>
        {detail && <p className="mt-0.5 text-xs text-muted">{detail}</p>}
    </Card>
);

// Half a year of study days, a column per week like a contributions graph
const Heatmap = ({ days, minutesByDay, now }) => {
    const today = startOfDay(now);
    // Starts on the Sunday WEEKS - 1 weeks back, so each column is one Sunday-to-Saturday week
    const weekday = new Date(today).getDay();
    const firstDay = addDays(today, -weekday - (WEEKS - 1) * 7);
    const cells = Array.from({ length: (WEEKS - 1) * 7 + weekday + 1 }, (_, index) => addDays(firstDay, index));
    const level = (day) => {
        const key = dayKey(day);
        const minutes = minutesByDay[key] ?? 0;
        if (!days.has(key)) return 0;
        if (minutes >= 60) return 4;
        if (minutes >= 30) return 3;
        if (minutes >= 10) return 2;
        return 1;
    };
    const tones = ['bg-white/[0.06]', 'bg-amber/25', 'bg-amber/45', 'bg-amber/70', 'bg-amber'];
    return (
        <div className="overflow-x-auto pb-1">
            <div className="grid min-w-max grid-flow-col grid-rows-7 gap-1" role="img" aria-label={`${days.size} active days in the last ${WEEKS} weeks`}>
                {cells.map((day) => (
                    <span key={day} title={`${formatDate(day)}: ${formatMinutes(minutesByDay[dayKey(day)] ?? 0)}`} className={`h-3 w-3 rounded-[3px] ${tones[level(day)]}`} />
                ))}
            </div>
        </div>
    );
};

const ProgressPage = () => {
    const course = useCourse();
    const { lessons: allLessons, parts, DIFFICULTIES, practice: problems, links } = course;
    useConsoleMeta('Progress', links.progress);
    const state = useCourseStore();
    const path = usePath();
    const { xp, rank, streak, days } = useStats();
    const now = useNow();
    const minutesByDay = Object.fromEntries(Object.entries(state.activity).map(([day, record]) => [day, minutesOn(record)]));
    const totalMinutes = Object.values(minutesByDay).reduce((sum, value) => sum + value, 0);
    const pathProgress = completion(path, state.lessons);
    const solvedByDifficulty = Object.keys(DIFFICULTIES).map((key) => ({
        key,
        total: problems.filter((problem) => problem.difficulty === key).length,
        solved: problems.filter((problem) => problem.difficulty === key && state.problems[problem.id]?.status === 'solved').length,
    })).filter((entry) => entry.total > 0);
    const { goal } = useProfile();
    const mastery = masteryByPart({ lessons: state.lessons, problems: state.problems, goal }, course);
    const badges = badgesFor({ ...state, streak, bestStreak: longestStreak(days), goal }, course);
    const earnedCount = badges.filter((badge) => badge.isEarned).length;
    const answers = Object.values(state.lessons).flatMap((record) => Object.values(record.quiz ?? {}));
    const firstTry = answers.length ? answers.filter((answer) => answer.firstTry).length / answers.length : 0;

    return (
        <div className="mx-auto max-w-5xl">
            <PageHeader eyebrow={rank.title} title="Progress" />

            <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
                <Tile icon={Sparkles} label="Experience" value={`${xp.toLocaleString('en-GB')} XP`} detail={rank.next ? `${(rank.next.min - xp).toLocaleString('en-GB')} to ${rank.next.title}` : 'Top rank'} />
                <Tile icon={Flame} label="Streak" value={`${streak} day${streak === 1 ? '' : 's'}`} detail={`${days.size} active days in total`} />
                <Tile icon={Clock3} label="Time studied" value={formatMinutes(totalMinutes)} detail="Counted while you’re active" />
                <Tile icon={Target} label="First-try accuracy" value={`${Math.round(firstTry * 100)}%`} detail={`${answers.length} questions answered`} />
            </div>

            <Card className="mt-6 p-5">
                <h2 className="mb-4 flex items-center gap-2 font-semibold"><Radar size={17} aria-hidden="true" className="text-amber" /> Mastery by part</h2>
                <MasteryRadar entries={mastery} />
                <p className="mt-3 text-xs text-muted">Half lessons finished, a quarter first-try quiz accuracy, a quarter problems solved, counting your path only.</p>
            </Card>

            <Card className="mt-6 p-5">
                <h2 className="mb-4 flex items-center gap-2 font-semibold"><Award size={17} aria-hidden="true" className="text-amber" /> Badges <span className="font-mono text-xs font-normal text-muted">{earnedCount} of {badges.length}</span></h2>
                <ul className="grid gap-2 sm:grid-cols-2 lg:grid-cols-3">
                    {badges.map((badge) => (
                        <li key={badge.id} className={`flex items-start gap-3 rounded-xl border p-3 ${badge.isEarned ? 'border-amber/50 bg-amber/[0.07]' : 'border-line opacity-60'}`}>
                            {badge.isEarned ? <Award size={20} aria-hidden="true" className="mt-0.5 shrink-0 text-amber" /> : <Lock size={18} aria-hidden="true" className="mt-0.5 shrink-0 text-muted" />}
                            <span>
                                <span className="block text-sm font-semibold">{badge.title}<span className="sr-only">{badge.isEarned ? ' (earned)' : ' (locked)'}</span></span>
                                <span className="block text-xs text-muted">{badge.detail}</span>
                            </span>
                        </li>
                    ))}
                </ul>
            </Card>

            <Card className="mt-6 p-5">
                <h2 className="mb-4 font-semibold">Study days</h2>
                <Heatmap days={days} minutesByDay={minutesByDay} now={now} />
            </Card>

            <div className="mt-6 grid gap-6 lg:grid-cols-2">
                <Card className="p-5">
                    <h2 className="mb-1 font-semibold">Your path by part</h2>
                    <p className="mb-4 text-sm text-muted">{pathProgress.done} of {pathProgress.total} lessons on your path · {allLessons.filter((lesson) => state.lessons[lesson.id]?.completedAt).length} done overall</p>
                    <ul className="space-y-3">
                        {parts.map((part) => {
                            const partProgress = completion(path.filter((lesson) => lesson.part === part.number), state.lessons);
                            if (!partProgress.total) return null;
                            return (
                                <li key={part.number}>
                                    <div className="mb-1 flex justify-between gap-2 text-sm">
                                        <span className="truncate"><span className="font-mono text-xs text-muted">{part.number}</span> {part.title}</span>
                                        <span className="shrink-0 font-mono text-xs text-muted">{partProgress.done}/{partProgress.total}</span>
                                    </div>
                                    <ProgressBar value={partProgress.ratio} label={`${part.title} completion`} />
                                </li>
                            );
                        })}
                    </ul>
                </Card>

                <div className="space-y-6">
                    <Card className="p-5">
                        <h2 className="mb-4 flex items-center gap-2 font-semibold"><Code2 size={17} aria-hidden="true" className="text-amber" /> Problems solved</h2>
                        <ul className="space-y-3">
                            {solvedByDifficulty.map(({ key, total, solved }) => (
                                <li key={key}>
                                    <div className="mb-1 flex justify-between text-sm"><span>{DIFFICULTIES[key].label}</span><span className="font-mono text-xs text-muted">{solved}/{total}</span></div>
                                    <ProgressBar value={total ? solved / total : 0} label={`${DIFFICULTIES[key].label} problems solved`} />
                                </li>
                            ))}
                        </ul>
                    </Card>
                    <Card className="p-5">
                        <h2 className="mb-4 flex items-center gap-2 font-semibold"><Layers size={17} aria-hidden="true" className="text-amber" /> Ranks</h2>
                        <ol className="space-y-1.5 text-sm">
                            {RANKS.map((entry) => (
                                <li key={entry.title} className={`flex justify-between ${entry.title === rank.title ? 'font-semibold text-amber' : xp >= entry.min ? 'text-paper' : 'text-muted'}`}>
                                    <span>{entry.title}</span><span className="font-mono text-xs">{entry.min.toLocaleString('en-GB')} XP</span>
                                </li>
                            ))}
                        </ol>
                    </Card>
                </div>
            </div>
        </div>
    );
};

export default ProgressPage;
