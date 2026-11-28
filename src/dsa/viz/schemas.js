// Build-time checks for visualisers whose props describe a whole diagram or simulation. The build plugin
// runs the schema for a ```visual block's name on its YAML; a schema returns true or a readable problem.
import { SCRIPT_SCHEMAS } from './script/index.js';
import { SIM_SCHEMAS } from './sims/index.js';

export const VISUAL_SCHEMAS = { ...SCRIPT_SCHEMAS, ...SIM_SCHEMAS };
