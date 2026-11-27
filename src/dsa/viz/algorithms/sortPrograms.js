// Sorting and searching programs for the arrayTrace visualiser (same frame shape as arrayPrograms.js).

const row = (label, values, extra = {}) => ({ label, values: [...values], pointers: {}, marks: {}, range: null, ...extra });
const sortedTail = (from, length) => (from < length ? { from, to: length - 1, tone: 'kept' } : null);

export const SORT_PROGRAMS = {
    bubbleSort: {
        title: 'Bubble sort',
        defaults: { items: [5, 1, 4, 2, 8, 3] },
        code: `func bubbleSort(_ items: inout [Int]) {
    for pass in 0..<items.count {
        var swapped = false
        for j in 0..<(items.count - 1 - pass) {
            if items[j] > items[j + 1] {
                items.swapAt(j, j + 1)
                swapped = true
            }
        }
        if !swapped { return }
    }
}`,
        * run({ items }) {
            const values = [...items];
            let comparisons = 0;
            let swaps = 0;
            for (let pass = 0; pass < values.length; pass += 1) {
                let swapped = false;
                const tail = values.length - pass;
                for (let j = 0; j < values.length - 1 - pass; j += 1) {
                    comparisons += 1;
                    const bigger = values[j] > values[j + 1];
                    if (bigger) {
                        [values[j], values[j + 1]] = [values[j + 1], values[j]];
                        swaps += 1;
                        swapped = true;
                    }
                    yield { rows: [row('items', values, { pointers: { j, 'j+1': j + 1 }, marks: bigger ? { [j]: 'swap', [j + 1]: 'swap' } : {}, range: sortedTail(tail, values.length) })], vars: { pass, comparisons, swaps }, line: bigger ? 6 : 5, message: bigger ? `${values[j + 1]} > ${values[j]}: swap them. The bigger value bubbles right.` : `${values[j]} ≤ ${values[j + 1]}: already in order.` };
                }
                yield { rows: [row('items', values, { range: sortedTail(tail - 1, values.length) })], vars: { pass, comparisons, swaps }, line: 10, message: swapped ? `Pass ${pass + 1} done: the largest remaining value is now in place at the right.` : 'No swaps in a whole pass: the array is sorted, so stop early.' };
                if (!swapped) return;
            }
        },
        result: ({ items }) => [...items].sort((a, b) => a - b),
    },
    selectionSort: {
        title: 'Selection sort',
        defaults: { items: [29, 10, 14, 37, 13, 5] },
        code: `func selectionSort(_ items: inout [Int]) {
    for i in 0..<items.count {
        var smallest = i
        for j in (i + 1)..<items.count where items[j] < items[smallest] {
            smallest = j
        }
        items.swapAt(i, smallest)
    }
}`,
        * run({ items }) {
            const values = [...items];
            for (let i = 0; i < values.length; i += 1) {
                let smallest = i;
                for (let j = i + 1; j < values.length; j += 1) {
                    const smaller = values[j] < values[smallest];
                    if (smaller) smallest = j;
                    yield { rows: [row('items', values, { pointers: { i, j, smallest }, range: i > 0 ? { from: 0, to: i - 1, tone: 'kept' } : null, marks: { [smallest]: 'found' } })], vars: { i, smallest }, line: smaller ? 5 : 4, message: smaller ? `${values[j]} is the smallest so far.` : `${values[j]} isn’t smaller than ${values[smallest]}.` };
                }
                [values[i], values[smallest]] = [values[smallest], values[i]];
                yield { rows: [row('items', values, { pointers: { i, smallest }, range: { from: 0, to: i, tone: 'kept' }, marks: { [i]: 'swap', [smallest]: 'swap' } })], vars: { i, smallest }, line: 7, message: `Swap the smallest remaining value (${values[i]}) into index ${i}. Indexes 0–${i} are final.` };
            }
        },
        result: ({ items }) => [...items].sort((a, b) => a - b),
    },
    insertionSort: {
        title: 'Insertion sort',
        defaults: { items: [12, 11, 13, 5, 6, 7] },
        code: `func insertionSort(_ items: inout [Int]) {
    for i in 1..<items.count {
        let key = items[i]
        var j = i - 1
        while j >= 0 && items[j] > key {
            items[j + 1] = items[j]
            j -= 1
        }
        items[j + 1] = key
    }
}`,
        * run({ items }) {
            const values = [...items];
            for (let i = 1; i < values.length; i += 1) {
                const key = values[i];
                let j = i - 1;
                yield { rows: [row('items', values, { pointers: { i }, range: { from: 0, to: i - 1, tone: 'kept' }, marks: { [i]: 'found' } })], vars: { key }, line: 3, message: `Take ${key}. Everything to its left is already sorted.` };
                while (j >= 0 && values[j] > key) {
                    values[j + 1] = values[j];
                    yield { rows: [row('items', values, { pointers: { j }, range: { from: 0, to: i, tone: 'kept' }, marks: { [j + 1]: 'swap' } })], vars: { key, j }, line: 6, message: `${values[j]} > ${key}: shift it one place right.` };
                    j -= 1;
                }
                values[j + 1] = key;
                yield { rows: [row('items', values, { range: { from: 0, to: i, tone: 'kept' }, marks: { [j + 1]: 'found' } })], vars: { key }, line: 9, message: `Drop ${key} into the gap at index ${j + 1}. Indexes 0–${i} are sorted.` };
            }
        },
        result: ({ items }) => [...items].sort((a, b) => a - b),
    },
    mergeSort: {
        title: 'Merge sort, bottom-up',
        defaults: { items: [38, 27, 43, 3, 9, 82, 10, 1] },
        code: `func mergeSort(_ items: inout [Int]) {
    var width = 1
    while width < items.count {
        for low in stride(from: 0, to: items.count, by: 2 * width) {
            let mid = min(low + width, items.count)
            let high = min(low + 2 * width, items.count)
            var merged: [Int] = []
            var i = low, j = mid
            while i < mid && j < high {
                if items[i] <= items[j] { merged.append(items[i]); i += 1 }
                else { merged.append(items[j]); j += 1 }
            }
            merged += items[i..<mid] + items[j..<high]
            items.replaceSubrange(low..<high, with: merged)
        }
        width *= 2
    }
}`,
        * run({ items }) {
            const values = [...items];
            for (let width = 1; width < values.length; width *= 2) {
                yield { rows: [row('items', values)], vars: { width }, line: 3, message: `Merge neighbouring sorted runs of length ${width} into runs of length ${width * 2}.` };
                for (let low = 0; low < values.length; low += 2 * width) {
                    const mid = Math.min(low + width, values.length);
                    const high = Math.min(low + 2 * width, values.length);
                    if (mid >= high) continue;
                    const merged = [];
                    let i = low;
                    let j = mid;
                    while (i < mid && j < high) {
                        const takeLeft = values[i] <= values[j];
                        merged.push(takeLeft ? values[i] : values[j]);
                        yield { rows: [row('items', values, { pointers: { i, j }, range: { from: low, to: high - 1, tone: 'window' } }), row('merged', [...merged, ...Array(high - low - merged.length).fill(null)], { marks: { [merged.length - 1]: 'swap' } })], vars: { width }, line: 10, message: `Take the smaller front: ${takeLeft ? values[i] : values[j]}.` };
                        if (takeLeft) i += 1;
                        else j += 1;
                    }
                    merged.push(...values.slice(i, mid), ...values.slice(j, high));
                    values.splice(low, high - low, ...merged);
                    yield { rows: [row('items', values, { range: { from: low, to: high - 1, tone: 'kept' } }), row('merged', merged)], vars: { width }, line: 14, message: `One run is used up: copy the rest and write the merged run back (indexes ${low}–${high - 1}).` };
                }
            }
            yield { rows: [row('items', values, { range: { from: 0, to: values.length - 1, tone: 'kept' } })], vars: {}, line: 16, message: `Sorted, in about log₂(${values.length}) rounds of merging. Each round touches every element once: O(n log n).` };
        },
        result: ({ items }) => [...items].sort((a, b) => a - b),
    },
    quickSort: {
        title: 'Quick sort with Lomuto partitioning',
        defaults: { items: [10, 80, 30, 90, 40, 50, 70] },
        code: `func quickSort(_ items: inout [Int], _ low: Int, _ high: Int) {
    guard low < high else { return }
    let pivot = items[high]
    var i = low
    for j in low..<high where items[j] < pivot {
        items.swapAt(i, j)
        i += 1
    }
    items.swapAt(i, high)
    quickSort(&items, low, i - 1)
    quickSort(&items, i + 1, high)
}`,
        * run({ items }) {
            const values = [...items];
            const done = new Set();
            const finalMarks = () => Object.fromEntries([...done].map((index) => [index, 'found']));
            const ranges = [[0, values.length - 1]];
            while (ranges.length) {
                const [low, high] = ranges.pop();
                if (low >= high) {
                    if (low === high) done.add(low);
                    continue;
                }
                const pivot = values[high];
                let i = low;
                yield { rows: [row('items', values, { range: { from: low, to: high, tone: 'window' }, marks: { ...finalMarks(), [high]: 'out' } })], vars: { low, high, pivot }, line: 3, message: `Partition indexes ${low}–${high} around the last value, pivot ${pivot}.` };
                for (let j = low; j < high; j += 1) {
                    const smaller = values[j] < pivot;
                    if (smaller) {
                        [values[i], values[j]] = [values[j], values[i]];
                        yield { rows: [row('items', values, { pointers: { i, j }, range: { from: low, to: high, tone: 'window' }, marks: { ...finalMarks(), [high]: 'out', [i]: 'swap', [j]: 'swap' } })], vars: { low, high, pivot }, line: 6, message: `${values[i]} < ${pivot}: swap it into the "smaller" side at index ${i}.` };
                        i += 1;
                    } else {
                        yield { rows: [row('items', values, { pointers: { i, j }, range: { from: low, to: high, tone: 'window' }, marks: { ...finalMarks(), [high]: 'out' } })], vars: { low, high, pivot }, line: 5, message: `${values[j]} ≥ ${pivot}: leave it on the "bigger" side.` };
                    }
                }
                [values[i], values[high]] = [values[high], values[i]];
                done.add(i);
                yield { rows: [row('items', values, { range: { from: low, to: high, tone: 'window' }, marks: finalMarks() })], vars: { low, high, pivot }, line: 9, message: `Put the pivot between the sides, at index ${i}: it’s in its final place. Now sort each side.` };
                ranges.push([i + 1, high], [low, i - 1]);
            }
            yield { rows: [row('items', values, { range: { from: 0, to: values.length - 1, tone: 'kept' } })], vars: {}, line: 11, message: 'Every pivot landed in its final place, so the array is sorted.' };
        },
        result: ({ items }) => [...items].sort((a, b) => a - b),
    },
    countingSort: {
        title: 'Counting sort',
        defaults: { items: [4, 2, 2, 8, 3, 3, 1], max: 8 },
        code: `func countingSort(_ items: [Int], maxValue: Int) -> [Int] {
    var counts = [Int](repeating: 0, count: maxValue + 1)
    for value in items {
        counts[value] += 1
    }
    var sorted: [Int] = []
    for value in 0...maxValue {
        sorted += Array(repeating: value, count: counts[value])
    }
    return sorted
}`,
        * run({ items, max }) {
            const counts = Array(max + 1).fill(0);
            yield { rows: [row('items', items), row('counts', counts)], vars: {}, line: 2, message: `One counter per possible value, 0 to ${max}.` };
            for (let index = 0; index < items.length; index += 1) {
                counts[items[index]] += 1;
                yield { rows: [row('items', items, { pointers: { value: index } }), row('counts', counts, { marks: { [items[index]]: 'swap' } })], vars: {}, line: 4, message: `Count ${items[index]}: counts[${items[index]}] is now ${counts[items[index]]}.` };
            }
            const sorted = [];
            for (let value = 0; value <= max; value += 1) {
                if (!counts[value]) continue;
                sorted.push(...Array(counts[value]).fill(value));
                yield { rows: [row('counts', counts, { marks: { [value]: 'found' } }), row('sorted', [...sorted, ...Array(items.length - sorted.length).fill(null)])], vars: {}, line: 8, message: `Write ${value} ${counts[value]} time${counts[value] > 1 ? 's' : ''}.` };
            }
            yield { rows: [row('sorted', sorted, { range: { from: 0, to: sorted.length - 1, tone: 'kept' } })], vars: {}, line: 10, message: `No comparisons at all: O(n + k), where k is the range of values (${max + 1} here).` };
        },
        result: ({ items }) => [...items].sort((a, b) => a - b),
    },
    sieve: {
        title: 'The Sieve of Eratosthenes',
        defaults: { n: 30 },
        code: `func primes(upTo n: Int) -> [Int] {
    var isPrime = [Bool](repeating: true, count: n + 1)
    isPrime[0] = false
    isPrime[1] = false
    var p = 2
    while p * p <= n {
        if isPrime[p] {
            for multiple in stride(from: p * p, through: n, by: p) {
                isPrime[multiple] = false
            }
        }
        p += 1
    }
    return (0...n).filter { isPrime[$0] }
}`,
        * run({ n }) {
            const values = Array.from({ length: n + 1 }, (_, index) => index);
            const isPrime = values.map((value) => value >= 2);
            const marks = () => Object.fromEntries(values.filter((value) => !isPrime[value]).map((value) => [value, 'out']));
            yield { rows: [row('numbers', values, { marks: marks() })], vars: {}, line: 4, message: `Assume every number from 2 to ${n} is prime. 0 and 1 aren’t.` };
            for (let p = 2; p * p <= n; p += 1) {
                if (!isPrime[p]) {
                    yield { rows: [row('numbers', values, { pointers: { p }, marks: marks() })], vars: { p }, line: 13, message: `${p} was already crossed out, so its multiples are crossed out too. Skip it.` };
                    continue;
                }
                const crossed = [];
                for (let multiple = p * p; multiple <= n; multiple += p) {
                    if (isPrime[multiple]) crossed.push(multiple);
                    isPrime[multiple] = false;
                }
                yield { rows: [row('numbers', values, { pointers: { p }, marks: { ...marks(), [p]: 'found' } })], vars: { p }, line: 9, message: `${p} is prime. Cross out its multiples from ${p}² = ${p * p}: ${crossed.length ? crossed.join(', ') : 'all already crossed'}.` };
            }
            const primes = values.filter((value) => isPrime[value]);
            yield { rows: [row('numbers', values, { marks: { ...marks(), ...Object.fromEntries(primes.map((value) => [value, 'found'])) } })], vars: {}, line: 15, message: `Once p² passes ${n}, everything left is prime: ${primes.join(', ')}.` };
        },
    },
    lowerBound: {
        title: 'Lower bound: the first index whose value is ≥ the target',
        defaults: { items: [1, 3, 3, 3, 5, 8, 9], target: 3 },
        code: `func lowerBound(_ items: [Int], _ target: Int) -> Int {
    var low = 0
    var high = items.count          // half-open: [low, high)
    while low < high {
        let mid = low + (high - low) / 2
        if items[mid] < target {
            low = mid + 1
        } else {
            high = mid
        }
    }
    return low
}`,
        * run({ items, target }) {
            let low = 0;
            let high = items.length;
            const frame = (line, message, mid) => ({ rows: [row('items', items, { pointers: mid === undefined ? { low, high } : { low, mid, high }, range: low < high ? { from: low, to: high - 1, tone: 'window' } : null })], vars: { low, high, target }, line, message });
            yield frame(3, `The answer is somewhere in [${low}, ${high}): high is one past the end, because "not found" is an answer too.`);
            while (low < high) {
                const mid = low + Math.floor((high - low) / 2);
                if (items[mid] < target) {
                    yield frame(7, `items[${mid}] = ${items[mid]} < ${target}: the answer is after mid.`, mid);
                    low = mid + 1;
                } else {
                    yield frame(9, `items[${mid}] = ${items[mid]} ≥ ${target}: mid could be the answer, so keep it: high = mid.`, mid);
                    high = mid;
                }
            }
            yield { ...frame(12, `low == high == ${low}: the first index with a value ≥ ${target}${low === items.length ? ' (past the end: every value is smaller)' : ''}.`), rows: [row('items', items, { pointers: { answer: low }, marks: low < items.length ? { [low]: 'found' } : {} })] };
        },
    },
};
