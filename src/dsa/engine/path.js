// The learner's path: lessons in curriculum order (modules are listed after the modules they require),
// keeping the ones whose tracks match the chosen goal.
import { GOALS, lessons as allLessons } from '../data/curriculum.js';

export const DEFAULT_GOAL = 'foundations';

export const isOnPath = (lesson, goal = DEFAULT_GOAL) => {
    const tracks = (GOALS[goal] ?? GOALS[DEFAULT_GOAL]).tracks;
    return lesson.tracks.some((track) => tracks.includes(track));
};

export const pathFor = (goal, lessons = allLessons) => lessons.filter((lesson) => isOnPath(lesson, goal));

// A lesson is done once it's completed, or tested out of in the placement check
export const isDone = (lessonId, progress) => Boolean(progress[lessonId]?.completedAt || progress[lessonId]?.testedOutAt);

export const lessonState = (lesson, progress) => {
    if (progress[lesson.id]?.completedAt) return 'done';
    if (progress[lesson.id]?.testedOutAt) return 'skipped';
    if (progress[lesson.id]?.openedAt) return 'started';
    return lesson.status === 'stub' ? 'stub' : 'todo';
};

// The first unfinished lesson on the path, even if its content isn't written yet
export const nextOnPath = (path, progress) => path.find((lesson) => !isDone(lesson.id, progress)) ?? null;

export const completion = (lessons, progress) => {
    const done = lessons.filter((lesson) => isDone(lesson.id, progress)).length;
    return { done, total: lessons.length, ratio: lessons.length ? done / lessons.length : 0 };
};

export const moduleCompletion = (module, progress, goal) => completion(
    goal ? module.lessons.filter((lesson) => isOnPath(lesson, goal)) : module.lessons,
    progress,
);

// Minutes of study left on the path, and the finish date at the learner's pace
export const projection = ({ path, progress, minutesPerDay, daysPerWeek, now }) => {
    const minutesLeft = path.filter((lesson) => !isDone(lesson.id, progress)).reduce((sum, lesson) => sum + lesson.minutes, 0);
    const minutesPerWeek = Math.max(1, minutesPerDay * daysPerWeek);
    const weeks = minutesLeft / minutesPerWeek;
    return { minutesLeft, weeks, finish: now + Math.ceil(weeks * 7) * 86_400_000 };
};
