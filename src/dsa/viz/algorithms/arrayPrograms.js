import { SORT_PROGRAMS } from './sortPrograms.js';

// Array algorithms as frames for the arrayTrace visualiser. Each frame holds one or more rows
// ({ label, values, pointers: { name: index }, range: { from, to }, marks: { index: tone } }), the
// variables, an optional stack, the Swift line and a message. `null` values draw as empty slots.

const row = (label, values, extra = {}) => ({ label, values: [...values], pointers: {}, marks: {}, range: null, ...extra });

const PROGRAMS = {
    reverse: {
        title: 'Reversing in place with two pointers',
        defaults: { items: [1, 2, 3, 4, 5, 6] },
        code: `func reverse(_ items: inout [Int]) {
    var left = 0
    var right = items.count - 1
    while left < right {
        items.swapAt(left, right)
        left += 1
        right -= 1
    }
}`,
        * run({ items }) {
            const values = [...items];
            let left = 0;
            let right = values.length - 1;
            const frame = (line, message, marks = {}) => ({ rows: [row('items', values, { pointers: { left, right }, marks })], vars: { left, right }, line, message });
            yield frame(3, `Start with left at the first index and right at the last (${right}).`);
            while (left < right) {
                yield frame(4, `left (${left}) < right (${right}), so there's still a pair to swap.`);
                [values[left], values[right]] = [values[right], values[left]];
                yield frame(5, `Swap items[${left}] and items[${right}].`, { [left]: 'swap', [right]: 'swap' });
                left += 1;
                right -= 1;
                yield frame(7, 'Move both pointers one step towards the middle.');
            }
            yield frame(4, `left (${left}) is no longer < right (${right}): every pair is swapped. Done in ${Math.floor(items.length / 2)} swaps.`);
        },
        result: ({ items }) => [...items].reverse(),
    },
    pairSum: {
        title: 'Pair with a target sum in a sorted array',
        defaults: { items: [1, 3, 4, 6, 8, 11, 14], target: 14 },
        code: `func pairWithSum(_ items: [Int], _ target: Int) -> (Int, Int)? {
    var left = 0
    var right = items.count - 1
    while left < right {
        let sum = items[left] + items[right]
        if sum == target {
            return (left, right)
        } else if sum < target {
            left += 1
        } else {
            right -= 1
        }
    }
    return nil
}`,
        * run({ items, target }) {
            let left = 0;
            let right = items.length - 1;
            const frame = (line, message, extra = {}) => ({ rows: [row('items', items, { pointers: { left, right }, ...extra })], vars: { left, right, target, ...(extra.sum !== undefined ? { sum: extra.sum } : {}) }, line, message });
            yield frame(3, `Pointers at both ends. We want two values adding up to ${target}.`);
            while (left < right) {
                const sum = items[left] + items[right];
                if (sum === target) {
                    yield frame(7, `${items[left]} + ${items[right]} = ${target}. Found the pair at indexes ${left} and ${right}.`, { sum, marks: { [left]: 'found', [right]: 'found' } });
                    return;
                }
                if (sum < target) {
                    yield frame(9, `${items[left]} + ${items[right]} = ${sum}, too small. Only a bigger left value can help, so move left right.`, { sum });
                    left += 1;
                } else {
                    yield frame(11, `${items[left]} + ${items[right]} = ${sum}, too big. Only a smaller right value can help, so move right left.`, { sum });
                    right -= 1;
                }
            }
            yield frame(14, 'The pointers met: no pair adds up to the target.');
        },
    },
    dedupe: {
        title: 'Removing duplicates with read and write pointers',
        defaults: { items: [1, 1, 2, 2, 2, 3, 5, 5] },
        code: `func removeDuplicates(_ items: inout [Int]) -> Int {
    guard !items.isEmpty else { return 0 }
    var write = 1
    for read in 1..<items.count {
        if items[read] != items[write - 1] {
            items[write] = items[read]
            write += 1
        }
    }
    return write
}`,
        * run({ items }) {
            const values = [...items];
            let write = 1;
            const frame = (line, message, read, marks = {}) => ({
                rows: [row('items', values, { pointers: read === undefined ? { write } : { read, write }, range: { from: 0, to: write - 1, tone: 'kept' }, marks })],
                vars: read === undefined ? { write } : { read, write },
                line,
                message,
            });
            yield frame(3, 'The first element is always kept, so writing starts at index 1.');
            for (let read = 1; read < values.length; read += 1) {
                if (values[read] !== values[write - 1]) {
                    values[write] = values[read];
                    yield frame(6, `${values[read]} is new: copy it to index ${write}.`, read, { [write]: 'swap' });
                    write += 1;
                } else {
                    yield frame(5, `${values[read]} repeats the last kept value: skip it.`, read);
                }
            }
            yield frame(10, `The first ${write} elements are the unique values. Return ${write}.`);
        },
    },
    dutchFlag: {
        title: 'Sorting 0s, 1s and 2s in one pass',
        defaults: { items: [2, 0, 2, 1, 1, 0, 1, 2, 0] },
        code: `func sortColors(_ items: inout [Int]) {
    var low = 0
    var mid = 0
    var high = items.count - 1
    while mid <= high {
        if items[mid] == 0 {
            items.swapAt(low, mid)
            low += 1
            mid += 1
        } else if items[mid] == 1 {
            mid += 1
        } else {
            items.swapAt(mid, high)
            high -= 1
        }
    }
}`,
        * run({ items }) {
            const values = [...items];
            let low = 0;
            let mid = 0;
            let high = values.length - 1;
            const frame = (line, message, marks = {}) => ({ rows: [row('items', values, { pointers: { low, mid, high }, marks })], vars: { low, mid, high }, line, message });
            yield frame(4, 'Everything before low is 0, before mid is 1, after high is 2. In between is unknown.');
            while (mid <= high) {
                if (values[mid] === 0) {
                    [values[low], values[mid]] = [values[mid], values[low]];
                    yield frame(7, 'items[mid] is 0: swap it to the low region.', { [low]: 'swap', [mid]: 'swap' });
                    low += 1;
                    mid += 1;
                } else if (values[mid] === 1) {
                    yield frame(11, 'items[mid] is 1: it’s already in the middle region.');
                    mid += 1;
                } else {
                    [values[mid], values[high]] = [values[high], values[mid]];
                    yield frame(13, 'items[mid] is 2: swap it to the high region. Don’t move mid: the value that came back is unknown.', { [mid]: 'swap', [high]: 'swap' });
                    high -= 1;
                }
            }
            yield frame(5, 'mid passed high: nothing is unknown any more. Sorted in one pass.');
        },
        result: ({ items }) => [...items].sort((a, b) => a - b),
    },
    maxSumFixed: {
        title: 'Largest sum of k neighbours with a sliding window',
        defaults: { items: [2, 1, 5, 1, 3, 2, 7, 1], k: 3 },
        code: `func maxWindowSum(_ items: [Int], _ k: Int) -> Int {
    var windowSum = items[0..<k].reduce(0, +)
    var best = windowSum
    for right in k..<items.count {
        windowSum += items[right] - items[right - k]
        best = max(best, windowSum)
    }
    return best
}`,
        * run({ items, k }) {
            let windowSum = items.slice(0, k).reduce((a, b) => a + b, 0);
            let best = windowSum;
            yield { rows: [row('items', items, { range: { from: 0, to: k - 1, tone: 'window' } })], vars: { windowSum, best }, line: 3, message: `The first window (indexes 0–${k - 1}) sums to ${windowSum}.` };
            for (let right = k; right < items.length; right += 1) {
                windowSum += items[right] - items[right - k];
                best = Math.max(best, windowSum);
                yield {
                    rows: [row('items', items, { pointers: { right }, range: { from: right - k + 1, to: right, tone: 'window' }, marks: { [right - k]: 'out' } })],
                    vars: { windowSum, best },
                    line: 5,
                    message: `Slide: add ${items[right]}, drop ${items[right - k]}. Window sum ${windowSum}, best ${best}. One add and one subtract, not a full re-sum.`,
                };
            }
            yield { rows: [row('items', items)], vars: { best }, line: 7, message: `Return ${best}.` };
        },
    },
    shortestWindow: {
        title: 'Shortest window with a sum of at least the target',
        defaults: { items: [2, 3, 1, 2, 4, 3], target: 7 },
        code: `func shortestWindow(_ items: [Int], atLeast target: Int) -> Int {
    var left = 0
    var sum = 0
    var best = Int.max
    for right in 0..<items.count {
        sum += items[right]
        while sum >= target {
            best = min(best, right - left + 1)
            sum -= items[left]
            left += 1
        }
    }
    return best == Int.max ? 0 : best
}`,
        * run({ items, target }) {
            let left = 0;
            let sum = 0;
            let best = Infinity;
            const frame = (line, message, right) => ({
                rows: [row('items', items, { pointers: right === undefined ? {} : { left, right }, range: right === undefined || left > right ? null : { from: left, to: right, tone: 'window' } })],
                vars: { left, sum, best: best === Infinity ? 'none' : best },
                line,
                message,
            });
            yield frame(4, `Grow the window to the right until its sum reaches ${target}, then shrink it from the left.`);
            for (let right = 0; right < items.length; right += 1) {
                sum += items[right];
                yield frame(6, `Add ${items[right]}: window sum ${sum}.`, right);
                while (sum >= target) {
                    best = Math.min(best, right - left + 1);
                    yield frame(8, `${sum} ≥ ${target}: a window of length ${right - left + 1}. Best so far ${best}.`, right);
                    sum -= items[left];
                    left += 1;
                    yield frame(10, `Shrink from the left: the sum drops to ${sum}.`, right);
                }
            }
            yield frame(13, `Every window was tried. The shortest has length ${best === Infinity ? 0 : best}.`);
        },
    },
    longestUnique: {
        title: 'Longest run of characters with no repeats',
        defaults: { text: 'abcabcbb' },
        code: `func longestUniqueRun(_ text: String) -> Int {
    let chars = Array(text)
    var seen = Set<Character>()
    var left = 0
    var best = 0
    for right in 0..<chars.count {
        while seen.contains(chars[right]) {
            seen.remove(chars[left])
            left += 1
        }
        seen.insert(chars[right])
        best = max(best, right - left + 1)
    }
    return best
}`,
        * run({ text }) {
            const chars = [...text];
            const seen = new Set();
            let left = 0;
            let best = 0;
            const frame = (line, message, right, marks = {}) => ({
                rows: [row('chars', chars, { pointers: right === undefined ? {} : { left, right }, range: right === undefined || left > right ? null : { from: left, to: right, tone: 'window' }, marks })],
                vars: { seen: `{${[...seen].sort().join(', ')}}`, best },
                line,
                message,
            });
            yield frame(5, 'The window holds characters with no repeats. The set remembers what’s inside it.');
            for (let right = 0; right < chars.length; right += 1) {
                while (seen.has(chars[right])) {
                    seen.delete(chars[left]);
                    yield frame(8, `“${chars[right]}” is already in the window. Drop “${chars[left]}” from the left.`, right, { [right]: 'out' });
                    left += 1;
                }
                seen.add(chars[right]);
                best = Math.max(best, right - left + 1);
                yield frame(12, `Add “${chars[right]}”. Window length ${right - left + 1}, best ${best}.`, right);
            }
            yield frame(14, `Return ${best}.`);
        },
    },
    prefixSum: {
        title: 'Building prefix sums, then answering a range query',
        defaults: { items: [3, 1, 4, 1, 5, 9, 2], query: [2, 5] },
        code: `func prefixSums(_ items: [Int]) -> [Int] {
    var prefix = [0]
    for value in items {
        prefix.append(prefix.last! + value)
    }
    return prefix
}

// The sum of items[i...j] is prefix[j + 1] - prefix[i]`,
        // run is defined below the table: it builds rows in a plain loop
    },
    kadane: {
        title: 'Kadane’s maximum subarray',
        defaults: { items: [-2, 1, -3, 4, -1, 2, 1, -5, 4] },
        code: `func maxSubarraySum(_ items: [Int]) -> Int {
    var current = items[0]
    var best = items[0]
    for value in items.dropFirst() {
        current = max(value, current + value)
        best = max(best, current)
    }
    return best
}`,
        * run({ items }) {
            let current = items[0];
            let best = items[0];
            let start = 0;
            let bestRange = { from: 0, to: 0 };
            yield { rows: [row('items', items, { range: { from: 0, to: 0, tone: 'window' } })], vars: { current, best }, line: 3, message: `Start: the best subarray so far is just [${items[0]}].` };
            for (let index = 1; index < items.length; index += 1) {
                const value = items[index];
                const restart = value > current + value;
                current = restart ? value : current + value;
                if (restart) start = index;
                if (current > best) {
                    best = current;
                    bestRange = { from: start, to: index };
                }
                yield {
                    rows: [row('items', items, { pointers: { i: index }, range: { from: start, to: index, tone: 'window' }, marks: Object.fromEntries(Array.from({ length: bestRange.to - bestRange.from + 1 }, (_, k) => [bestRange.from + k, 'found'])) })],
                    vars: { current, best },
                    line: 5,
                    message: restart
                        ? `${value} on its own beats extending a negative run: start a new subarray here. current = ${current}, best = ${best}.`
                        : `Extend the run with ${value}: current = ${current}, best = ${best}.`,
                };
            }
            yield { rows: [row('items', items, { range: { ...bestRange, tone: 'window' } })], vars: { best }, line: 7, message: `The best subarray is indexes ${bestRange.from}–${bestRange.to}, summing to ${best}.` };
        },
    },
    dynamicAppend: {
        title: 'Appending to a dynamic array that doubles its capacity',
        defaults: { count: 9, capacity: 1 },
        code: `mutating func append(_ value: Int) {
    if count == capacity {
        let newCapacity = max(1, capacity * 2)
        var newBuffer = [Int?](repeating: nil, count: newCapacity)
        for i in 0..<count {
            newBuffer[i] = buffer[i]
        }
        buffer = newBuffer
        capacity = newCapacity
    }
    buffer[count] = value
    count += 1
}`,
        * run({ count: appends, capacity: startCapacity }) {
            let capacity = startCapacity;
            let buffer = Array(capacity).fill(null);
            let count = 0;
            let copies = 0;
            for (let value = 1; value <= appends; value += 1) {
                if (count === capacity) {
                    const newCapacity = Math.max(1, capacity * 2);
                    const newBuffer = Array(newCapacity).fill(null);
                    for (let i = 0; i < count; i += 1) newBuffer[i] = buffer[i];
                    copies += count;
                    yield {
                        rows: [row(`buffer (capacity ${capacity})`, buffer), row(`new buffer (capacity ${newCapacity})`, newBuffer, { marks: Object.fromEntries(Array.from({ length: count }, (_, i) => [i, 'swap'])) })],
                        vars: { count, capacity: newCapacity, copies },
                        line: 6,
                        message: `Full! Allocate ${newCapacity} slots and copy all ${count} elements. Copies so far: ${copies}.`,
                    };
                    buffer = newBuffer;
                    capacity = newCapacity;
                }
                buffer[count] = value;
                count += 1;
                yield {
                    rows: [row(`buffer (capacity ${capacity})`, buffer, { marks: { [count - 1]: 'found' } })],
                    vars: { count, capacity, copies },
                    line: 11,
                    message: `Append ${value}. ${count} appends have cost ${copies} copies, ${(copies / count).toFixed(2)} per append.`,
                };
            }
            yield { rows: [row(`buffer (capacity ${capacity})`, buffer)], vars: { count, capacity, copies }, line: 12, message: `${count} appends, ${copies} copies in total: ${(copies / count).toFixed(2)} per append. With doubling, the copies always stay below 2 × the appends, however many you add: amortised O(1) per append.` };
        },
    },
    nextGreater: {
        title: 'Next greater element with a monotonic stack',
        defaults: { items: [2, 7, 3, 5, 4, 6, 8] },
        code: `func nextGreater(_ items: [Int]) -> [Int] {
    var result = Array(repeating: -1, count: items.count)
    var stack: [Int] = []   // indexes still waiting for a bigger value
    for i in 0..<items.count {
        while let top = stack.last, items[top] < items[i] {
            result[top] = items[i]
            stack.removeLast()
        }
        stack.append(i)
    }
    return result
}`,
        * run({ items }) {
            const result = Array(items.length).fill(-1);
            const stack = [];
            const frame = (line, message, i, marks = {}) => ({
                rows: [row('items', items, { pointers: i === undefined ? {} : { i }, marks }), row('result', result)],
                stack: stack.map((index) => `${items[index]} (index ${index})`),
                vars: {},
                line,
                message,
            });
            yield frame(3, 'The stack holds indexes still waiting for a bigger value. Their values only go down from bottom to top.');
            for (let i = 0; i < items.length; i += 1) {
                while (stack.length && items[stack.at(-1)] < items[i]) {
                    const top = stack.pop();
                    result[top] = items[i];
                    yield frame(6, `${items[i]} is bigger than ${items[top]} on top of the stack: it’s ${items[top]}’s next greater element. Pop it.`, i, { [top]: 'found' });
                }
                stack.push(i);
                yield frame(9, `Push index ${i} (${items[i]}): it waits for something bigger.`, i);
            }
            yield frame(11, `Whatever is left on the stack never found anything bigger, so it stays -1. Each index is pushed and popped at most once: O(n).`);
        },
    },
};

// Sliding window maximum with a monotonic deque, matching the queue-monotonic-deque lesson
PROGRAMS.windowMax = {
    title: 'Sliding window maximum with a monotonic deque',
    defaults: { items: [4, 2, 12, 3, 1, 8, 5], k: 3 },
    code: `func windowMaxima(_ values: [Int], k: Int) -> [Int] {
    var result: [Int] = []
    var window: [Int] = []       // indexes; their values decrease from window[head] to the end
    var head = 0
    for i in values.indices {
        if head < window.count && window[head] <= i - k {
            head += 1
        }
        while head < window.count && values[window[window.count - 1]] <= values[i] {
            window.removeLast()
        }
        window.append(i)
        if i >= k - 1 {
            result.append(values[window[head]])
        }
    }
    return result
}`,
    * run({ items, k }) {
        const result = [];
        const deque = [];
        const frame = (line, message, i, marks = {}) => ({
            rows: [row('values', items, { pointers: i === undefined ? {} : { i }, range: i === undefined ? null : { from: Math.max(0, i - k + 1), to: i, tone: 'window' }, marks }), row('maxima', [...result, ...Array(Math.max(0, items.length - k + 1 - result.length)).fill(null)])],
            list: { title: 'deque, front first (indexes → values)', items: deque.map((index) => `${index}→${items[index]}`) },
            vars: {},
            line,
            message,
        });
        yield frame(3, `The deque keeps indexes whose values decrease from front to back. The front is always the window's maximum. k = ${k}.`);
        for (let i = 0; i < items.length; i += 1) {
            if (deque.length && deque[0] <= i - k) {
                const expired = deque.shift();
                yield frame(7, `Index ${expired} (${items[expired]}) has slid out of the window: drop it from the front.`, i, { [expired]: 'out' });
            }
            while (deque.length && items[deque.at(-1)] <= items[i]) {
                const popped = deque.pop();
                yield frame(10, `${items[popped]} ≤ ${items[i]}: it can never be a maximum again. Pop it from the back.`, i, { [popped]: 'out' });
            }
            deque.push(i);
            if (i >= k - 1) result.push(items[deque[0]]);
            yield frame(i >= k - 1 ? 14 : 12, i >= k - 1 ? `Push index ${i}. Window ${i - k + 1}–${i} has maximum ${items[deque[0]]}, at the front.` : `Push index ${i}. The first window isn't full yet.`, i, { [deque[0]]: 'found' });
        }
        yield frame(17, `Maxima: ${result.join(', ')}. Each index is pushed and popped at most once: O(n).`);
    },
};

// A fixed-capacity ring buffer that refuses new values when full, matching the queue-ring-buffer lesson
PROGRAMS.ringBuffer = {
    title: 'A ring buffer wrapping round',
    defaults: { capacity: 4, operations: ['enqueue 1', 'enqueue 2', 'enqueue 3', 'dequeue', 'dequeue', 'enqueue 4', 'enqueue 5', 'enqueue 6', 'enqueue 7'] },
    code: `mutating func enqueue(_ value: Int) -> Bool {
    guard !isFull else { return false }          // full: refuse
    slots[(head + count) % capacity] = value     // the slot right after the back
    count += 1
    return true
}

mutating func dequeue() -> Int? {
    guard count > 0 else { return nil }
    let value = slots[head]
    slots[head] = nil
    head = (head + 1) % capacity                 // wraps from the last slot to 0
    count -= 1
    return value
}`,
    * run({ capacity, operations }) {
        const slots = Array(capacity).fill(null);
        let head = 0;
        let count = 0;
        const frame = (line, message, marks = {}) => ({
            rows: [row('slots', slots, { pointers: { head, next: (head + count) % capacity }, marks })],
            vars: { head, count },
            line,
            message,
        });
        yield frame(1, `${capacity} slots in a circle. head is the oldest value; next is (head + count) % ${capacity}, where the next value goes.`);
        for (const operation of operations) {
            const [op, arg] = operation.trim().split(/\s+/);
            if (op === 'enqueue') {
                const value = Number(arg);
                if (count === capacity) {
                    yield frame(2, `enqueue(${value}): the ring is full, so it's refused (returns false).`);
                    continue;
                }
                const slot = (head + count) % capacity;
                slots[slot] = value;
                count += 1;
                yield frame(3, `enqueue(${value}) goes into slot (${head} + ${count - 1}) % ${capacity} = ${slot}.`, { [slot]: 'found' });
            } else {
                if (count === 0) {
                    yield frame(9, 'dequeue() on an empty ring returns nil.');
                    continue;
                }
                const value = slots[head];
                const from = head;
                slots[head] = null;
                head = (head + 1) % capacity;
                count -= 1;
                yield frame(12, `dequeue() returns ${value} from slot ${from}; head moves to ${head}${from === capacity - 1 ? ', wrapping round to the start' : ''}.`, { [from]: 'out' });
            }
        }
        yield frame(14, 'No element ever moved: only head and count changed. Every operation is O(1).');
    },
};

// Container with most water, drawn as bars, matching the tp-container-water lesson
PROGRAMS.container = {
    title: 'Container with most water: move the shorter wall',
    defaults: { heights: [3, 7, 2, 5, 4, 8, 3, 6] },
    code: `func mostWater(_ heights: [Int]) -> Int {
    var left = 0
    var right = heights.count - 1
    var best = 0
    while left < right {
        let water = min(heights[left], heights[right]) * (right - left)
        best = max(best, water)
        if heights[left] < heights[right] {
            left += 1
        } else {
            right -= 1
        }
    }
    return best
}`,
    * run({ heights }) {
        let left = 0;
        let right = heights.length - 1;
        let best = 0;
        let bestPair = null;
        const bars = (extra) => [row('heights', heights, { bars: true, pointers: { left, right }, ...extra })];
        yield { rows: bars(), vars: { best }, line: 4, message: 'Start with the widest container: the first wall and the last. Every other container is narrower.' };
        while (left < right) {
            const level = Math.min(heights[left], heights[right]);
            const water = level * (right - left);
            const record = water > best;
            if (record) {
                best = water;
                bestPair = [left, right];
            }
            const area = { from: left, to: right, level };
            yield { rows: bars({ area, marks: { [left]: 'swap', [right]: 'swap' } }), vars: { left, right, water, best }, line: 7, message: `Walls ${heights[left]} and ${heights[right]}, ${right - left} apart: min(${heights[left]}, ${heights[right]}) × ${right - left} = ${water}.${record ? ' A new best.' : ''}` };
            const moveLeft = heights[left] < heights[right];
            const dropped = moveLeft ? left : right;
            yield { rows: bars({ area, marks: { [dropped]: 'out', [moveLeft ? right : left]: 'swap' } }), vars: { left, right, water, best }, line: moveLeft ? 9 : 11, message: heights[left] === heights[right] ? 'Equal heights: neither wall can do better with a narrower partner, so either can go. The code moves right.' : `The ${moveLeft ? 'left' : 'right'} wall (${heights[dropped]}) is shorter. Any narrower container using it can't be taller, so drop it.` };
            if (moveLeft) left += 1; else right -= 1;
        }
        yield {
            rows: [row('heights', heights, { bars: true, ...(bestPair ? { area: { from: bestPair[0], to: bestPair[1], level: Math.min(heights[bestPair[0]], heights[bestPair[1]]) }, marks: { [bestPair[0]]: 'found', [bestPair[1]]: 'found' } } : {}) })],
            vars: { best },
            line: 14,
            message: `The pointers met after ${Math.max(0, heights.length - 1)} containers instead of ${(heights.length * (heights.length - 1)) / 2}. The best holds ${best}.`,
        };
    },
};

// Trapping rain water with two pointers, drawn as bars, matching the tp-trapping-rain-water lesson
PROGRAMS.rainWater = {
    title: 'Trapping rain water with two pointers',
    defaults: { heights: [4, 1, 3, 0, 2, 5, 1, 2] },
    code: `func trappedWater(_ heights: [Int]) -> Int {
    var left = 0
    var right = heights.count - 1
    var leftMax = 0
    var rightMax = 0
    var total = 0
    while left <= right {
        leftMax = max(leftMax, heights[left])
        rightMax = max(rightMax, heights[right])
        if leftMax <= rightMax {
            total += leftMax - heights[left]
            left += 1
        } else {
            total += rightMax - heights[right]
            right -= 1
        }
    }
    return total
}`,
    * run({ heights }) {
        let left = 0;
        let right = heights.length - 1;
        let leftMax = 0;
        let rightMax = 0;
        let total = 0;
        const water = heights.map(() => null);
        const bars = (extra) => [row('heights', heights, { bars: true, water: [...water], pointers: { left, right }, ...extra })];
        yield { rows: bars(), vars: { leftMax, rightMax, total }, line: 6, message: 'Two walkers start at the ends, each remembering the tallest bar it has passed. Whoever remembers the lower wall knows the water level at its feet.' };
        while (left <= right) {
            leftMax = Math.max(leftMax, heights[left]);
            rightMax = Math.max(rightMax, heights[right]);
            if (leftMax <= rightMax) {
                water[left] = leftMax - heights[left];
                total += water[left];
                yield { rows: bars({ marks: { [left]: 'swap' } }), vars: { leftMax, rightMax, total }, line: 11, message: `leftMax ${leftMax} ≤ rightMax ${rightMax}, so the level at position ${left} is certain: ${leftMax} − ${heights[left]} = ${water[left]} unit${water[left] === 1 ? '' : 's'}.` };
                left += 1;
            } else {
                water[right] = rightMax - heights[right];
                total += water[right];
                yield { rows: bars({ marks: { [right]: 'swap' } }), vars: { leftMax, rightMax, total }, line: 14, message: `rightMax ${rightMax} < leftMax ${leftMax}, so the level at position ${right} is certain: ${rightMax} − ${heights[right]} = ${water[right]} unit${water[right] === 1 ? '' : 's'}.` };
                right -= 1;
            }
        }
        yield { rows: [row('heights', heights, { bars: true, water: [...water] })], vars: { leftMax, rightMax, total }, line: 18, message: `Every position settled exactly once: ${total} units of water, in O(n) time and O(1) space.` };
    },
};

// Largest rectangle in a histogram with a monotonic stack and a sentinel, matching the stack-histogram lesson
PROGRAMS.histogram = {
    title: 'Largest rectangle: measure each bar when it’s popped',
    defaults: { heights: [2, 1, 5, 6, 2, 3] },
    code: `func largestArea(_ heights: [Int]) -> Int {
    var rising: [Int] = []                        // bar indexes, heights increasing bottom to top
    var best = 0
    for i in 0...heights.count {
        let height = i < heights.count ? heights[i] : 0     // a sentinel bar of height 0 at the end
        while let top = rising.last, heights[top] >= height {
            rising.removeLast()
            let left = rising.last ?? -1          // the previous shorter bar
            let width = i - left - 1              // bar i is the next shorter bar
            best = max(best, heights[top] * width)
        }
        rising.append(i)
    }
    return best
}`,
    * run({ heights }) {
        const n = heights.length;
        const withSentinel = [...heights, 0];
        const rising = [];
        let best = 0;
        const labels = () => rising.map((index) => `${index} (${withSentinel[index]})`);
        const bars = (extra) => [row(`heights + sentinel at ${n}`, withSentinel, { bars: true, ...extra })];
        yield { rows: bars(), stack: labels(), vars: { best }, line: 3, message: `The stack holds bar indexes whose heights rise from bottom to top. Index ${n} is a pretend bar of height 0 that will pop everything left at the end.` };
        for (let i = 0; i <= n; i += 1) {
            const height = withSentinel[i];
            while (rising.length && heights[rising.at(-1)] >= height) {
                const top = rising.pop();
                const left = rising.length ? rising.at(-1) : -1;
                const width = i - left - 1;
                const area = heights[top] * width;
                const record = area > best;
                best = Math.max(best, area);
                yield {
                    rows: bars({ pointers: { i }, area: { from: left + 1, to: i - 1, level: heights[top] }, marks: { [top]: 'swap', [i]: 'out' } }),
                    stack: labels(),
                    vars: { i, top, left, width, best },
                    line: 10,
                    message: `${i === n ? 'The sentinel (0)' : `Height ${height} at index ${i}`} is no taller than ${heights[top]} at index ${top}: pop it. Its walls are ${left === -1 ? 'the start' : `index ${left}`} and index ${i}, so its rectangle is ${heights[top]} × ${width} = ${area}.${record ? ' A new best.' : ''}`,
                };
            }
            rising.push(i);
            yield { rows: bars({ pointers: { i }, marks: { [i]: 'found' } }), stack: labels(), vars: { i, best }, line: 12, message: i === n ? 'The sentinel popped every real bar, so each one has been measured.' : `Push index ${i} (height ${height}). The stack's heights still rise from bottom to top.` };
        }
        yield { rows: bars(), stack: labels(), vars: { best }, line: 14, message: `The largest rectangle has area ${best}. Each index was pushed once and popped at most once: O(n).` };
    },
};

// Searching a rotated sorted array in one pass: one half is always sorted. Matches the bs-rotated lesson.
PROGRAMS.rotatedSearch = {
    title: 'Searching a rotated array: one half is always sorted',
    defaults: { items: [40, 50, 60, 70, 10, 20, 30], target: 20 },
    code: `func search(_ items: [Int], for target: Int) -> Int? {
    var low = 0
    var high = items.count - 1
    while low <= high {
        let mid = low + (high - low) / 2
        if items[mid] == target {
            return mid
        }
        if items[low] <= items[mid] {
            if items[low] <= target && target < items[mid] {
                high = mid - 1
            } else {
                low = mid + 1
            }
        } else {
            if items[mid] < target && target <= items[high] {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
    }
    return nil
}`,
    * run({ items, target }) {
        let low = 0;
        let high = items.length - 1;
        const window = () => (low <= high ? { from: low, to: high, tone: 'window' } : null);
        const frame = (line, message, extra = {}) => ({ rows: [row('items', items, { pointers: { low, high }, range: window(), ...extra })], vars: { low, high, target }, line, message });
        yield frame(3, `Search for ${target}. The array was sorted, then rotated, so somewhere there's a break.`);
        while (low <= high) {
            const mid = low + Math.floor((high - low) / 2);
            const pointers = { low, mid, high };
            if (items[mid] === target) {
                yield { ...frame(7, `items[${mid}] is ${target}: found it at index ${mid}.`, { pointers, marks: { [mid]: 'found' } }), vars: { low, mid, high, target } };
                return;
            }
            const leftSorted = items[low] <= items[mid];
            const [from, to] = leftSorted ? [low, mid] : [mid, high];
            yield { ...frame(leftSorted ? 9 : 15, `${items[mid]} isn't ${target}. items[${low}] = ${items[low]} ${leftSorted ? '≤' : '>'} items[${mid}] = ${items[mid]}, so the ${leftSorted ? 'left' : 'right'} half ${items[from]}…${items[to]} is sorted.`, { pointers, range: { from, to, tone: 'kept' } }), vars: { low, mid, high, target } };
            const inside = leftSorted ? items[low] <= target && target < items[mid] : items[mid] < target && target <= items[high];
            const goLeft = leftSorted ? inside : !inside;
            if (goLeft) high = mid - 1; else low = mid + 1;
            const line = leftSorted ? (inside ? 11 : 13) : (inside ? 17 : 19);
            yield { ...frame(line, `${target} is ${inside ? '' : 'not '}between ${items[from]} and ${items[to]}, so it can only be in the ${goLeft ? 'left' : 'right'} part: ${goLeft ? `high = ${high}` : `low = ${low}`}.`), vars: { low, mid, high, target } };
        }
        yield frame(23, `low passed high: ${target} isn't in the array.`);
    },
};

// Cyclic sort for values 1...n, matching the sort-cyclic lesson. Values at home are marked green.
PROGRAMS.cyclicSort = {
    title: 'Cyclic sort: swap every value to its home',
    defaults: { items: [3, 5, 2, 1, 4] },
    code: `func cyclicSort(_ numbers: inout [Int]) {
    var i = 0
    while i < numbers.count {
        let home = numbers[i] - 1                 // where numbers[i] belongs
        if numbers[i] != numbers[home] {
            numbers.swapAt(i, home)
        } else {
            i += 1                                // index i is settled: move on
        }
    }
}`,
    * run({ items }) {
        const numbers = [...items];
        let i = 0;
        let swaps = 0;
        let moves = 0;
        const atHome = (extra = {}) => ({ ...Object.fromEntries(numbers.flatMap((value, index) => (value === index + 1 ? [[index, 'found']] : []))), ...extra });
        const frame = (line, message, pointers, marks) => ({ rows: [row('numbers', numbers, { pointers, marks })], vars: { i, swaps, moves }, line, message });
        yield frame(2, `Each value v belongs at index v − 1. Green values are already home.`, { i }, atHome());
        while (i < numbers.length) {
            const home = numbers[i] - 1;
            if (numbers[i] !== numbers[home]) {
                [numbers[i], numbers[home]] = [numbers[home], numbers[i]];
                swaps += 1;
                yield frame(6, `Send ${numbers[home]} home to index ${home}. ${numbers[i]} comes back to index ${i}${numbers[i] === i + 1 ? ', and it’s home too' : ', and it isn’t home yet, so stay on i'}.`, { i, home }, atHome({ [i]: numbers[i] === i + 1 ? 'found' : 'swap', [home]: 'found' }));
            } else {
                moves += 1;
                yield frame(8, home === i ? `${numbers[i]} is at home: move on.` : `${numbers[i]} is already at its home, index ${home}, so this one is a duplicate: leave it and move on.`, { i }, atHome());
                i += 1;
            }
        }
        yield frame(11, `Sorted with ${swaps} swaps and ${moves} move-ons: at most n of each, so O(n).`, {}, atHome());
    },
};

// Jump game II: fewest jumps to the last index, treating each jump's reachable range as one BFS level
PROGRAMS.jumpGame = {
    title: 'Fewest jumps: each jump covers a range of indexes',
    defaults: { steps: [2, 3, 1, 1, 4, 2, 1, 3, 1] },
    code: `func fewestJumps(_ steps: [Int]) -> Int {
    var jumps = 0
    var reachEnd = 0          // the last index reachable with \`jumps\` jumps
    var farthest = 0          // the farthest any index up to here can reach
    for i in 0..<(steps.count - 1) {
        farthest = max(farthest, i + steps[i])
        if i == reachEnd {    // this range is used up: one more jump is needed
            jumps += 1
            reachEnd = farthest
        }
    }
    return jumps
}`,
    * run({ steps }) {
        let jumps = 0;
        let reachEnd = 0;
        let farthest = 0;
        let rangeStart = 0;
        const last = steps.length - 1;
        const frame = (line, message, i, extra = {}) => ({ rows: [row('steps', steps, { pointers: { ...(i !== undefined ? { i } : {}), farthest: Math.min(farthest, last) }, range: { from: rangeStart, to: Math.min(reachEnd, last), tone: 'window' }, ...extra })], vars: { jumps, reachEnd, farthest }, line, message });
        yield frame(4, `steps[i] is the longest jump from index i. With 0 jumps you can only stand on index 0 (shaded).`, 0);
        for (let i = 0; i < last; i += 1) {
            farthest = Math.max(farthest, i + steps[i]);
            if (i === reachEnd) {
                yield frame(6, `From ${i} you can reach ${i + steps[i]}. The best from this range is ${farthest}, and the range ends here.`, i, { marks: { [i]: 'swap' } });
                jumps += 1;
                rangeStart = reachEnd + 1;
                reachEnd = farthest;
                yield frame(9, `One more jump: ${jumps}. Everything up to ${Math.min(reachEnd, last)} is now reachable (shaded); which index you jumped from doesn't matter.`, i);
            } else {
                yield frame(6, `From ${i} you can reach ${i + steps[i]}. The farthest so far is ${farthest}.`, i, { marks: { [i]: 'swap' } });
            }
        }
        yield { ...frame(12, `The last index is inside the shaded range: ${jumps} jump${jumps === 1 ? '' : 's'}. One pass, O(n), like BFS over ranges instead of single cells.`, undefined, { marks: { [last]: 'found' } }) };
    },
};

// The prefix-sum program, defined separately to keep the table above readable
PROGRAMS.prefixSum.run = function* run({ items, query: [from, to] }) {
    const prefix = [0];
    const padded = () => [...prefix, ...Array(items.length + 1 - prefix.length).fill(null)];
    yield { rows: [row('items', items), row('prefix', padded())], vars: {}, line: 2, message: 'prefix[i] will hold the sum of the first i items. prefix[0] is 0: the sum of nothing.' };
    for (let index = 0; index < items.length; index += 1) {
        const value = items[index];
        prefix.push(prefix.at(-1) + value);
        yield { rows: [row('items', items, { pointers: { value: index } }), row('prefix', padded(), { marks: { [index + 1]: 'swap' } })], vars: { value }, line: 4, message: `prefix[${index + 1}] = prefix[${index}] + ${value} = ${prefix.at(-1)}.` };
    }
    const answer = prefix[to + 1] - prefix[from];
    yield {
        rows: [row('items', items, { range: { from, to, tone: 'window' } }), row('prefix', prefix, { marks: { [to + 1]: 'found', [from]: 'out' } })],
        vars: { answer },
        line: 9,
        message: `Sum of items[${from}...${to}] = prefix[${to + 1}] − prefix[${from}] = ${prefix[to + 1]} − ${prefix[from]} = ${answer}. One subtraction, whatever the range length.`,
    };
};

// KMP's prefix function, matching the sa-kmp lesson: k is the length of the border being extended
const prefixTable = (chars) => {
    const pi = chars.map(() => 0);
    let k = 0;
    for (let i = 1; i < chars.length; i += 1) {
        while (k > 0 && chars[i] !== chars[k]) k = pi[k - 1];
        if (chars[i] === chars[k]) k += 1;
        pi[i] = k;
    }
    return pi;
};

PROGRAMS.prefixFunction = {
    title: 'Building KMP’s prefix function',
    defaults: { pattern: 'abacabab' },
    code: `func prefixFunction(_ s: [Character]) -> [Int] {
    var pi = [Int](repeating: 0, count: s.count)
    var k = 0                          // length of the border being extended
    for i in s.indices.dropFirst() {
        while k > 0 && s[i] != s[k] {
            k = pi[k - 1]              // fall back to the next shorter border
        }
        if s[i] == s[k] {
            k += 1                     // the border grows by one character
        }
        pi[i] = k
    }
    return pi
}`,
    * run({ pattern }) {
        const chars = [...pattern];
        const pi = chars.map((_, index) => (index === 0 ? 0 : null));
        let k = 0;
        const quote = (from, to) => `“${chars.slice(from, to).join('')}”`;
        const frame = (line, message, i, marks = {}, piMarks = {}) => ({
            rows: [
                row('s', chars, { pointers: i === undefined ? {} : { i, k }, range: k > 0 ? { from: 0, to: k - 1, tone: 'kept' } : null, marks }),
                row('π', pi, { pointers: i === undefined ? {} : { i }, marks: piMarks }),
            ],
            vars: { k, border: k ? quote(0, k) : '“”' },
            line,
            message,
        });
        yield frame(3, `π[0] = 0: one character has no proper border. k, the length of the border being extended, starts at 0.`);
        for (let i = 1; i < chars.length; i += 1) {
            while (k > 0 && chars[i] !== chars[k]) {
                const longer = k;
                k = pi[k - 1];
                yield frame(6, `s[${i}] = ${chars[i]} ≠ s[${longer}] = ${chars[longer]}, so the border ${quote(0, longer)} can’t grow. A border of a border is a border: fall back to π[${longer - 1}] = ${k}${k ? `, the border ${quote(0, k)}` : ''}.`, i, { [i]: 'out' }, { [longer - 1]: 'swap' });
            }
            if (chars[i] === chars[k]) {
                k += 1;
                pi[i] = k;
                yield frame(11, `s[${i}] = s[${k - 1}] = ${chars[i]}: the border grows to ${quote(0, k)}, so π[${i}] = ${k}.`, i, { [i]: 'found', [k - 1]: 'found' }, { [i]: 'found' });
            } else {
                pi[i] = 0;
                yield frame(11, `s[${i}] = ${chars[i]} ≠ s[0] = ${chars[0]}: no border ends here, so π[${i}] = 0.`, i, { [i]: 'out' }, { [i]: 'out' });
            }
        }
        yield frame(13, `π = [${pi.join(', ')}]. k rises by at most 1 per step and every fallback lowers it, so all the fallbacks together cost at most m − 1 steps: O(m).`);
    },
};

PROGRAMS.kmpSearch = {
    title: 'KMP matching: the text pointer never moves back',
    defaults: { text: 'abacabacabab', pattern: 'abacabab' },
    code: `func kmpSearch(_ pattern: [Character], in text: [Character]) -> [Int] {
    let pi = prefixFunction(pattern)
    var result: [Int] = []
    var j = 0                          // how many pattern characters match so far
    for (i, c) in text.enumerated() {
        while j > 0 && c != pattern[j] {
            j = pi[j - 1]              // shift the pattern; i stays put
        }
        if c == pattern[j] {
            j += 1
        }
        if j == pattern.count {
            result.append(i - j + 1)
            j = pi[j - 1]              // matches can overlap, so keep the border
        }
    }
    return result
}`,
    * run({ text, pattern }) {
        const chars = [...text];
        const needle = [...pattern];
        const pi = prefixTable(needle);
        const matches = [];
        let j = 0;
        // The pattern row is lined up under the text: pattern[0] sits under text index `shift`
        const frame = (line, message, { i, shift = 0, matched = 0, textMarks = {}, piMarks = {} } = {}) => {
            const width = Math.max(chars.length, shift + needle.length);
            const aligned = Array.from({ length: width }, (_, index) => (index >= shift && index < shift + needle.length ? needle[index - shift] : null));
            const range = matched > 0 ? { from: shift, to: shift + matched - 1, tone: 'kept' } : null;
            return {
                rows: [
                    row('text', chars, { pointers: i === undefined ? {} : { i }, range, marks: textMarks }),
                    row('pattern, lined up', aligned, { pointers: i === undefined ? {} : { j: shift + j }, range, marks: Object.fromEntries(Object.entries(textMarks).filter(([index]) => aligned[index] !== null)) }),
                    row('π (pattern)', pi, { marks: piMarks }),
                ],
                list: { title: 'matches start at', items: matches.map(String) },
                vars: { j },
                line,
                message,
            };
        };
        yield frame(4, `π for “${pattern}” is [${pi.join(', ')}]. j counts the pattern characters matched so far; the text pointer i only ever moves forward.`);
        for (let i = 0; i < chars.length; i += 1) {
            const c = chars[i];
            while (j > 0 && c !== needle[j]) {
                const before = j;
                yield frame(6, `text[${i}] = ${c} ≠ pattern[${j}] = ${needle[j]}. Of the ${j} matched characters “${needle.slice(0, j).join('')}”, the longest border is π[${j - 1}] = ${pi[j - 1]} long.`, { i, shift: i - j, matched: j, textMarks: { [i]: 'out' }, piMarks: { [j - 1]: 'swap' } });
                j = pi[j - 1];
                const skipped = before - j - 1;
                yield frame(7, `${j ? `Slide the pattern so ${j === 1 ? 'its first character sits under the text it already matches' : `its first ${j} characters sit under the text they already match`}: j = ${j}.` : 'No border: slide the pattern past everything matched, j = 0.'}${skipped > 0 ? ` Starts ${i - before + 1}${skipped > 1 ? `–${i - j - 1}` : ''} are skipped without a comparison: none can match.` : ''} i stays at ${i}.`, { i, shift: i - j, matched: j, piMarks: { [before - 1]: 'swap' } });
            }
            if (c === needle[j]) {
                j += 1;
                yield frame(10, `text[${i}] = pattern[${j - 1}] = ${c}: ${j} character${j === 1 ? '' : 's'} match.`, { i, shift: i - j + 1, matched: j, textMarks: { [i]: 'found' } });
            } else {
                yield frame(9, `text[${i}] = ${c} ≠ pattern[0] = ${needle[0]}: nothing matches yet. Move on.`, { i, shift: i, textMarks: { [i]: 'out' } });
            }
            if (j === needle.length) {
                const at = i - j + 1;
                matches.push(at);
                yield frame(13, `All ${needle.length} characters match: a match starts at ${at}.`, { i, shift: at, matched: j, textMarks: Object.fromEntries(needle.map((_, index) => [at + index, 'found'])) });
                j = pi[j - 1];
                yield frame(14, `Keep the border so overlapping matches count: j = π[${needle.length - 1}] = ${j}. The next text character is compared with pattern[${j}].`, { i, shift: i + 1 - j, matched: j, piMarks: { [needle.length - 1]: 'swap' } });
            }
        }
        const found = Object.fromEntries(matches.flatMap((at) => needle.map((_, index) => [at + index, 'found'])));
        yield frame(17, `${matches.length ? `Matches start at ${matches.join(', ')}.` : 'No match.'} i moved forward ${chars.length} times and every slide lowered j, so the search is O(n + m).`, { shift: matches.at(-1) ?? 0, textMarks: found });
    },
};

Object.assign(PROGRAMS, SORT_PROGRAMS);

export const ARRAY_PROGRAMS = Object.keys(PROGRAMS);

export const arrayProgram = (name) => {
    const program = PROGRAMS[name];
    if (!program) throw new Error(`Unknown array program "${name}"`);
    return program;
};

export const arrayFrames = (name, input = {}) => [...arrayProgram(name).run({ ...arrayProgram(name).defaults, ...input })];
