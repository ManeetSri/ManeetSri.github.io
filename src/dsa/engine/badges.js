// Badges and per-part mastery, worked out from recorded facts like everything else in stats.js.
import { lessons as allLessons, parts } from '../data/curriculum.js';
import { problems as allProblems } from '../data/problems.js';
import { isDone, isOnPath } from './path.js';

const PART_BADGES = ['Ready to Learn', 'Swift Speaker', 'Algorithmic Thinker', 'Pointer Pro', 'Sort Sorcerer', 'Tree Hugger', 'Graph Explorer', 'DP Wizard', 'Advanced Adventurer', 'Performance Pro', 'Interview Ready'];

// Only parts whose lessons are written can be completed
const writtenOnPath = (part, goal) => allLessons.filter((lesson) => lesson.part === part && lesson.status === 'ready' && isOnPath(lesson, goal));

export const BADGES = [
    ...parts.map((part) => ({
        id: `part-${part.number}`,
        title: PART_BADGES[part.number],
        detail: `Finish every lesson on your path in Part ${part.number}: ${part.title}.`,
        earned: ({ lessons, goal }) => {
            const list = writtenOnPath(part.number, goal);
            const whole = allLessons.filter((lesson) => lesson.part === part.number);
            return list.length > 0 && list.length === whole.filter((lesson) => isOnPath(lesson, goal)).length && list.every((lesson) => isDone(lesson.id, lessons));
        },
    })),
    { id: 'streak-7', title: 'Week Warrior', detail: 'Study 7 days in a row.', earned: ({ streak, bestStreak }) => Math.max(streak, bestStreak) >= 7 },
    { id: 'streak-30', title: 'Monthly Habit', detail: 'Study 30 days in a row.', earned: ({ streak, bestStreak }) => Math.max(streak, bestStreak) >= 30 },
    { id: 'streak-100', title: 'Centurion', detail: 'Study 100 days in a row.', earned: ({ streak, bestStreak }) => Math.max(streak, bestStreak) >= 100 },
    ...[10, 50, 100, 250].map((count) => ({
        id: `solved-${count}`,
        title: { 10: 'Problem Solver', 50: 'Half Century', 100: 'Centurion Coder', 250: 'Problem Machine' }[count],
        detail: `Solve ${count} practice problems.`,
        earned: ({ problems }) => Object.values(problems).filter((record) => record.status === 'solved').length >= count,
    })),
    { id: 'checkpoint-1', title: 'Checkpoint Champion', detail: 'Pass your first module checkpoint.', earned: ({ checkpoints }) => Object.values(checkpoints).some((record) => record.passedAt) },
    { id: 'checkpoint-10', title: 'Module Master', detail: 'Pass 10 module checkpoints.', earned: ({ checkpoints }) => Object.values(checkpoints).filter((record) => record.passedAt).length >= 10 },
    { id: 'mock-1', title: 'Under Pressure', detail: 'Finish a mock interview.', earned: ({ mocks }) => Object.keys(mocks).length > 0 },
    { id: 'reviews-100', title: 'Memory Keeper', detail: 'Complete 100 reviews.', earned: ({ cards }) => Object.values(cards).reduce((sum, card) => sum + (card.reviews ?? 0), 0) >= 100 },
];

export const badgesFor = (facts) => BADGES.map((badge) => ({ ...badge, isEarned: badge.earned({ lessons: {}, problems: {}, cards: {}, checkpoints: {}, mocks: {}, streak: 0, bestStreak: 0, goal: 'foundations', ...facts }) }));

// The longest run of consecutive days in a set of "yyyy-mm-dd" keys
export const longestStreak = (days) => {
    const sorted = [...days].sort();
    let best = 0;
    let run = 0;
    let previous = null;
    sorted.forEach((day) => {
        const time = new Date(`${day}T12:00:00`).getTime();
        run = previous !== null && Math.round((time - previous) / 86_400_000) === 1 ? run + 1 : 1;
        best = Math.max(best, run);
        previous = time;
    });
    return best;
};

// Mastery from 0 to 1 for each part: half lessons finished, a quarter first-try quiz accuracy, a quarter problems solved
export const masteryByPart = ({ lessons = {}, problems = {}, goal = 'foundations' }) => parts.filter((part) => part.number > 0).map((part) => {
    const onPath = allLessons.filter((lesson) => lesson.part === part.number && isOnPath(lesson, goal));
    const done = onPath.filter((lesson) => isDone(lesson.id, lessons)).length;
    const lessonShare = onPath.length ? done / onPath.length : 0;
    const answers = onPath.flatMap((lesson) => Object.values(lessons[lesson.id]?.quiz ?? {}));
    const accuracy = answers.length ? answers.filter((answer) => answer.firstTry).length / answers.length : lessonShare;
    const lessonIds = new Set(onPath.map((lesson) => lesson.id));
    const partProblems = allProblems.filter((problem) => problem.lessons.some((id) => lessonIds.has(id)));
    const solved = partProblems.length ? partProblems.filter((problem) => problems[problem.id]?.status === 'solved').length / partProblems.length : lessonShare;
    return { part: part.number, title: part.title, value: 0.5 * lessonShare + 0.25 * accuracy + 0.25 * solved, lessons: { done, total: onPath.length } };
});
