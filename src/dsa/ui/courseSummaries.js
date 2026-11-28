// Each course at a glance (path progress, due reviews, next lesson), and where you last were in it
import { useEffect, useMemo } from 'react';
import { useLocation } from 'react-router-dom';
import { useCourse } from '../course/context.js';
import { courseList } from '../course/courses.js';
import { filterState } from '../course/ownership.js';
import { courseProfile } from '../course/profile.js';
import { completion, nextOnPath, pathFor } from '../engine/path.js';
import { dueCards } from '../engine/srs.js';
import { useStore } from '../store/store.js';
import { useNow } from './hooks.js';

const LAST_PATH = 'maneet-console-last:';

export const readLastPath = (course) => {
    try {
        const saved = sessionStorage.getItem(LAST_PATH + course.id);
        return saved?.startsWith(`${course.base}/`) || saved === course.base ? saved : course.base;
    } catch {
        return course.base;
    }
};

// Remembers where you were in each course, so switching back returns you there
export const useRememberCoursePath = () => {
    const course = useCourse();
    const { pathname } = useLocation();
    useEffect(() => {
        try {
            sessionStorage.setItem(LAST_PATH + course.id, pathname);
        } catch {
            // Session storage is blocked: switching just opens the course's Today page
        }
    }, [course, pathname]);
};

// Progress on every course's path, and what's due there
export const useCourseSummaries = () => {
    const state = useStore();
    const now = useNow();
    return useMemo(() => courseList.map((course) => {
        const owned = filterState(state, course.id);
        const profile = courseProfile(state.meta.profile, course);
        const path = pathFor(profile.goal, course.lessons, course.GOALS);
        return {
            course,
            progress: completion(path, owned.lessons),
            due: dueCards(owned.cards, now).length,
            next: nextOnPath(path, owned.lessons),
        };
    }), [state, now]);
};
