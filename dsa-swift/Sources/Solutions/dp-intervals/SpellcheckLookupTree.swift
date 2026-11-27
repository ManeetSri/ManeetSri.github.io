// Reference solution: The cheapest lookup tree. Optimal BST with failed searches. With half-open ranges,
// cost[i][j] is the cheapest subtree for keys i..<j, which also holds gaps i...j (the misses that end
// up inside it). Choosing root r puts keys i..<r and gaps i...r on the left, keys r + 1..<j and gaps
// r + 1...j on the right, and every search that ends anywhere in the range pays one comparison at the
// root: the range's total hits plus misses, from prefix sums. An empty range costs 0.
// O(n³) time and O(n²) space for n keys.

public enum SpellcheckLookupTree {
    public static func cheapestCost(hits: [Int], misses: [Int]) -> Int {
        let n = hits.count
        var hitPrefix = [0]                                   // hitPrefix[i]: hits[0] + … + hits[i - 1]
        for h in hits { hitPrefix.append(hitPrefix.last! + h) }
        var missPrefix = [0]
        for m in misses { missPrefix.append(missPrefix.last! + m) }
        /// Every search ending in keys i..<j or gaps i...j
        func weight(_ i: Int, _ j: Int) -> Int {
            hitPrefix[j] - hitPrefix[i] + missPrefix[j + 1] - missPrefix[i]
        }
        var cost = Array(repeating: Array(repeating: 0, count: n + 1), count: n + 1)
        for length in stride(from: 1, through: n, by: 1) {
            for i in 0...(n - length) {
                let j = i + length
                var best = Int.max
                for r in i..<j {
                    best = min(best, cost[i][r] + cost[r + 1][j])   // left: i..<r, right: r + 1..<j
                }
                cost[i][j] = best + weight(i, j)
            }
        }
        return cost[0][n]
    }
}
