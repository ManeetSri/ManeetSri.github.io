// Generated from src/dsa/content/lessons/patterns/pat-templates-linear.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Prefix sums + dictionary: count, and find the longest, subarrays adding up to k
func countSumming(to k: Int, in items: [Int]) -> Int {
    var seen: [Int: Int] = [0: 1]                 // prefix value → how many times so far
    var prefix = 0
    var count = 0
    for value in items {
        prefix += value
        count += seen[prefix - k, default: 0]     // look up first...
        seen[prefix, default: 0] += 1             // ...then record
    }
    return count
}

func longestSumming(to k: Int, in items: [Int]) -> Int {
    var first: [Int: Int] = [0: -1]               // prefix value → first index it appeared after
    var prefix = 0
    var best = 0
    for (i, value) in items.enumerated() {
        prefix += value
        if let start = first[prefix - k] {
            best = max(best, i - start)
        }
        if first[prefix] == nil {                 // keep the earliest: never overwrite
            first[prefix] = i
        }
    }
    return best
}

let changes = [2, -1, 1, 3, -3, 0, 2, -2]
print(countSumming(to: 0, in: changes), longestSumming(to: 0, in: changes))
print(countSumming(to: 3, in: changes), longestSumming(to: 3, in: changes))
