import { useEffect, useMemo, useRef, useState } from 'react';
import { usePageMeta } from '../../hooks/usePageMeta';
import { useCourse } from '../course/context.js';
import { courseList } from '../course/courses.js';
import { filterState } from '../course/ownership.js';
import { pathFor } from '../engine/path.js';
import { activeDays, rankFor, streakFrom, xpFrom } from '../engine/stats.js';
import { useActions, useProfile, useStore } from '../store/store.js';

// Every console page is private: never indexed, and titled for the browser tab only
export const useConsoleMeta = (title, path) => {
    const course = useCourse();
    usePageMeta({
        title: title ? `${title} · ${course.title}` : course.title,
        description: 'Private learning console.',
        path: path ?? course.base,
        noindex: true,
    });
};

export const usePath = () => {
    const course = useCourse();
    const { goal } = useProfile();
    return useMemo(() => pathFor(goal, course.lessons, course.GOALS), [goal, course]);
};

// The current time, refreshed every so often, so "today" and "due" stay right on a page left open
export const useNow = (refreshMs = 60_000) => {
    const [now, setNow] = useState(() => Date.now());
    useEffect(() => {
        const refresh = () => setNow(Date.now());
        const timer = setInterval(refresh, refreshMs);
        window.addEventListener('focus', refresh);
        return () => {
            clearInterval(timer);
            window.removeEventListener('focus', refresh);
        };
    }, [refreshMs]);
    return now;
};

// XP and the streak cover every course: each course scores its own items, and any study day counts
export const useStats = () => {
    const state = useStore();
    const now = useNow();
    return useMemo(() => {
        const xp = courseList.reduce((sum, item) => sum + xpFrom(filterState(state, item.id), item), 0);
        const days = activeDays(state);
        return { xp, rank: rankFor(xp), days, streak: streakFrom(days, now) };
    }, [state, now]);
};

export const lessonContext = (lesson, course) => ({
    module: course.moduleById[lesson.module],
    part: course.partByNumber[lesson.part],
});

const IDLE_AFTER_MS = 3 * 60_000;
const TICK_MS = 60_000;
const ACTIVITY_EVENTS = ['pointerdown', 'keydown', 'scroll', 'touchstart'];

// Counts study minutes while the tab is visible and the learner has done something in the last few
// minutes, and records one minute at a time
export const useStudyTimer = () => {
    const { addMinutes } = useActions();
    const lastActivity = useRef(0);

    useEffect(() => {
        lastActivity.current = Date.now();
        const markActive = () => {
            lastActivity.current = Date.now();
        };
        ACTIVITY_EVENTS.forEach((name) => window.addEventListener(name, markActive, { passive: true }));
        const timer = setInterval(() => {
            const active = document.visibilityState === 'visible' && Date.now() - lastActivity.current < IDLE_AFTER_MS;
            if (active) addMinutes(1);
        }, TICK_MS);
        return () => {
            clearInterval(timer);
            ACTIVITY_EVENTS.forEach((name) => window.removeEventListener(name, markActive));
        };
    }, [addMinutes]);
};
