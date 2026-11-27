// Everything here is calculated from recorded facts (completions, attempts, reviews, minutes), never
// stored as counters, so two devices syncing after being offline can't lose each other's progress.
import { DIFFICULTIES, problemById } from '../data/problems.js';
import { addDays, dayKey } from './dates.js';

export const XP = { lesson: 50, firstTryAnswer: 10, review: 5, checkpoint: 200, mock: 50 };

export const RANKS = [
    { min: 0, title: 'Novice' },
    { min: 500, title: 'Apprentice' },
    { min: 2000, title: 'Practitioner' },
    { min: 6000, title: 'Specialist' },
    { min: 15000, title: 'Expert' },
    { min: 30000, title: 'Grandmaster' },
];

const problemXp = (id, record) => {
    const difficulty = DIFFICULTIES[problemById[id]?.difficulty];
    if (!difficulty || !record) return 0;
    if (record.status === 'solved') return difficulty.xp;
    if (record.status === 'helped') return Math.round(difficulty.xp / 2);
    return 0;
};

export const xpFrom = ({ lessons = {}, problems = {}, cards = {}, checkpoints = {}, mocks = {} }) => {
    const lessonXp = Object.values(lessons).reduce((sum, record) => {
        const answers = Object.values(record.quiz ?? {}).filter((answer) => answer.firstTry).length;
        return sum + (record.completedAt ? XP.lesson : 0) + answers * XP.firstTryAnswer;
    }, 0);
    const solvedXp = Object.entries(problems).reduce((sum, [id, record]) => sum + problemXp(id, record), 0);
    const reviewXp = Object.values(cards).reduce((sum, card) => sum + (card.reviews ?? 0) * XP.review, 0);
    const checkpointXp = Object.values(checkpoints).filter((record) => record.passedAt).length * XP.checkpoint;
    return lessonXp + solvedXp + reviewXp + checkpointXp + Object.keys(mocks).length * XP.mock;
};

export const rankFor = (xp) => {
    const index = RANKS.findLastIndex((rank) => xp >= rank.min);
    const current = RANKS[index];
    const next = RANKS[index + 1] ?? null;
    return {
        title: current.title,
        next,
        progress: next ? (xp - current.min) / (next.min - current.min) : 1,
    };
};

export const minutesOn = (record) => Object.values(record?.minutes ?? {}).reduce((sum, value) => sum + value, 0);

// Every day with any recorded learning
export const activeDays = ({ lessons = {}, problems = {}, cards = {}, activity = {}, checkpoints = {}, mocks = {} }) => {
    const days = new Set();
    const add = (ms) => ms && days.add(dayKey(ms));
    Object.values(lessons).forEach((record) => {
        add(record.completedAt);
        Object.values(record.quiz ?? {}).forEach((answer) => add(answer.at));
    });
    // Attempts are keyed by time, so two devices' attempts merge instead of replacing each other
    Object.values(problems).forEach((record) => Object.values(record.attempts ?? {}).forEach((attempt) => add(attempt.at)));
    Object.values(cards).forEach((card) => add(card.last));
    Object.values(checkpoints).forEach((record) => Object.values(record.attempts ?? {}).forEach((attempt) => add(attempt.at)));
    Object.values(mocks).forEach((record) => add(record.at));
    Object.entries(activity).forEach(([day, record]) => minutesOn(record) > 0 && days.add(day));
    return days;
};

// Consecutive active days up to today. A streak survives until the end of the day after the last one.
export const streakFrom = (days, now) => {
    let cursor = days.has(dayKey(now)) ? now : addDays(now, -1);
    let streak = 0;
    while (days.has(dayKey(cursor))) {
        streak += 1;
        cursor = addDays(cursor, -1);
    }
    return streak;
};
