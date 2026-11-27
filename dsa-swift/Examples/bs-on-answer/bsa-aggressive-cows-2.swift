// Generated from src/dsa/content/lessons/bs-on-answer/bsa-aggressive-cows.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func canPlace(_ cows: Int, in sortedStalls: [Int], gap: Int) -> Bool {
    var placed = 1
    var last = sortedStalls[0]
    for stall in sortedStalls.dropFirst() where stall - last >= gap {
        placed += 1
        last = stall
    }
    return placed >= cows
}

func largestMinimumGap(_ stalls: [Int], cows: Int) -> Int {
    let sorted = stalls.sorted()
    let span = sorted[sorted.count - 1] - sorted[0]
    var low = 1                                  // a gap of 1 always works
    var high = span / (cows - 1) + 1             // a gap this big always fails
    while low < high {
        let mid = low + (high - low) / 2
        if canPlace(cows, in: sorted, gap: mid) {
            low = mid + 1                        // mid works: the first failure is later
        } else {
            high = mid                           // mid fails: it could be the first failure
        }
    }
    return low - 1                               // the last gap that works
}

let stalls = [3, 14, 1, 9, 6, 17]
print(largestMinimumGap(stalls, cows: 2))
print(largestMinimumGap(stalls, cows: 3))
print(largestMinimumGap(stalls, cows: 4))
print(largestMinimumGap(stalls, cows: 6))
