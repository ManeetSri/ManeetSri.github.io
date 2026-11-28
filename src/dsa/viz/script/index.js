// Author-scripted diagrams (flow, sequence, states, timeline): what a lesson describes in YAML, stepped
// through in the Player. Each name has a schema the build runs on the lesson's YAML, which returns true or a
// readable problem. The views are in views.js, so the build (which imports this file through names.js)
// never pulls in React components. Node-safe. src/dsa/design/content/AUTHORING.md documents the YAML.
import { checkFlow } from './flow.js';
import { checkSequence } from './sequence.js';
import { checkStates } from './states.js';
import { checkTimeline } from './timeline.js';

export const SCRIPT_SCHEMAS = {
    flow: checkFlow,
    sequence: checkSequence,
    states: checkStates,
    timeline: checkTimeline,
};

export const SCRIPT_NAMES = Object.keys(SCRIPT_SCHEMAS);
