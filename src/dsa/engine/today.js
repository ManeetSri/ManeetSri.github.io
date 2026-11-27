// Today's plan, sized to the learner's daily minutes: due reviews first (up to about 30% of the time),
// then the next lessons on the path, then practice on what was learned recently. Items finished today
// stay in the plan, ticked, so the plan doesn't reshuffle as you work through it.
import { problemById } from '../data/problems.js';
import { isSameDay } from './dates.js';
import { isDone, nextOnPath } from './path.js';
import { dueCards } from './srs.js';

const REVIEW_SHARE = 0.3;
const MINUTES_PER_REVIEW = 1;
const MAX_PRACTICE = 3;

// Attempts are stored keyed by time: { [at]: { at, status, … } }
const solvedToday = (record, now) => Object.values(record?.attempts ?? {}).some((attempt) => attempt.status === 'solved' && isSameDay(attempt.at, now));

export const planToday = ({ path, lessons = {}, problems = {}, cards = {}, minutesPerDay, now }) => {
    const reviewedToday = Object.values(cards).filter((card) => card.last && isSameDay(card.last, now)).length;
    const due = dueCards(cards, now);
    const reviewSlots = Math.max(0, Math.floor((minutesPerDay * REVIEW_SHARE) / MINUTES_PER_REVIEW) - reviewedToday);
    const reviewCount = Math.min(due.length, reviewSlots);
    let minutesLeft = minutesPerDay - (reviewCount + reviewedToday) * MINUTES_PER_REVIEW;

    // Lessons finished today, then new ones while they fit. There's always at least one if any is left.
    const finishedToday = path.filter((lesson) => lessons[lesson.id]?.completedAt && isSameDay(lessons[lesson.id].completedAt, now));
    minutesLeft -= finishedToday.reduce((sum, lesson) => sum + lesson.minutes, 0);
    const upcoming = [];
    let comingSoon = null;
    for (const lesson of path) {
        if (isDone(lesson.id, lessons)) continue;
        if (lesson.status === 'stub') {
            comingSoon = lesson;
            break;
        }
        const nothingPlanned = finishedToday.length === 0 && upcoming.length === 0;
        if (!nothingPlanned && lesson.minutes > minutesLeft) break;
        upcoming.push(lesson);
        minutesLeft -= lesson.minutes;
    }

    // Practice: problems from lessons done or planned today, then the most recently finished lessons
    const recentLessons = [...finishedToday, ...upcoming, ...path
        .filter((lesson) => isDone(lesson.id, lessons))
        .sort((a, b) => lessons[b.id].completedAt - lessons[a.id].completedAt)];
    const practice = [];
    const seen = new Set();
    for (const lesson of recentLessons) {
        for (const id of lesson.problems) {
            const problem = problemById[id];
            if (!problem || seen.has(id) || practice.length >= MAX_PRACTICE) continue;
            seen.add(id);
            const done = solvedToday(problems[id], now);
            if (problems[id]?.status === 'solved' && !done) continue;
            if (!done && practice.length > 0 && problem.minutes > minutesLeft) continue;
            practice.push({ problem, done });
            if (!done) minutesLeft -= problem.minutes;
        }
    }

    return {
        reviews: { due: due.length, planned: reviewCount, doneToday: reviewedToday },
        lessons: [
            ...finishedToday.map((lesson) => ({ lesson, done: true })),
            ...upcoming.map((lesson) => ({ lesson, done: false })),
        ],
        practice,
        comingSoon,
        next: nextOnPath(path, lessons),
        plannedMinutes: minutesPerDay - Math.max(0, minutesLeft),
        budget: minutesPerDay,
    };
};
