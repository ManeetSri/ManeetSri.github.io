// Binary search as a list of frames. Each frame is one step: the search range, the middle index, the
// line of Swift that's running, and what's happening in words. The view draws a frame; the player
// moves between them.
export const BINARY_SEARCH_SWIFT = `func binarySearch(_ items: [Int], for target: Int) -> Int? {
    var low = 0
    var high = items.count - 1
    while low <= high {
        let mid = low + (high - low) / 2
        if items[mid] == target {
            return mid
        } else if items[mid] < target {
            low = mid + 1
        } else {
            high = mid - 1
        }
    }
    return nil
}`;

export const binarySearchFrames = (items, target) => {
    const frames = [];
    const frame = (fields) => frames.push({ low: null, high: null, mid: null, found: null, done: false, ...fields });
    let low = 0;
    let high = items.length - 1;
    frame({ low, high, line: 3, message: `Search the whole array for ${target}: low = 0, high = ${high}.` });

    while (low <= high) {
        frame({ low, high, line: 4, message: `low (${low}) ≤ high (${high}), so there's still a range to search.` });
        const mid = low + Math.floor((high - low) / 2);
        frame({ low, high, mid, line: 5, message: `The middle index is ${mid}, holding ${items[mid]}.` });
        if (items[mid] === target) {
            frame({ low, high, mid, found: mid, done: true, line: 7, message: `${items[mid]} is the target. Found it at index ${mid}.` });
            return frames;
        }
        if (items[mid] < target) {
            frame({ low, high, mid, line: 9, message: `${items[mid]} < ${target}, so everything up to index ${mid} is too small. Move low to ${mid + 1}.` });
            low = mid + 1;
        } else {
            frame({ low, high, mid, line: 11, message: `${items[mid]} > ${target}, so everything from index ${mid} on is too big. Move high to ${mid - 1}.` });
            high = mid - 1;
        }
    }
    frame({ low, high, done: true, line: 14, message: `low (${low}) passed high (${high}): ${target} isn't in the array.` });
    return frames;
};
