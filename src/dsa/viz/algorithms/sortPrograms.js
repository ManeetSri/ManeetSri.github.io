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

// The seeded generator the efficient-sorts lessons use (a 64-bit LCG), so traces match their printed output
export const lessonDice = (seed) => {
    let state = BigInt(seed);
    const mask = (1n << 64n) - 1n;
    return (low, high) => {
        state = (state * 6364136223846793005n + 1442695040888963407n) & mask;
        return low + Number((state >> 33n) % BigInt(high - low + 1));
    };
};

SORT_PROGRAMS.hoarePartition = {
    title: 'Hoare partitioning: two scans meet in the middle',
    defaults: { items: [3, 9, 5, 1, 7, 2] },
    code: `func hoarePartition(_ items: inout [Int], _ low: Int, _ high: Int) -> Int {
    let pivot = items[low + (high - low) / 2]    // the middle element (rounding down)
    var i = low - 1
    var j = high + 1
    while true {
        repeat { i += 1 } while items[i] < pivot   // find an element that belongs on the right
        repeat { j -= 1 } while items[j] > pivot   // find an element that belongs on the left
        if i >= j { return j }                     // the scans have met: done
        items.swapAt(i, j)
    }
}`,
    * run({ items }) {
        const values = [...items];
        const high = values.length - 1;
        const pivot = values[Math.floor(high / 2)];
        let i = -1;
        let j = values.length;
        const frame = (line, message, extra = {}) => ({ rows: [row('items', values, { pointers: { i, j }, ...extra })], vars: { pivot, i, j }, line, message });
        yield frame(2, `The pivot is the middle element, ${pivot}. i and j start just outside the range.`, { marks: { [Math.floor(high / 2)]: 'found' } });
        for (;;) {
            do { i += 1; } while (values[i] < pivot);
            yield frame(6, `i stops at index ${i}: ${values[i]} ≥ ${pivot}, so it belongs on the right.`, { marks: { [i]: 'swap' } });
            do { j -= 1; } while (values[j] > pivot);
            yield frame(7, `j stops at index ${j}: ${values[j]} ≤ ${pivot}, so it belongs on the left.`, { marks: { [i]: 'swap', [j]: 'swap' } });
            if (i >= j) {
                yield frame(8, `The scans have met (i ${i} ≥ j ${j}). Split after index ${j}: everything in 0…${j} is ≤ ${pivot}, everything after is ≥ ${pivot}. The pivot isn't necessarily at the split.`, { range: { from: 0, to: j, tone: 'kept' } });
                return;
            }
            [values[i], values[j]] = [values[j], values[i]];
            yield frame(9, `Swap them: ${values[i]} moves left and ${values[j]} moves right.`, { marks: { [i]: 'swap', [j]: 'swap' } });
        }
    },
};

SORT_PROGRAMS.threeWay = {
    title: 'Three-way partitioning: smaller, equal, larger',
    defaults: { items: [4, 9, 4, 1, 4, 7, 2, 4], pivot: 4 },
    code: `func partition3(_ items: inout [Int], _ low: Int, _ high: Int, pivot: Int) -> (lessEnd: Int, greaterStart: Int) {
    var less = low                           // low..<less: smaller than the pivot
    var scan = low                           // less..<scan: equal to it
    var greater = high + 1                   // scan..<greater: not looked at yet
    while scan < greater {                   // greater...high: larger than it
        if items[scan] < pivot {
            items.swapAt(less, scan)
            less += 1
            scan += 1
        } else if items[scan] > pivot {
            greater -= 1
            items.swapAt(scan, greater)      // the element swapped in hasn't been looked at
        } else {
            scan += 1
        }
    }
    return (less, greater)
}`,
    * run({ items, pivot }) {
        const values = [...items];
        let less = 0;
        let scan = 0;
        let greater = values.length;
        // Settled regions: smaller (green), equal (shaded), larger (red)
        const regions = (extra = {}) => ({
            marks: { ...Object.fromEntries(values.flatMap((_, index) => (index < less ? [[index, 'found']] : index >= greater ? [[index, 'out']] : []))), ...extra },
            range: scan > less ? { from: less, to: scan - 1, tone: 'kept' } : null,
        });
        const frame = (line, message, extra) => ({ rows: [row('items', values, { pointers: { less, scan, greater }, ...regions(extra) })], vars: { pivot, less, scan, greater }, line, message });
        yield frame(4, `Partition around ${pivot}. Green will be smaller, the shaded block equal, red larger; scan…greater − 1 is still unknown.`);
        while (scan < greater) {
            const value = values[scan];
            if (value < pivot) {
                [values[less], values[scan]] = [values[scan], values[less]];
                less += 1;
                scan += 1;
                yield frame(9, `${value} < ${pivot}: swap it to the end of the smaller block. less and scan both move on.`);
            } else if (value > pivot) {
                greater -= 1;
                [values[scan], values[greater]] = [values[greater], values[scan]];
                yield frame(12, `${value} > ${pivot}: swap it into the larger block. ${values[scan]} comes back to scan unseen, so scan stays.`, { [scan]: 'swap' });
            } else {
                scan += 1;
                yield frame(14, `${value} equals the pivot: it joins the equal block. scan moves on.`);
            }
        }
        yield frame(17, `Done in one pass. Smaller: 0..<${less}, equal: ${less}..<${greater}, larger: ${greater}…${values.length - 1}. The equal block is in its final place.`);
    },
};

SORT_PROGRAMS.quickselect = {
    title: 'Quickselect: partition, then keep only the side with k',
    defaults: { items: [42, 7, 19, 88, 3, 56, 23, 71, 12, 64], k: 5, seed: 11 },
    code: `func partition(_ items: inout [Int], _ low: Int, _ high: Int) -> Int {
    items.swapAt(dice.roll(low...high), high)    // a random pivot, moved to the end
    let pivot = items[high]
    var boundary = low
    for j in low..<high where items[j] < pivot {
        items.swapAt(boundary, j)
        boundary += 1
    }
    items.swapAt(boundary, high)
    return boundary
}

/// The value that would be at index k (0-based) if numbers were sorted
func quickselect(_ numbers: [Int], _ k: Int) -> Int {
    var items = numbers
    var low = 0
    var high = items.count - 1
    while true {
        let p = partition(&items, low, high)
        if p == k {
            return items[p]
        } else if k < p {
            high = p - 1                     // the answer is on the left: forget the right
        } else {
            low = p + 1                      // the answer is on the right: forget the left
        }
    }
}`,
    * run({ items, k, seed }) {
        const values = [...items];
        const roll = lessonDice(seed);
        let low = 0;
        let high = values.length - 1;
        let partitions = 0;
        const frame = (line, message, extra = {}) => ({ rows: [row('items', values, { pointers: { low, high, k }, range: { from: low, to: high, tone: 'window' }, ...extra })], vars: { k, low, high, partitions }, line, message });
        yield frame(17, `Find the value that belongs at index ${k} in sorted order, without sorting. The shaded range is still in play.`);
        for (;;) {
            const chosen = roll(low, high);
            [values[chosen], values[high]] = [values[high], values[chosen]];
            const pivot = values[high];
            yield frame(2, `Random pivot: ${pivot} (from index ${chosen}), moved to the end of the range.`, { marks: { [high]: 'swap' } });
            let boundary = low;
            for (let j = low; j < high; j += 1) {
                if (values[j] < pivot) {
                    [values[boundary], values[j]] = [values[j], values[boundary]];
                    boundary += 1;
                }
            }
            [values[boundary], values[high]] = [values[high], values[boundary]];
            partitions += 1;
            const p = boundary;
            yield frame(19, `After partitioning ${low}…${high}, the pivot ${pivot} lands at index ${p}: everything left of it is smaller.`, { marks: { [p]: 'found' } });
            if (p === k) {
                yield { ...frame(21, `p == k: ${pivot} is the answer, after ${partitions} partition${partitions === 1 ? '' : 's'}. The rest of the array is still unsorted, and that's fine.`, { marks: { [p]: 'found' } }), rows: [row('items', values, { pointers: { k }, marks: { [p]: 'found' } })] };
                return;
            }
            if (k < p) high = p - 1; else low = p + 1;
            yield frame(k < p ? 23 : 25, k < p ? `k ${k} < ${p}: the answer is on the left, so forget everything from ${p} on.` : `k ${k} > ${p}: the answer is on the right, so forget everything up to ${p}.`);
        }
    },
};

// Counting inversions while merge sorting, matching the sort-inversions lesson
SORT_PROGRAMS.inversions = {
    title: 'Counting inversions while merging',
    defaults: { items: [5, 2, 6, 1, 3, 4] },
    code: `func sortAndCount(_ items: inout [Int], _ buffer: inout [Int], _ low: Int, _ high: Int) -> Int {
    guard high - low > 1 else { return 0 }
    let mid = low + (high - low) / 2
    var inversions = sortAndCount(&items, &buffer, low, mid) + sortAndCount(&items, &buffer, mid, high)
    for index in low..<high {
        buffer[index] = items[index]
    }
    var across = 0
    var left = low
    var right = mid
    for write in low..<high {
        if right == high || (left < mid && buffer[left] <= buffer[right]) {
            items[write] = buffer[left]
            left += 1
        } else {
            items[write] = buffer[right]
            right += 1
            across += mid - left             // it jumps ahead of everything left in the left half
        }
    }
    inversions += across
    return inversions
}`,
    * run({ items }) {
        const values = [...items];
        const buffer = [...items];
        let total = 0;
        yield { rows: [row('items', values)], vars: { total }, line: 1, message: 'Merge sort, counting as it merges: when an element comes from the right half, it jumps ahead of every element still waiting on the left.' };
        function* sortAndCount(low, high) {
            if (high - low <= 1) return;
            const mid = low + Math.floor((high - low) / 2);
            yield* sortAndCount(low, mid);
            yield* sortAndCount(mid, high);
            for (let index = low; index < high; index += 1) buffer[index] = values[index];
            let across = 0;
            let left = low;
            let right = mid;
            const halves = (extra = {}) => row('buffer', buffer.map((value, index) => (index >= low && index < high ? value : null)), { pointers: { left, right }, range: { from: low, to: mid - 1, tone: 'window' }, ...extra });
            for (let write = low; write < high; write += 1) {
                const takeLeft = right === high || (left < mid && buffer[left] <= buffer[right]);
                if (takeLeft) {
                    values[write] = buffer[left];
                    left += 1;
                    yield { rows: [halves(), row('items', values, { marks: { [write]: 'swap' }, range: { from: low, to: write, tone: 'kept' } })], vars: { across, total }, line: 13, message: `Take ${values[write]} from the left half. It jumps over nothing, so no inversions.` };
                } else {
                    const waiting = Array.from({ length: mid - left }, (_, offset) => left + offset);
                    values[write] = buffer[right];
                    right += 1;
                    across += waiting.length;
                    total += waiting.length;
                    yield { rows: [halves({ marks: Object.fromEntries(waiting.map((index) => [index, 'out'])) }), row('items', values, { marks: { [write]: 'swap' }, range: { from: low, to: write, tone: 'kept' } })], vars: { across, total }, line: 18, message: waiting.length ? `Take ${values[write]} from the right half. It's smaller than the ${waiting.length} waiting on the left (${waiting.map((index) => buffer[index]).join(', ')}): ${waiting.length} inversion${waiting.length === 1 ? '' : 's'}.` : `Take ${values[write]} from the right half. The left half is used up, so it jumps over nothing.` };
                }
            }
            yield { rows: [row('items', values, { range: { from: low, to: high - 1, tone: 'kept' } })], vars: { across, total }, line: 21, message: `Merged ${buffer.slice(low, mid).join(', ')} with ${buffer.slice(mid, high).join(', ')}: ${across} across.` };
        }
        yield* sortAndCount(0, values.length);
        yield { rows: [row('items', values, { range: { from: 0, to: values.length - 1, tone: 'kept' } })], vars: { total }, line: 22, message: `${total} inversions in total, counted in O(n log n) instead of checking all ${(items.length * (items.length - 1)) / 2} pairs.` };
    },
};

// LSD radix sort, base 10, with a stable counting pass per digit, matching the sort-radix lesson
SORT_PROGRAMS.radixSort = {
    title: 'Radix sort: one stable counting pass per digit',
    defaults: { items: [512, 38, 204, 97, 731, 45, 260, 8] },
    code: `func countingPass(_ numbers: [Int], place: Int) -> [Int] {
    var next = [Int](repeating: 0, count: 10)
    for number in numbers {
        next[(number / place) % 10] += 1
    }
    var total = 0                                // counts become starting positions
    for digit in 0..<10 {
        let count = next[digit]
        next[digit] = total
        total += count
    }
    var result = numbers
    for number in numbers {                      // place in input order: stable
        let digit = (number / place) % 10
        result[next[digit]] = number
        next[digit] += 1
    }
    return result
}

func radixSort(_ numbers: [Int]) -> [Int] {
    guard let largest = numbers.max() else { return [] }
    var result = numbers
    var place = 1
    while true {
        result = countingPass(result, place: place)
        if place > largest / 10 { break }        // no higher digits left
        place *= 10
    }
    return result
}`,
    * run({ items }) {
        if (!items.length) {
            yield { rows: [row('numbers', [])], vars: {}, line: 22, message: 'An empty array is already sorted.' };
            return;
        }
        const largest = Math.max(...items);
        const width = String(largest).length;
        const padded = (values) => values.map((value) => (value === null ? null : String(value).padStart(width, '0')));
        let result = [...items];
        let place = 1;
        for (;;) {
            const input = [...result];
            const digitOf = (value) => Math.floor(value / place) % 10;
            const next = Array(10).fill(0);
            input.forEach((value) => { next[digitOf(value)] += 1; });
            let total = 0;
            for (let digit = 0; digit < 10; digit += 1) {
                const count = next[digit];
                next[digit] = total;
                total += count;
            }
            const output = Array(input.length).fill(null);
            const rows = (current, extra = {}) => [
                row(`input (sorting by the ${place}s digit)`, padded(input), { marks: current === undefined ? {} : { [current]: 'swap' } }),
                row(`${place}s digit`, input.map(digitOf), { marks: current === undefined ? {} : { [current]: 'swap' } }),
                row('next position for digit 0…9', [...next]),
                row('output', padded(output), extra),
            ];
            yield { rows: rows(), vars: { place }, line: 11, message: `Count how many values have each ${place}s digit, then turn the counts into starting positions (third row): values with digit d start at index next[d].` };
            for (let index = 0; index < input.length; index += 1) {
                const digit = digitOf(input[index]);
                const at = next[digit];
                output[at] = input[index];
                next[digit] += 1;
                yield { rows: rows(index, { marks: { [at]: 'found' } }), vars: { place, digit, position: at }, line: 15, message: `${input[index]} has ${place}s digit ${digit}: it goes to index ${at}, and digit ${digit}'s next slot moves to ${at + 1}. Taking the input in order keeps the pass stable.` };
            }
            result = output;
            const done = place > Math.floor(largest / 10);
            yield { rows: [row(`after the ${place}s pass`, padded(result))], vars: { place }, line: done ? 27 : 28, message: done ? `${place * 10} is more than the largest value, ${largest}: no digits left. Sorted: ${result.join(', ')}.` : `Sorted by the last ${String(place).length} digit${place === 1 ? '' : 's'}. Next, the ${place * 10}s digit.` };
            if (done) return;
            place *= 10;
        }
    },
    result: ({ items }) => [...items].sort((a, b) => a - b),
};
