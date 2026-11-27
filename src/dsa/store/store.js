// The console's progress store. It mirrors every collection from the adapter (Firestore in production,
// localStorage in development) and exposes small actions that only ever record facts.
import { createContext, useContext, useSyncExternalStore } from 'react';
import { addDays, dayKey, startOfDay } from '../engine/dates.js';
import { newCard, reviewCard } from '../engine/srs.js';

export const COLLECTIONS = ['meta', 'lessons', 'problems', 'cards', 'notes', 'activity', 'checkpoints', 'mocks'];

export const DEFAULT_PROFILE = {
    goal: 'foundations',
    minutesPerDay: 45,
    daysPerWeek: 5,
    targetDate: null,
    textSize: 'normal',
};

const STATUS_RANK = { attempted: 1, helped: 2, solved: 3 };
const DEVICE_KEY = 'maneet-dsa-device';

// Each device writes only its own minutes, so two devices never overwrite each other
const deviceId = (() => {
    let id = null;
    return () => {
        if (id) return id;
        try {
            id = localStorage.getItem(DEVICE_KEY);
            if (!id) {
                id = Math.random().toString(36).slice(2, 10);
                localStorage.setItem(DEVICE_KEY, id);
            }
        } catch {
            id = 'session';
        }
        return id;
    };
})();

export const cardId = {
    takeaway: (lessonId, id) => `${lessonId}~card~${id}`,
    question: (lessonId, id) => `${lessonId}~q~${id}`,
    problem: (problemId) => `problem~${problemId}`,
};

export const createStore = (adapter) => {
    const loaded = new Set();
    const listeners = new Set();
    let state = {
        ready: false,
        sync: 'synced',
        ...Object.fromEntries(COLLECTIONS.map((name) => [name, {}])),
    };

    const update = (patch) => {
        state = { ...state, ...patch };
        listeners.forEach((listener) => listener());
    };

    const unsubscribers = COLLECTIONS.map((name) => adapter.subscribe(name, (docs) => {
        loaded.add(name);
        update({ [name]: docs, ready: loaded.size === COLLECTIONS.length });
    }));
    const stopStatus = adapter.onStatus((sync) => update({ sync }));

    const put = (name, id, patch) => adapter.put(name, id, patch).catch((error) => console.warn(`Couldn't save ${name}/${id}:`, error));
    const now = () => Date.now();

    const actions = {
        saveProfile: (patch) => put('meta', 'profile', patch),

        openLesson: (lessonId) => {
            if (!state.lessons[lessonId]?.openedAt) put('lessons', lessonId, { openedAt: now() });
        },

        // Finishing a lesson schedules its takeaways for their first review tomorrow
        completeLesson: (lessonId, takeaways = []) => {
            const time = now();
            put('lessons', lessonId, { completedAt: time });
            const tomorrow = startOfDay(addDays(time, 1));
            takeaways.forEach((card) => {
                const id = cardId.takeaway(lessonId, card.id);
                if (!state.cards[id]) put('cards', id, { ...newCard({ kind: 'takeaway', lessonId, ref: card.id }, time), due: tomorrow });
            });
        },

        reopenLesson: (lessonId) => put('lessons', lessonId, { completedAt: null, testedOutAt: null }),

        // Placement: lessons already known count as done on the path, but earn no XP
        testOut: (lessonIds) => {
            const time = now();
            lessonIds.forEach((lessonId) => {
                if (!state.lessons[lessonId]?.completedAt) put('lessons', lessonId, { testedOutAt: time });
            });
        },

        // A question missed on its first try becomes a review card
        recordAnswer: (lessonId, questionId, correct) => {
            const time = now();
            const previous = state.lessons[lessonId]?.quiz?.[questionId];
            put('lessons', lessonId, {
                quiz: {
                    [questionId]: {
                        correct,
                        firstTry: previous ? previous.firstTry : correct,
                        tries: (previous?.tries ?? 0) + 1,
                        at: time,
                    },
                },
            });
            const id = cardId.question(lessonId, questionId);
            if (!correct && !state.cards[id]) put('cards', id, newCard({ kind: 'question', lessonId, ref: questionId }, time));
        },

        toggleFlag: (name, id, flag) => put(name, id, { [flag]: !state[name][id]?.[flag] }),

        saveNote: (lessonId, text) => put('notes', lessonId, { text, updatedAt: now() }),

        // Attempts are keyed by time, so attempts made on two devices merge instead of replacing each other.
        // The rating schedules the next re-solve.
        logAttempt: (problemId, { status, seconds, rating }) => {
            const time = now();
            const record = state.problems[problemId];
            const best = STATUS_RANK[status] > (STATUS_RANK[record?.status] ?? 0) ? status : record.status;
            put('problems', problemId, { status: best, attempts: { [time]: { at: time, status, seconds, rating } } });
            const id = cardId.problem(problemId);
            const card = state.cards[id] ?? newCard({ kind: 'problem', ref: problemId }, time);
            put('cards', id, reviewCard(card, rating, time));
        },

        saveProblemText: (problemId, field, text) => put('problems', problemId, { [field]: text, updatedAt: now() }),

        review: (id, rating) => put('cards', id, reviewCard(state.cards[id], rating, now())),

        // Every attempt is kept, keyed by time. The first pass marks the module mastered.
        recordCheckpoint: (moduleId, { score, total, passed }) => {
            const time = now();
            const alreadyPassed = Boolean(state.checkpoints[moduleId]?.passedAt);
            put('checkpoints', moduleId, {
                attempts: { [time]: { at: time, score, total, passed } },
                ...(passed && !alreadyPassed ? { passedAt: time } : {}),
            });
        },

        // A mock interview keeps its rubric, and also counts as an attempt at the problem
        recordMock: ({ problemId, seconds, status, scores, notes }) => {
            const time = now();
            const average = Object.values(scores).reduce((sum, value) => sum + value, 0) / Math.max(1, Object.values(scores).length);
            const rating = status === 'attempted' || average < 2 ? 'again' : average < 2.75 ? 'hard' : average < 3.5 ? 'good' : 'easy';
            put('mocks', String(time), { at: time, problemId, seconds, status, scores, notes });
            actions.logAttempt(problemId, { status, seconds, rating });
        },

        addMinutes: (minutes) => {
            const day = dayKey(now());
            const device = deviceId();
            const current = state.activity[day]?.minutes?.[device] ?? 0;
            put('activity', day, { minutes: { [device]: current + minutes } });
        },

        importAll: async (data) => {
            const writes = COLLECTIONS.flatMap((name) => Object.entries(data[name] ?? {}).map(([id, value]) => adapter.put(name, id, value)));
            await Promise.all(writes);
        },

        resetAll: async () => {
            const removals = COLLECTIONS.flatMap((name) => Object.keys(state[name]).map((id) => adapter.remove(name, id)));
            await Promise.all(removals);
        },
    };

    return {
        getState: () => state,
        subscribe: (listener) => {
            listeners.add(listener);
            return () => listeners.delete(listener);
        },
        actions,
        destroy: () => {
            unsubscribers.forEach((unsubscribe) => unsubscribe());
            stopStatus();
            adapter.destroy();
        },
    };
};

export const StoreContext = createContext(null);

export const useStore = () => {
    const store = useContext(StoreContext);
    return useSyncExternalStore(store.subscribe, store.getState);
};

export const useActions = () => useContext(StoreContext).actions;

export const useProfile = () => {
    const { meta } = useStore();
    return { ...DEFAULT_PROFILE, ...meta.profile };
};
