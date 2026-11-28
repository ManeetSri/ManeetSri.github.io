// Today's plan, sized to the learner's daily minutes: due reviews first (up to about 30% of the time),
// then the next lessons on the path, then practice on what was learned recently. Items finished today
// stay in the plan, ticked, so the plan doesn't reshuffle as you work through it.
import { isSameDay } from './dates.js';
import { isDone, nextOnPath } from './path.js';
import { dueCards } from './srs.js';

const REVIEW_SHARE = 0.3;
const MAX_PRACTICE = 3;

// Attempts are stored keyed by time: { [at]: { at, status, … } }
const solvedToday = (record, now) => Object.values(record?.attempts ?? {}).some((attempt) => attempt.status === 'solved' && isSameDay(attempt.at, now));

// `practiceById` is the course's practice items, whatever their kind. A review takes a minute unless the
// course says a kind of card takes longer (`cardMinutes`): recalling a whole design takes more than a fact.
export const planToday = ({ path, lessons = {}, problems = {}, cards = {}, minutesPerDay, now, practiceById, cardMinutes = {} }) => {
    const minutesFor = (card) => cardMinutes[card.kind] ?? 1;
    const reviewedTodayCards = Object.values(cards).filter((card) => card.last && isSameDay(card.last, now));
    const reviewedToday = reviewedTodayCards.length;
    const reviewedMinutes = reviewedTodayCards.reduce((sum, card) => sum + minutesFor(card), 0);
    const due = dueCards(cards, now);
    let reviewBudget = Math.floor(minutesPerDay * REVIEW_SHARE) - reviewedMinutes;
    let reviewCount = 0;
    let reviewMinutes = 0;
    for (const card of due) {
        if (minutesFor(card) > reviewBudget) break;
        reviewBudget -= minutesFor(card);
        reviewMinutes += minutesFor(card);
        reviewCount += 1;
    }
    let minutesLeft = minutesPerDay - reviewMinutes - reviewedMinutes;

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
            const problem = practiceById[id];
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
