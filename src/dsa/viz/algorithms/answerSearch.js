// Binary search on the answer: candidates on a number line, the predicate's verdicts, and the check for `mid`.
// Each frame: { range: { min, max }, low, high, mid?, check?: { kind, groups, total, limit, ok }, vars, line, message }.
// Candidates below `low` are known to fail, candidates from `high` up are known to work (high always works here).

const speed = {
    title: 'Binary search on the answer: the slowest speed that finishes in time',
    defaults: { piles: [5, 9, 4, 12], hours: 7 },
    code: `func hoursNeeded(_ piles: [Int], speed: Int) -> Int {
    var hours = 0
    for pile in piles {
        hours += (pile + speed - 1) / speed
    }
    return hours
}

func minimumSpeed(_ piles: [Int], hours h: Int) -> Int {
    var low = 1
    var high = piles.max()!              // always fast enough, because h >= piles.count
    while low < high {
        let mid = low + (high - low) / 2
        let needed = hoursNeeded(piles, speed: mid)
        if needed <= h {
            high = mid                   // fast enough: the answer is mid or slower
        } else {
            low = mid + 1                // too slow
        }
    }
    return low
}`,
    lines: { start: 11, check: 14, works: 16, fails: 18, done: 21 },
    unit: 'speed',
    bounds: ({ piles }) => ({ low: 1, high: Math.max(...piles) }),
    check: ({ piles, hours }, mid) => {
        const groups = piles.map((pile) => ({ label: `${pile}`, value: Math.ceil(pile / mid), detail: `⌈${pile}/${mid}⌉` }));
        const total = groups.reduce((sum, group) => sum + group.value, 0);
        return { kind: 'hours', groups, total, limit: hours, ok: total <= hours };
    },
    describe: (mid, { total, limit, ok }) => `Speed ${mid} needs ${total} hour${total === 1 ? '' : 's'}${ok ? `, within ${limit}: fast enough, so the answer is ${mid} or slower.` : `, more than ${limit}: too slow, and so is every slower speed.`}`,
    intro: ({ hours }, low, high) => `Speeds ${low}…${high} are the candidates. Speed ${high}, the largest pile, finishes each pile in an hour, so it always works. Find the first speed that fits in ${hours} hours.`,
};

const capacity = {
    title: 'Binary search on the answer: the smallest capacity that ships in time',
    defaults: { weights: [6, 2, 9, 3, 5, 4, 8], days: 4 },
    code: `func daysNeeded(_ weights: [Int], capacity: Int) -> Int {
    var days = 1
    var load = 0
    for weight in weights {
        if load + weight > capacity {
            days += 1
            load = 0
        }
        load += weight
    }
    return days
}

func shipWithin(_ weights: [Int], days: Int) -> Int {
    var low = weights.max()!                 // anything less can't carry the heaviest package
    var high = weights.reduce(0, +)          // one day carries everything
    while low < high {
        let mid = low + (high - low) / 2
        if daysNeeded(weights, capacity: mid) <= days {
            high = mid
        } else {
            low = mid + 1
        }
    }
    return low
}`,
    lines: { start: 16, check: 19, works: 20, fails: 22, done: 25 },
    unit: 'capacity',
    bounds: ({ weights }) => ({ low: Math.max(...weights), high: weights.reduce((sum, weight) => sum + weight, 0) }),
    check: ({ weights, days }, mid) => {
        const groups = [];
        let load = [];
        weights.forEach((weight) => {
            const sum = load.reduce((total, value) => total + value, 0);
            if (sum + weight > mid) {
                groups.push(load);
                load = [];
            }
            load.push(weight);
        });
        groups.push(load);
        const shaped = groups.map((group, index) => ({ label: `day ${index + 1}`, value: group.reduce((total, value) => total + value, 0), detail: group.join(' + ') }));
        return { kind: 'days', groups: shaped, total: shaped.length, limit: days, ok: shaped.length <= days };
    },
    describe: (mid, { total, limit, ok }) => `Capacity ${mid} needs ${total} day${total === 1 ? '' : 's'}${ok ? `, within ${limit}: big enough, so the answer is ${mid} or smaller.` : `, more than ${limit}: too small, and so is every smaller capacity.`}`,
    intro: ({ days }, low, high) => `Capacities ${low}…${high} are the candidates: below ${low} the heaviest package never fits, and ${high} ships everything in one day. Find the first capacity that needs at most ${days} days.`,
};

const PROGRAMS = { speed, capacity };

export const ANSWER_SEARCH_PROGRAMS = Object.keys(PROGRAMS);

export const answerSearchProgram = (name) => {
    const program = PROGRAMS[name];
    if (!program) throw new Error(`Unknown answerSearch program "${name}" (known: ${ANSWER_SEARCH_PROGRAMS.join(', ')})`);
    return program;
};

export const answerSearchFrames = (name, input = {}) => {
    const program = answerSearchProgram(name);
    const data = { ...program.defaults, ...input };
    let { low, high } = program.bounds(data);
    const range = { min: low, max: high };
    const { lines, unit } = program;
    let checks = 0;
    const frames = [{ range, low, high, vars: { low, high, checks }, line: lines.start, message: program.intro(data, low, high) }];
    while (low < high) {
        const mid = low + Math.floor((high - low) / 2);
        const check = program.check(data, mid);
        checks += 1;
        frames.push({ range, low, high, mid, check, vars: { low, mid, high, checks }, line: lines.check, message: program.describe(mid, check) });
        if (check.ok) high = mid; else low = mid + 1;
        frames.push({ range, low, high, mid, check, vars: { low, high, checks }, line: check.ok ? lines.works : lines.fails, message: check.ok ? `high = ${mid}. Everything from ${mid} up works.` : `low = ${mid + 1}. Everything below ${mid + 1} fails.` });
    }
    frames.push({ range, low, high, answer: low, vars: { answer: low, checks }, line: lines.done, message: `low meets high: ${low} is the smallest ${unit} that works. ${checks} check${checks === 1 ? '' : 's'} instead of trying all ${range.max - range.min + 1} candidates.` });
    return frames;
};
