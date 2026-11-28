import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct HikeRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct GentlestHikingRouteTests {
    /// A different method: binary search on the effort, checking each guess with a BFS that only takes
    /// steps of at most that height.
    private func reference(_ heights: [[Int]]) -> Int {
        let rows = heights.count, cols = heights[0].count
        func crosses(withEffort limit: Int) -> Bool {
            var seen = Array(repeating: Array(repeating: false, count: cols), count: rows)
            seen[0][0] = true
            var queue = [(0, 0)]
            var head = 0
            while head < queue.count {
                let (row, col) = queue[head]
                head += 1
                for (dr, dc) in [(0, 1), (1, 0), (0, -1), (-1, 0)] {
                    let r = row + dr, c = col + dc
                    guard r >= 0, r < rows, c >= 0, c < cols, !seen[r][c] else { continue }
                    if abs(heights[r][c] - heights[row][col]) <= limit {
                        seen[r][c] = true
                        queue.append((r, c))
                    }
                }
            }
            return seen[rows - 1][cols - 1]
        }
        var low = 0
        var high = heights.joined().max()! - heights.joined().min()!
        while low < high {
            let mid = (low + high) / 2
            if crosses(withEffort: mid) { high = mid } else { low = mid + 1 }
        }
        return low
    }

    @Test("Examples and small grids", arguments: [
        ([[5]], 0),
        ([[1, 2, 3]], 1),
        ([[1], [7], [4]], 6),
        ([[1, 10], [2, 3]], 1),
        ([[1, 4, 2], [3, 8, 2], [5, 3, 1]], 2),
        ([[4, 4, 4], [4, 4, 4]], 0),
        ([[1, 9, 1, 1], [1, 9, 1, 9], [1, 1, 1, 9], [9, 9, 1, 1]], 0),
        ([[10, 1], [1, 10]], 9),
    ])
    func examples(heights: [[Int]], expected: Int) {
        #expect(GentlestHikingRoute.minimumEffort(heights) == expected)
    }

    @Test("Matches binary search on 300 small random grids")
    func randomSmall() {
        var random = HikeRandom(seed: 3)
        for _ in 0..<300 {
            let rows = Int.random(in: 1...6, using: &random), cols = Int.random(in: 1...6, using: &random)
            let heights = (0..<rows).map { _ in (0..<cols).map { _ in Int.random(in: 0...20, using: &random) } }
            #expect(GentlestHikingRoute.minimumEffort(heights) == reference(heights))
        }
    }

    @Test("A 300 × 300 grid with heights up to a million")
    func large() {
        var random = HikeRandom(seed: 300)
        let heights = (0..<300).map { _ in (0..<300).map { _ in Int.random(in: 0...1_000_000, using: &random) } }
        #expect(GentlestHikingRoute.minimumEffort(heights) == reference(heights))
    }

    @Test("A gentle slope with one easy path through a steep wall")
    func gentleSlope() {
        // Heights rise by 1 per column, and column 150 is a cliff except for one gap at row 299
        var heights = (0..<300).map { _ in (0..<300).map { $0 } }
        for row in 0..<299 {
            heights[row][150] = 1_000_000
        }
        #expect(GentlestHikingRoute.minimumEffort(heights) == 1)
    }
}
