// Reference solution: The shortest strand holding every fragment. Since no fragment sits inside another,
// the fragments appear in the strand in some order, each one starting after the previous one starts,
// and the best strand for an order overlaps each neighbouring pair as much as possible. So the strand
// is the total length minus the overlaps saved, and choosing the order is a TSP-style path problem:
// saved[mask][last] = most letters saved by a chain using exactly the fragments in mask, ending with
// last. Any fragment can start the chain, and there's no return trip.
// O(n² · L²) to compute the overlaps (L = longest fragment), then O(2ⁿ · n²) time and O(2ⁿ · n) space.

public enum ShortestCommonStrand {
    public static func shortestLength(_ fragments: [String]) -> Int {
        let words = fragments.map { Array($0.utf8) }
        let n = words.count
        if n == 0 { return 0 }

        // overlap[i][j]: the longest suffix of i that is also a prefix of j
        var overlap = [[Int]](repeating: [Int](repeating: 0, count: n), count: n)
        for i in 0..<n {
            for j in 0..<n where i != j {
                let a = words[i], b = words[j]
                for k in stride(from: min(a.count, b.count) - 1, through: 1, by: -1)
                where a[(a.count - k)...] == b[..<k] {
                    overlap[i][j] = k
                    break
                }
            }
        }

        let full = 1 << n
        var saved = [Int](repeating: -1, count: full * n)      // -1: no chain like that yet
        for v in 0..<n {
            saved[(1 << v) * n + v] = 0
        }
        for mask in 1..<full {
            for last in 0..<n where mask & (1 << last) != 0 {
                let here = saved[mask * n + last]
                if here < 0 { continue }
                for next in 0..<n where mask & (1 << next) == 0 {
                    let grown = (mask | (1 << next)) * n + next
                    saved[grown] = max(saved[grown], here + overlap[last][next])
                }
            }
        }
        let bestSaving = (0..<n).map { saved[(full - 1) * n + $0] }.max()!
        return words.reduce(0) { $0 + $1.count } - bestSaving
    }
}
