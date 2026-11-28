import { createElement } from 'react';

// SVG pieces the diagrams share: an arrowhead marker, and the geometry that makes a line start and end
// at the border of the shapes it joins. Points are { x, y }; rectangles are { x, y, w, h } (top left).

export const ARROW_PATH = 'M0,0 L10,5 L0,10 z';
const OPEN_ARROW_PATH = 'M1,1 L10,5 L1,9';

// Put inside <defs>, then draw a line with markerEnd={`url(#${id})`}. `open` draws a stick arrowhead.
export const ArrowMarker = ({ id, fill = 'rgba(242,240,235,0.55)', refX = 10, size = 7, open = false }) => createElement(
    'marker',
    { id, viewBox: '0 0 10 10', refX, refY: 5, markerWidth: size, markerHeight: size, orient: 'auto-start-reverse' },
    open
        ? createElement('path', { d: OPEN_ARROW_PATH, fill: 'none', stroke: fill, strokeWidth: 1.6, strokeLinecap: 'round', strokeLinejoin: 'round' })
        : createElement('path', { d: ARROW_PATH, fill }),
);

// The point `radius` along the line from a circle's centre toward another point
export const clipCircle = (center, toward, radius) => {
    const length = Math.hypot(toward.x - center.x, toward.y - center.y);
    if (!length) return { x: center.x, y: center.y };
    return { x: center.x + ((toward.x - center.x) / length) * radius, y: center.y + ((toward.y - center.y) / length) * radius };
};

export const rectCenter = (rect) => ({ x: rect.x + rect.w / 2, y: rect.y + rect.h / 2 });

// Where a ray from `from` (inside the rectangle) toward `toward` leaves it, pushed `gap` further out
export const exitRect = (rect, from, toward, gap = 0) => {
    const dx = toward.x - from.x;
    const dy = toward.y - from.y;
    const length = Math.hypot(dx, dy);
    if (!length) return { x: from.x, y: from.y };
    const ux = dx / length;
    const uy = dy / length;
    const tx = ux > 0 ? (rect.x + rect.w - from.x) / ux : ux < 0 ? (rect.x - from.x) / ux : Infinity;
    const ty = uy > 0 ? (rect.y + rect.h - from.y) / uy : uy < 0 ? (rect.y - from.y) / uy : Infinity;
    const t = Math.max(0, Math.min(tx, ty)) + gap;
    return { x: from.x + ux * t, y: from.y + uy * t };
};

// The unit normal of the direction a → b: a quarter turn clockwise on screen (y points down)
export const normal = (a, b) => {
    const length = Math.hypot(b.x - a.x, b.y - a.y) || 1;
    return { x: -(b.y - a.y) / length, y: (b.x - a.x) / length };
};

// A straight edge between two rectangles, clipped to their borders. `offset` slides it sideways, so two
// opposite edges between the same pair (each offset along its own normal) sit side by side.
export const segmentBetweenRects = (a, b, { offset = 0, gapStart = 2, gapEnd = 2 } = {}) => {
    const ca = rectCenter(a);
    const cb = rectCenter(b);
    const n = normal(ca, cb);
    const pa = { x: ca.x + n.x * offset, y: ca.y + n.y * offset };
    const pb = { x: cb.x + n.x * offset, y: cb.y + n.y * offset };
    const start = exitRect(a, pa, pb, gapStart);
    const end = exitRect(b, pb, pa, gapEnd);
    return { start, end, mid: { x: (start.x + end.x) / 2, y: (start.y + end.y) / 2 }, normal: n, d: `M ${round(start.x)} ${round(start.y)} L ${round(end.x)} ${round(end.y)}` };
};

// A quadratic arc between two rectangles, bowing `bend` along the normal of a → b
export const arcBetweenRects = (a, b, bend, { gapStart = 2, gapEnd = 2 } = {}) => {
    const ca = rectCenter(a);
    const cb = rectCenter(b);
    const n = normal(ca, cb);
    const control = { x: (ca.x + cb.x) / 2 + n.x * bend * 2, y: (ca.y + cb.y) / 2 + n.y * bend * 2 };
    const start = exitRect(a, ca, control, gapStart);
    const end = exitRect(b, cb, control, gapEnd);
    // The curve's midpoint, which is where its label goes
    const mid = { x: 0.25 * start.x + 0.5 * control.x + 0.25 * end.x, y: 0.25 * start.y + 0.5 * control.y + 0.25 * end.y };
    return { start, end, control, mid, normal: n, d: `M ${round(start.x)} ${round(start.y)} Q ${round(control.x)} ${round(control.y)} ${round(end.x)} ${round(end.y)}` };
};

// A loop that leaves and re-enters one side of a rectangle: 'top', 'bottom', 'left' or 'right'
export const selfLoop = (rect, side = 'top', { reach = 40, spread = 15, gap = 2 } = {}) => {
    const { x: cx, y: cy } = rectCenter(rect);
    const geometry = {
        top: { start: { x: cx - spread, y: rect.y - gap }, end: { x: cx + spread, y: rect.y - gap }, out: { x: 0, y: -1 } },
        bottom: { start: { x: cx + spread, y: rect.y + rect.h + gap }, end: { x: cx - spread, y: rect.y + rect.h + gap }, out: { x: 0, y: 1 } },
        right: { start: { x: rect.x + rect.w + gap, y: cy - spread * 0.7 }, end: { x: rect.x + rect.w + gap, y: cy + spread * 0.7 }, out: { x: 1, y: 0 } },
        left: { start: { x: rect.x - gap, y: cy + spread * 0.7 }, end: { x: rect.x - gap, y: cy - spread * 0.7 }, out: { x: -1, y: 0 } },
    }[side];
    const { start, end, out } = geometry;
    // Control points reach out and splay sideways, so the loop is a rounded teardrop
    const side1 = { x: start.x + out.x * reach + (start.x - end.x) * 0.9, y: start.y + out.y * reach + (start.y - end.y) * 0.9 };
    const side2 = { x: end.x + out.x * reach + (end.x - start.x) * 0.9, y: end.y + out.y * reach + (end.y - start.y) * 0.9 };
    const apex = { x: (start.x + end.x) / 2 + out.x * reach * 0.75, y: (start.y + end.y) / 2 + out.y * reach * 0.75 };
    return {
        start, end, apex, out,
        d: `M ${round(start.x)} ${round(start.y)} C ${round(side1.x)} ${round(side1.y)} ${round(side2.x)} ${round(side2.y)} ${round(end.x)} ${round(end.y)}`,
    };
};

const round = (value) => Math.round(value * 10) / 10;

// The point a fraction t along a straight segment, or along a quadratic curve through `control`
export const pointAt = ({ start, end, control }, t) => (control
    ? { x: (1 - t) ** 2 * start.x + 2 * (1 - t) * t * control.x + t ** 2 * end.x, y: (1 - t) ** 2 * start.y + 2 * (1 - t) * t * control.y + t ** 2 * end.y }
    : { x: start.x + (end.x - start.x) * t, y: start.y + (end.y - start.y) * t });

// How much two rectangles overlap, as an area
export const overlapArea = (a, b) => Math.max(0, Math.min(a.x + a.w, b.x + b.w) - Math.max(a.x, b.x)) * Math.max(0, Math.min(a.y + a.h, b.y + b.h) - Math.max(a.y, b.y));

// Picks the first spot where a w × h label overlaps none of the obstacles, or else the least-covered one
export const placeLabel = (spots, size, obstacles) => {
    let best = null;
    for (const spot of spots) {
        const box = { x: spot.x - size.w / 2, y: spot.y - size.h / 2, w: size.w, h: size.h };
        const cost = obstacles.reduce((sum, obstacle) => sum + overlapArea(box, obstacle), 0);
        if (cost === 0) return { x: spot.x, y: spot.y };
        if (!best || cost < best.cost) best = { x: spot.x, y: spot.y, cost };
    }
    return best && { x: best.x, y: best.y };
};

// Diagram text is short, so widths are estimated rather than measured: JetBrains Mono's advance is
// 0.6em, and the sans face averages a little less.
export const textWidth = (text, fontSize, mono = true) => String(text ?? '').length * fontSize * (mono ? 0.6 : 0.56);

// Breaks text into lines of at most `limit` characters, at spaces where it can
export const wrapText = (text, limit) => {
    const lines = [];
    String(text ?? '').split('\n').forEach((paragraph) => {
        let line = '';
        paragraph.split(/\s+/).filter(Boolean).forEach((word) => {
            let rest = word;
            while (rest.length > limit) {
                if (line) { lines.push(line); line = ''; }
                lines.push(rest.slice(0, limit));
                rest = rest.slice(limit);
            }
            if (!line) line = rest;
            else if (line.length + 1 + rest.length <= limit) line = `${line} ${rest}`;
            else { lines.push(line); line = rest; }
        });
        lines.push(line);
    });
    return lines;
};

// Shortens text to fit `limit` characters, ending with an ellipsis
export const truncate = (text, limit) => {
    const value = String(text ?? '');
    if (value.length <= limit) return value;
    return limit <= 1 ? '…' : `${value.slice(0, limit - 1)}…`;
};
