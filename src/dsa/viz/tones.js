// Colours the diagrams share. Plain values, so pure modules and schemas can use the names too.

// DSA graph nodes and edges
export const NODE_TONES = {
    idle: { fill: 'rgba(242,240,235,0.06)', stroke: 'rgba(242,240,235,0.35)', text: 'var(--color-paper)' },
    frontier: { fill: 'rgba(93,216,255,0.15)', stroke: '#5DD8FF', text: '#5DD8FF' },
    current: { fill: 'rgba(253,176,58,0.25)', stroke: 'var(--color-amber)', text: 'var(--color-amber)' },
    done: { fill: 'rgba(48,209,88,0.18)', stroke: '#30D158', text: '#9FE6B0' },
};
export const EDGE_TONES = { tree: '#30D158', used: 'var(--color-amber)', rejected: 'rgba(255,157,150,0.5)' };

// The scripted design diagrams: what a step's `state`, a timeline span's `tone` and the current
// highlight use. `bar` is the stronger fill for timeline spans.
export const TONE_NAMES = ['neutral', 'active', 'ok', 'error', 'wait'];
export const TONES = {
    neutral: { fill: 'rgba(242,240,235,0.05)', stroke: 'rgba(242,240,235,0.34)', text: 'var(--color-paper)', bar: 'rgba(242,240,235,0.22)' },
    active: { fill: 'rgba(253,176,58,0.18)', stroke: 'var(--color-amber)', text: 'var(--color-amber)', bar: 'rgba(253,176,58,0.55)' },
    ok: { fill: 'rgba(48,209,88,0.16)', stroke: '#30D158', text: '#9FE6B0', bar: 'rgba(48,209,88,0.5)' },
    error: { fill: 'rgba(255,157,150,0.15)', stroke: '#FF9D96', text: '#FF9D96', bar: 'rgba(255,157,150,0.5)' },
    wait: { fill: 'rgba(93,216,255,0.13)', stroke: '#5DD8FF', text: '#5DD8FF', bar: 'rgba(93,216,255,0.42)' },
};

// Lines and arrowheads in their resting and highlighted colours
export const LINE = 'rgba(242,240,235,0.4)';
export const LINE_ACTIVE = 'var(--color-amber)';
