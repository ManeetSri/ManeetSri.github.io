// Generated from src/dsa/content/lessons/bs-on-answer/bsa-split-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The smallest largest sum when values[start...] is split into `parts` non-empty parts
func bestSplit(_ values: [Int], from start: Int, parts: Int) -> Int {
    if parts == 1 {
        return values[start...].reduce(0, +)
    }
    var best = Int.max
    var first = 0
    for end in start...(values.count - parts) {      // leave one value for each later part
        first += values[end]
        best = min(best, max(first, bestSplit(values, from: end + 1, parts: parts - 1)))
    }
    return best
}

print(bestSplit([4, 9, 3, 7, 2, 8], from: 0, parts: 3))
