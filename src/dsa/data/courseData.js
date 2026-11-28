// The DSA course's data in one object, safe to import from Node (engines, tests and scripts use it).
// The engines take a course's data as an argument instead of importing it, so they serve every course.
import { GOALS, LEVELS, TRACKS, lessonById, lessons, moduleById, modules, modulesInPart, partByNumber, parts } from './curriculum.js';
import { DIFFICULTIES, LISTS, PATTERNS, problemById, problems } from './problems.js';
import { PLACEMENT_GROUPS } from './placement.js';

export const dsaData = {
    id: 'dsa',
    base: '/dsa',
    // Ids in this course carry no prefix: anything without another course's prefix belongs to DSA
    idPrefix: '',
    LEVELS,
    TRACKS,
    // The first goal is the default, and the fallback for a goal that no longer exists
    GOALS,
    defaultGoal: 'foundations',
    parts,
    modules,
    lessons,
    moduleById,
    lessonById,
    partByNumber,
    modulesInPart,
    DIFFICULTIES,
    PATTERNS,
    LISTS,
    problems,
    problemById,
    // Every practice item, whatever its kind. DSA only has coding problems.
    practice: problems,
    practiceById: problemById,
    placement: PLACEMENT_GROUPS,
    partBadges: ['Ready to Learn', 'Swift Speaker', 'Algorithmic Thinker', 'Pointer Pro', 'Sort Sorcerer', 'Tree Hugger', 'Graph Explorer', 'DP Wizard', 'Advanced Adventurer', 'Performance Pro', 'Interview Ready'],
};
