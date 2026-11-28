// The learner's path: lessons in curriculum order (modules are listed after the modules they require),
// keeping the ones whose tracks match the chosen goal. Goals come from the course; its first goal is the
// fallback for one that no longer exists.

export const isOnPath = (lesson, goal, goals) => {
    const tracks = (goals[goal] ?? Object.values(goals)[0]).tracks;
    return lesson.tracks.some((track) => tracks.includes(track));
};

export const pathFor = (goal, lessons, goals) => lessons.filter((lesson) => isOnPath(lesson, goal, goals));

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

export const moduleCompletion = (module, progress, goal, goals) => completion(
    goal ? module.lessons.filter((lesson) => isOnPath(lesson, goal, goals)) : module.lessons,
    progress,
);

// Minutes of study left on the path, and the finish date at the learner's pace
export const projection = ({ path, progress, minutesPerDay, daysPerWeek, now }) => {
    const minutesLeft = path.filter((lesson) => !isDone(lesson.id, progress)).reduce((sum, lesson) => sum + lesson.minutes, 0);
    const minutesPerWeek = Math.max(1, minutesPerDay * daysPerWeek);
    const weeks = minutesLeft / minutesPerWeek;
    return { minutesLeft, weeks, finish: now + Math.ceil(weeks * 7) * 86_400_000 };
};
