import { projects } from './projects';

// Scroll budgets, in screen heights: the home screen before the first app opens,
// and how long each app takes to open from its icon and to close back into it
const HOME_UNITS = 0.7;
const LAUNCH_UNITS = 0.28;
const CLOSE_UNITS = 0.18;

export const totalUnits = projects.reduce((sum, project) => sum + project.units, HOME_UNITS);

export const LAUNCH = LAUNCH_UNITS / totalUnits;
export const CLOSE = CLOSE_UNITS / totalUnits;

// Each project's slice of the Work section's 0–1 scroll progress
export const segments = projects.reduce((list, project) => {
    const startUnits = list.length ? list[list.length - 1].endUnits : HOME_UNITS;
    const endUnits = startUnits + project.units;
    return [...list, { project, startUnits, endUnits, start: startUnits / totalUnits, end: endUnits / totalUnits }];
}, []);

export const activeIndexAt = (progress) =>
    segments.findIndex((segment) => progress >= segment.start && progress < segment.end);

// Centre of each home screen icon, so an app can launch from exactly where its icon sits
export const ICON_SIZE = 56;
export const iconPosition = (index) => ({
    x: 22 + (index % 4) * 66,
    y: 92 + Math.floor(index / 4) * 96,
});
