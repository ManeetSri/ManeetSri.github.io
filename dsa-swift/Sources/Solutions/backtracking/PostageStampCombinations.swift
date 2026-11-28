// Reference solution: Postage stamp combinations. Combination sum with reuse: sort the stamps, and
// let each level choose the next stamp from index `start` onwards, passing `i` (not `i + 1`) down so
// the same stamp can be used again. Starting at `start` keeps every combination in non-decreasing
// order, so each multiset appears once. Because the stamps are sorted, the first stamp bigger than
// what's left ends the loop: every later one is bigger too.
// Time is proportional to the size of the pruned tree; O(postage / smallest stamp) extra space.

public enum PostageStampCombinations {
    public static func combinations(stamps: [Int], postage: Int) -> [[Int]] {
        let sorted = stamps.sorted()
        var result: [[Int]] = []
        var chosen: [Int] = []

        func explore(from start: Int, remaining: Int) {
            if remaining == 0 {
                result.append(chosen)
                return
            }
            for i in start..<sorted.count {
                if sorted[i] > remaining { break }                  // sorted: the rest are too big
                chosen.append(sorted[i])                            // choose
                explore(from: i, remaining: remaining - sorted[i])  // i again: reuse is allowed
                chosen.removeLast()                                 // unchoose
            }
        }

        explore(from: 0, remaining: postage)
        return result
    }
}
