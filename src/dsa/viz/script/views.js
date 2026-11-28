// Each scripted diagram's view, loaded the first time a lesson shows it (names match SCRIPT_NAMES in index.js)
export const SCRIPT_VISUALS = {
    flow: () => import('../views/FlowView.jsx'),
    sequence: () => import('../views/SequenceView.jsx'),
    states: () => import('../views/StatesView.jsx'),
    timeline: () => import('../views/TimelineView.jsx'),
};
