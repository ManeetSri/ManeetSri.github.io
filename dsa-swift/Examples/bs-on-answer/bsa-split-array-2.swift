// Generated from src/dsa/content/lessons/bs-on-answer/bsa-split-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Fewest parts when no part may exceed `limit`. Needs limit ≥ the largest value.
func partsNeeded(_ values: [Int], limit: Int) -> Int {
    var parts = 1
    var current = 0
    for value in values {
        if current + value > limit {
            parts += 1
            current = 0
        }
        current += value
    }
    return parts
}

/// The smallest possible largest part when values are split, in order, into at most k parts.
func smallestLargestPart(_ values: [Int], parts k: Int) -> Int {
    var low = values.max()!
    var high = values.reduce(0, +)
    while low < high {
        let mid = low + (high - low) / 2
        if partsNeeded(values, limit: mid) <= k {
            high = mid
        } else {
            low = mid + 1
        }
    }
    return low
}

func bestSplit(_ values: [Int], from start: Int, parts: Int) -> Int {
    if parts == 1 { return values[start...].reduce(0, +) }
    var best = Int.max
    var first = 0
    for end in start...(values.count - parts) {
        first += values[end]
        best = min(best, max(first, bestSplit(values, from: end + 1, parts: parts - 1)))
    }
    return best
}

let values = [4, 9, 3, 7, 2, 8]
for k in 1...6 {
    let fast = smallestLargestPart(values, parts: k)
    let slow = bestSplit(values, from: 0, parts: k)
    print("k = \(k): \(fast) (brute force \(slow))")
}
