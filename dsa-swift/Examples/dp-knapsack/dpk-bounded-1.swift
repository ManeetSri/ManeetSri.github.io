// Generated from src/dsa/content/lessons/dp-knapsack/dpk-bounded.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Splits k copies into pieces 1, 2, 4, … plus a remainder, so that every count 0...k is a sum of some pieces
func pieces(_ k: Int) -> [Int] {
    var result: [Int] = []
    var left = k
    var size = 1
    while size <= left {
        result.append(size)
        left -= size
        size *= 2
    }
    if left > 0 {
        result.append(left)                              // whatever is left over, less than the next power
    }
    return result
}

for k in [1, 5, 7, 13, 100] {
    print("\(k) copies:", pieces(k))
}

// Check: subsets of the pieces for 13 make every count from 0 to 13, and nothing else
let parts = pieces(13)
var counts: Set<Int> = []
for mask in 0..<(1 << parts.count) {
    counts.insert(parts.indices.filter { mask & (1 << $0) != 0 }.map { parts[$0] }.reduce(0, +))
}
print(counts.sorted())
