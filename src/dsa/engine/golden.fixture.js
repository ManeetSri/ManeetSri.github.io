// A fixed learner built from the real DSA curriculum, and a summary of everything the engines derive from
// it. golden.test.js compares the summary with golden.expected.json, recorded before the console learned to
// host more than one course, so refactoring the engines can't quietly change what DSA shows.
import { dsaData } from '../data/courseData.js';
import { badgesFor, longestStreak, masteryByPart } from './badges.js';
import { addDays, dayKey } from './dates.js';
import { mockMistakes, problemMistakes, quizMistakes } from './mistakes.js';
import { completion, moduleCompletion, nextOnPath, pathFor, projection } from './path.js';
import { activeDays, rankFor, streakFrom, xpFrom } from './stats.js';
import { planToday } from './today.js';

const { GOALS, lessons: allLessons, modules, problemById } = dsaData;

// 27 November 2026, 10:00 in the local time zone (the test pins TZ)
export const NOW = new Date(2026, 10, 27, 10, 0, 0).getTime();

const at = (daysAgo, hour = 9) => addDays(NOW, -daysAgo) - (10 - hour) * 3_600_000;

export const buildFixture = () => {
    const path = pathFor('foundations', allLessons, GOALS);
    const lessons = {};
    const problems = {};
    const cards = {};

    // 40 lessons finished over the last 20 days, two a day, with a mix of first-try and missed answers
    path.slice(0, 40).forEach((lesson, index) => {
        const day = 20 - Math.floor(index / 2);
        lessons[lesson.id] = {
            openedAt: at(day, 8),
            completedAt: at(day, 9 + (index % 2)),
            quiz: {
                q1: { correct: true, firstTry: index % 3 !== 0, tries: index % 3 === 0 ? 2 : 1, at: at(day, 9) },
                q2: { correct: index % 5 !== 0, firstTry: index % 4 !== 0, tries: 1, at: at(day, 9) },
            },
        };
    });
    // Placement tested out of a few later lessons, and one is open but unfinished
    path.slice(45, 51).forEach((lesson) => {
        lessons[lesson.id] = { testedOutAt: at(30) };
    });
    lessons[path[40].id] = { openedAt: at(0, 8) };
    // A lesson that isn't in the curriculum any more must be ignored everywhere
    lessons['retired-lesson'] = { completedAt: at(3), quiz: { q1: { correct: false, firstTry: false, at: at(3) } } };

    // Problems from the finished lessons: solved, solved with help, attempted, and rated hard
    const practised = [...new Set(path.slice(0, 40).flatMap((lesson) => lesson.problems))].filter((id) => problemById[id]);
    practised.slice(0, 18).forEach((id, index) => {
        const status = ['solved', 'solved', 'helped', 'attempted', 'solved', 'solved'][index % 6];
        const rating = ['good', 'easy', 'hard', 'again', 'hard', 'good'][index % 6];
        const day = 18 - index;
        problems[id] = {
            status,
            attempts: { [at(day, 11)]: { at: at(day, 11), status, seconds: 600 + index * 30, rating } },
            ...(index % 4 === 0 ? { solution: 'func solve() {}', notes: 'Two pointers.' } : {}),
        };
        cards[`problem~${id}`] = { kind: 'problem', ref: id, ease: 2.5, interval: 3, reps: 1, lapses: 0, due: at(day - 3), last: at(day, 11), reviews: 1 };
    });
    problems['retired-problem'] = { status: 'solved', attempts: { [at(2)]: { at: at(2), status: 'solved', seconds: 60, rating: 'good' } } };

    // Flashcards and missed questions, some due today, some overdue, some later
    path.slice(0, 12).forEach((lesson, index) => {
        cards[`${lesson.id}~card~takeaway`] = { kind: 'card', lessonId: lesson.id, ref: 'takeaway', ease: 2.3 + index * 0.05, interval: index, reps: index % 3, lapses: index % 2, due: at(5 - index), last: index % 2 ? at(1, 20) : at(index + 1), reviews: index % 4 };
        if (index % 3 === 0) cards[`${lesson.id}~q~q1`] = { kind: 'question', lessonId: lesson.id, ref: 'q1', ease: 2.5, interval: 0, reps: 0, lapses: 1, due: at(index - 2), reviews: 0 };
    });

    const checkpoints = {
        [modules[0].id]: { attempts: { [at(15)]: { at: at(15), score: 11, total: 12, passed: true } }, passedAt: at(15) },
        [modules[1].id]: { attempts: { [at(6)]: { at: at(6), score: 7, total: 12, passed: false } } },
    };
    const mocks = {
        [at(4, 18)]: { at: at(4, 18), problemId: practised[0], seconds: 2400, status: 'solved', scores: { understanding: 4, approach: 3, correctness: 3, complexity: 4, communication: 3 } },
        [at(1, 18)]: { at: at(1, 18), problemId: practised[1], seconds: 2700, status: 'attempted', scores: { understanding: 2, approach: 2, correctness: 1, complexity: 2, communication: 3 } },
    };
    const activity = Object.fromEntries([0, 1, 2, 3, 5, 6, 7, 25].map((daysAgo) => [dayKey(at(daysAgo)), { minutes: { mac: 20 + daysAgo, phone: daysAgo % 2 ? 5 : 0 } }]));

    return { lessons, problems, cards, checkpoints, mocks, activity };
};

const ids = (list) => list.map((item) => item.id);
const round = (value) => Math.round(value * 1000) / 1000;

export const summarize = (state, now = NOW) => {
    const days = activeDays(state);
    const streak = streakFrom(days, now);
    const bestStreak = longestStreak(days);
    const byGoal = Object.fromEntries(Object.keys(GOALS).map((goal) => {
        const path = pathFor(goal, allLessons, GOALS);
        const plan = (minutesPerDay) => {
            const result = planToday({ path, lessons: state.lessons, problems: state.problems, cards: state.cards, minutesPerDay, now, practiceById: dsaData.practiceById, cardMinutes: {} });
            return {
                reviews: result.reviews,
                lessons: result.lessons.map((item) => [item.lesson.id, item.done]),
                practice: result.practice.map((item) => [item.problem.id, item.done]),
                comingSoon: result.comingSoon?.id ?? null,
                next: result.next?.id ?? null,
                plannedMinutes: result.plannedMinutes,
                budget: result.budget,
            };
        };
        const ahead = projection({ path, progress: state.lessons, minutesPerDay: 45, daysPerWeek: 5, now });
        return [goal, {
            path: { length: path.length, first: path[0]?.id, last: path.at(-1)?.id, sample: ids(path.filter((_, index) => index % 50 === 0)) },
            completion: completion(path, state.lessons),
            next: nextOnPath(path, state.lessons)?.id ?? null,
            projection: JSON.parse(JSON.stringify(ahead)),
            today30: plan(30),
            today90: plan(90),
            modules: modules.slice(0, 6).map((module) => [module.id, moduleCompletion(module, state.lessons, goal, GOALS)]),
            badges: badgesFor({ ...state, streak, bestStreak, goal }, dsaData).filter((badge) => badge.isEarned).map((badge) => badge.id),
            mastery: masteryByPart({ lessons: state.lessons, problems: state.problems, goal }, dsaData).map((part) => [part.part, round(part.value), part.lessons]),
        }];
    }));
    const xp = xpFrom(state, dsaData);
    return {
        xp,
        rank: { ...rankFor(xp), progress: round(rankFor(xp).progress) },
        days: [...days].sort(),
        streak,
        bestStreak,
        mistakes: {
            quiz: quizMistakes(state.lessons, Object.fromEntries(allLessons.map((lesson) => [lesson.id, lesson]))),
            problems: problemMistakes(state.problems, problemById),
            mocks: mockMistakes(state.mocks).map((mock) => [mock.at, round(mock.average), mock.weakest]),
        },
        byGoal,
    };
};
