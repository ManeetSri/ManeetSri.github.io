// The design course's data in one object, safe to import from Node (engines, tests and scripts)
import { GOALS, LEVELS, TRACKS, lessonById, lessons, moduleById, modules, modulesInPart, partByNumber, parts } from './curriculum.js';
import { DIFFICULTIES, KIND_LABELS, LISTS, practice, practiceById, problemById, problems, TOPICS } from './practice.js';
import { PLACEMENT_GROUPS } from './placement.js';

export const designData = {
    id: 'design',
    base: '/design',
    idPrefix: 'sd-',
    LEVELS,
    TRACKS,
    GOALS,
    defaultGoal: 'solid',
    parts,
    modules,
    lessons,
    moduleById,
    lessonById,
    partByNumber,
    modulesInPart,
    DIFFICULTIES,
    PATTERNS: TOPICS,
    LISTS,
    problems,
    problemById,
    practice,
    practiceById,
    kindLabels: KIND_LABELS,
    placement: PLACEMENT_GROUPS,
    partBadges: ['Ready to Design', 'Principled', 'Pattern Spotter', 'Platform Native', 'Architect in Training', 'Data Wrangler', 'Backend Fluent', 'Cross-cutting Pro', 'Ship It', 'Team Scaler', 'Interview Ready', 'Architect'],
};
