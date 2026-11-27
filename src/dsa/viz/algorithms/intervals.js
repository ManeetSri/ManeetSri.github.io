// Interval programs for the intervals visualiser. Intervals are [start, end] pairs, as in the lessons.
// Each frame: { lanes: [{ label, each?, intervals: [{ start, end, tone }] }], cursor?, vars, line, message }.
// A lane with `each` draws one interval per row (so order shows); other lanes pack intervals into as few rows as fit.
// Tones: current, kept, removed, active, done, pending (or none).

const span = ([start, end], tone) => ({ start, end, tone });
const show = ([start, end]) => `[${start}, ${end}]`;

const merge = {
    title: 'Merging overlapping intervals',
    defaults: { intervals: [[8, 10], [1, 3], [2, 6], [15, 18], [6, 7], [17, 20]] },
    code: `func merge(_ intervals: [[Int]]) -> [[Int]] {
    let sorted = intervals.sorted { $0[0] < $1[0] }
    var merged: [[Int]] = []
    for interval in sorted {
        if let last = merged.last, interval[0] <= last[1] {
            merged[merged.count - 1][1] = max(last[1], interval[1])
        } else {
            merged.append(interval)
        }
    }
    return merged
}`,
    * run({ intervals }) {
        yield { lanes: [{ label: 'input', each: true, intervals: intervals.map((pair) => span(pair)) }], line: 1, message: `${intervals.length} intervals in no particular order. They're closed, so two that only touch, like [2, 6] and [6, 7], still overlap.` };
        const sorted = [...intervals].sort((a, b) => a[0] - b[0]);
        const merged = [];
        const lanes = (current, last) => [
            { label: 'sorted', each: true, intervals: sorted.map((pair, index) => span(pair, index === current ? 'current' : index < current ? 'done' : undefined)) },
            { label: 'merged', intervals: merged.map((pair, index) => span(pair, index === merged.length - 1 && last ? last : 'kept')) },
        ];
        yield { lanes: lanes(-1), line: 2, message: 'Sort by start. Now anything that overlaps the last merged interval comes straight after it, so one pass is enough.' };
        for (let index = 0; index < sorted.length; index += 1) {
            const [start, end] = sorted[index];
            const last = merged.at(-1);
            if (last && start <= last[1]) {
                const before = show(last);
                merged[merged.length - 1] = [last[0], Math.max(last[1], end)];
                yield { lanes: lanes(index, 'current'), vars: { merged: merged.length }, line: 6, message: `${show(sorted[index])} starts at ${start}, no later than ${before} ends: they overlap. ${end > last[1] ? `Stretch it to ${show(merged.at(-1))}.` : `It fits inside, so ${before} stays as it is.`}` };
            } else {
                merged.push([start, end]);
                yield { lanes: lanes(index, 'current'), vars: { merged: merged.length }, line: 8, message: last ? `${show(sorted[index])} starts after ${show(last)} ends at ${last[1]}: a gap, so it starts a new merged interval.` : `The first interval starts the merged list.` };
            }
        }
        yield { lanes: lanes(sorted.length), vars: { merged: merged.length }, line: 11, message: `Done: ${intervals.length} intervals became ${merged.length}. Sorting costs O(n log n) and the pass is O(n).` };
    },
};

const insert = {
    title: 'Inserting into sorted, non-overlapping intervals',
    defaults: { intervals: [[1, 2], [3, 5], [6, 7], [8, 10], [12, 16]], newInterval: [4, 8] },
    code: `func insert(_ intervals: [[Int]], _ newInterval: [Int]) -> [[Int]] {
    var result: [[Int]] = []
    var merged = newInterval
    var i = 0
    // 1. Everything that ends before the new interval starts
    while i < intervals.count && intervals[i][1] < merged[0] {
        result.append(intervals[i])
        i += 1
    }
    // 2. Everything that overlaps it gets absorbed
    while i < intervals.count && intervals[i][0] <= merged[1] {
        merged = [min(merged[0], intervals[i][0]), max(merged[1], intervals[i][1])]
        i += 1
    }
    result.append(merged)
    // 3. Everything after it
    while i < intervals.count {
        result.append(intervals[i])
        i += 1
    }
    return result
}`,
    * run({ intervals, newInterval }) {
        const result = [];
        let merged = [...newInterval];
        let placed = false;
        const lanes = (current, absorbed = []) => [
            { label: 'intervals', intervals: intervals.map((pair, index) => span(pair, index === current ? 'current' : absorbed.includes(index) ? 'removed' : index < current ? 'done' : undefined)) },
            ...(placed ? [] : [{ label: 'new', intervals: [span(merged, 'current')] }]),
            { label: 'result', intervals: result.map((pair) => span(pair, 'kept')) },
        ];
        yield { lanes: lanes(-1), line: 3, message: `The list is sorted and has no overlaps. Insert ${show(newInterval)} in one pass, in three phases, without sorting again.` };
        let i = 0;
        while (i < intervals.length && intervals[i][1] < merged[0]) {
            result.push(intervals[i]);
            yield { lanes: lanes(i), vars: { i }, line: 7, message: `${show(intervals[i])} ends at ${intervals[i][1]}, before ${merged[0]}: it comes first, unchanged.` };
            i += 1;
        }
        const absorbed = [];
        while (i < intervals.length && intervals[i][0] <= merged[1]) {
            const before = show(merged);
            merged = [Math.min(merged[0], intervals[i][0]), Math.max(merged[1], intervals[i][1])];
            absorbed.push(i);
            yield { lanes: lanes(i, absorbed), vars: { i }, line: 12, message: `${show(intervals[i])} starts at ${intervals[i][0]}, inside ${before}: absorb it, making ${show(merged)}.` };
            i += 1;
        }
        result.push(merged);
        placed = true;
        yield { lanes: lanes(i, absorbed), vars: { i }, line: 15, message: `${i < intervals.length ? `${show(intervals[i])} starts after ${merged[1]}, so nothing else overlaps.` : 'Nothing is left to overlap.'} Add the merged interval ${show(merged)}.` };
        while (i < intervals.length) {
            result.push(intervals[i]);
            yield { lanes: lanes(i, absorbed), vars: { i }, line: 18, message: `${show(intervals[i])} comes after: copy it over.` };
            i += 1;
        }
        yield { lanes: lanes(intervals.length, absorbed), vars: { i }, line: 21, message: `Done in O(n): ${result.length} interval${result.length === 1 ? '' : 's'}, still sorted and non-overlapping.` };
    },
};

const nonOverlapping = {
    title: 'Fewest removals: keep the interval that ends first',
    defaults: { intervals: [[1, 3], [2, 4], [3, 5], [1, 8], [6, 7], [5, 9]] },
    code: `func minRemovals(_ intervals: [[Int]]) -> Int {
    let sorted = intervals.sorted { $0[1] < $1[1] }
    var removals = 0
    var lastEnd = Int.min
    for interval in sorted {
        if interval[0] >= lastEnd {
            lastEnd = interval[1]
        } else {
            removals += 1
        }
    }
    return removals
}`,
    * run({ intervals }) {
        const sorted = [...intervals].sort((a, b) => a[1] - b[1]);
        const verdicts = [];
        let removals = 0;
        let lastEnd = null;
        const lanes = (current) => [{ label: 'sorted by end', each: true, intervals: sorted.map((pair, index) => span(pair, index === current ? (verdicts[index] === 'kept' ? 'current' : 'removed') : verdicts[index])) }];
        yield { lanes: [{ label: 'input', each: true, intervals: intervals.map((pair) => span(pair)) }], line: 1, message: 'Remove as few intervals as possible so the rest don’t overlap. Touching is fine: [1, 3] and [3, 5] can both stay.' };
        yield { lanes: lanes(-1), vars: { removals, lastEnd: '−∞' }, line: 2, message: 'Sort by end. The interval that ends first leaves the most room for everything after it, so it’s always safe to keep.' };
        for (let index = 0; index < sorted.length; index += 1) {
            const [start, end] = sorted[index];
            if (lastEnd === null || start >= lastEnd) {
                verdicts[index] = 'kept';
                const previous = lastEnd;
                lastEnd = end;
                yield { lanes: lanes(index), vars: { removals, lastEnd }, line: 7, message: previous === null ? `${show(sorted[index])} ends first: keep it.` : `${show(sorted[index])} starts at ${start}, at or after ${previous}: no overlap, keep it. lastEnd = ${end}.` };
            } else {
                verdicts[index] = 'removed';
                removals += 1;
                yield { lanes: lanes(index), vars: { removals, lastEnd }, line: 9, message: `${show(sorted[index])} starts at ${start}, before ${lastEnd}: it overlaps what we kept, and it ends later, so remove it.` };
            }
        }
        yield { lanes: lanes(sorted.length), vars: { removals, lastEnd }, line: 12, message: `${removals} removal${removals === 1 ? '' : 's'}; the ${sorted.length - removals} green intervals don’t overlap.` };
    },
};

// Rooms in use for half-open meetings, by sweeping +1/−1 events. The last frame shows a room for each meeting.
const meetingRooms = {
    title: 'Meeting rooms with a sweep line',
    defaults: { meetings: [[0, 30], [5, 10], [15, 20], [10, 15], [25, 35], [8, 12]] },
    code: `func minRooms(_ meetings: [[Int]]) -> Int {
    var events: [(time: Int, change: Int)] = []
    for meeting in meetings {
        events.append((meeting[0], 1))   // a meeting starts
        events.append((meeting[1], -1))  // a meeting ends
    }
    // At the same time, an end (-1) sorts before a start (+1)
    events.sort { ($0.time, $0.change) < ($1.time, $1.change) }
    var rooms = 0
    var most = 0
    for event in events {
        rooms += event.change
        most = max(most, rooms)
    }
    return most
}`,
    * run({ meetings }) {
        const events = meetings.flatMap(([start, end], index) => [{ time: start, change: 1, index }, { time: end, change: -1, index }])
            .sort((a, b) => a.time - b.time || a.change - b.change);
        const started = new Set();
        const ended = new Set();
        const lanes = (current) => [{
            label: 'meetings',
            each: true,
            intervals: meetings.map((pair, index) => span(pair, index === current ? 'current' : ended.has(index) ? 'done' : started.has(index) ? 'active' : undefined)),
        }];
        yield { lanes: lanes(-1), line: 1, message: 'Meetings are half-open: one that ends at 10 frees its room for one that starts at 10. How many rooms are needed at once?' };
        yield { lanes: lanes(-1), vars: { events: events.length }, line: 8, message: `Each meeting becomes two events: +1 when it starts, −1 when it ends. Sweep the ${events.length} events in time order.` };
        let rooms = 0;
        let most = 0;
        for (const [at, event] of events.entries()) {
            rooms += event.change;
            most = Math.max(most, rooms);
            (event.change === 1 ? started : ended).add(event.index);
            const meeting = show(meetings[event.index]);
            const tie = event.change === 1 && events[at - 1]?.time === event.time && events[at - 1].change === -1
                ? ' The end at the same time came first, so that room is reused.' : '';
            yield { lanes: lanes(event.index), cursor: event.time, vars: { rooms, most }, line: event.change === 1 ? 13 : 12, message: event.change === 1 ? `t = ${event.time}: ${meeting} starts. Rooms in use: ${rooms}${rooms === most ? ', the most so far' : ''}.${tie}` : `t = ${event.time}: ${meeting} ends and frees a room. Rooms in use: ${rooms}.` };
        }

        // Give each meeting the lowest-numbered room that's free when it starts
        const roomEnds = [];
        const assigned = meetings.map((pair, index) => ({ pair, index })).sort((a, b) => a.pair[0] - b.pair[0] || a.pair[1] - b.pair[1]).map(({ pair, index }) => {
            let room = roomEnds.findIndex((end) => end <= pair[0]);
            if (room === -1) room = roomEnds.length;
            roomEnds[room] = pair[1];
            return { pair, index, room };
        });
        const roomLanes = roomEnds.map((_, room) => ({ label: `room ${room + 1}`, intervals: assigned.filter((item) => item.room === room).map((item) => span(item.pair, 'kept')) }));
        yield { lanes: roomLanes, vars: { rooms, most }, line: 15, message: `${most} room${most === 1 ? '' : 's'}: the most meetings ever running at the same moment. Here's one way to fit them into ${most}.` };
    },
};

const intersections = {
    title: 'Intersecting two sorted interval lists',
    defaults: { a: [[0, 2], [5, 10], [13, 23], [24, 25]], b: [[1, 5], [8, 12], [15, 24], [25, 26]] },
    code: `func intersect(_ a: [[Int]], _ b: [[Int]]) -> [[Int]] {
    var result: [[Int]] = []
    var i = 0, j = 0
    while i < a.count && j < b.count {
        let start = max(a[i][0], b[j][0])
        let end = min(a[i][1], b[j][1])
        if start <= end { result.append([start, end]) }
        // The one that ends first can't overlap anything else
        if a[i][1] < b[j][1] { i += 1 } else { j += 1 }
    }
    return result
}`,
    * run({ a, b }) {
        const result = [];
        const lanes = (i, j, fresh) => [
            { label: 'a', intervals: a.map((pair, index) => span(pair, index === i ? 'current' : index < i ? 'done' : undefined)) },
            { label: 'b', intervals: b.map((pair, index) => span(pair, index === j ? 'current' : index < j ? 'done' : undefined)) },
            { label: 'a ∩ b', intervals: result.map((pair, index) => span(pair, fresh && index === result.length - 1 ? 'current' : 'kept')) },
        ];
        yield { lanes: lanes(-1, -1), line: 1, message: 'Both lists are sorted and have no overlaps within themselves. Walk them together with two pointers.' };
        let i = 0;
        let j = 0;
        while (i < a.length && j < b.length) {
            const start = Math.max(a[i][0], b[j][0]);
            const end = Math.min(a[i][1], b[j][1]);
            const overlap = start <= end;
            if (overlap) result.push([start, end]);
            yield { lanes: lanes(i, j, overlap), vars: { i, j, start, end }, line: 7, message: overlap ? `${show(a[i])} and ${show(b[j])} share [max of starts, min of ends] = ${show([start, end])}.` : `${show(a[i])} and ${show(b[j])}: the latest start ${start} is after the earliest end ${end}, so they don't meet.` };
            const moveA = a[i][1] < b[j][1];
            yield { lanes: lanes(i, j), vars: { i, j, start, end }, line: 9, message: moveA ? `${show(a[i])} ends first, at ${a[i][1]}. Nothing later in b can reach back to it, so move i on.` : `${show(b[j])} ends ${b[j][1] === a[i][1] ? 'at the same time' : 'first'}, at ${b[j][1]}. Move j on.` };
            if (moveA) i += 1; else j += 1;
        }
        yield { lanes: lanes(i, j), vars: { i, j }, line: 11, message: `One list is used up, so there's nothing left to intersect. ${result.length} overlaps, found in O(m + n).` };
    },
};

const PROGRAMS = { merge, insert, nonOverlapping, meetingRooms, intersections };

export const INTERVAL_PROGRAMS = Object.keys(PROGRAMS);

export const intervalProgram = (name) => {
    const program = PROGRAMS[name];
    if (!program) throw new Error(`Unknown intervals program "${name}" (known: ${INTERVAL_PROGRAMS.join(', ')})`);
    return program;
};

export const intervalFrames = (name, input = {}) => {
    const program = intervalProgram(name);
    return [...program.run({ ...program.defaults, ...input })];
};
