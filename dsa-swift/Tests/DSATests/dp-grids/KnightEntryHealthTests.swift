import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct KnightRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct KnightEntryHealthTests {
    /// Try every path, and keep the one whose lowest running total is highest
    private func everyPath(_ dungeon: [[Int]]) -> Int {
        let rows = dungeon.count, cols = dungeon[0].count
        var best = Int.max
        func walk(_ r: Int, _ c: Int, _ total: Int, _ lowest: Int) {
            let total = total + dungeon[r][c]
            let lowest = min(lowest, total)
            if r == rows - 1 && c == cols - 1 {
                best = min(best, max(1, 1 - lowest))
                return
            }
            if c + 1 < cols { walk(r, c + 1, total, lowest) }
            if r + 1 < rows { walk(r + 1, c, total, lowest) }
        }
        walk(0, 0, 0, 0)
        return best
    }

    /// A different method: binary search on the starting health, checking each guess forwards
    private func binarySearch(_ dungeon: [[Int]]) -> Int {
        let cols = dungeon[0].count
        func survives(_ health: Int) -> Bool {
            var best = Array(repeating: 0, count: cols)        // most health after each cell, 0 if dead
            for r in dungeon.indices {
                for c in 0..<cols {
                    let arriving = r == 0 && c == 0 ? health : max(r > 0 ? best[c] : 0, c > 0 ? best[c - 1] : 0)
                    let after = arriving + dungeon[r][c]
                    best[c] = arriving > 0 && after > 0 ? after : 0
                }
            }
            return best[cols - 1] > 0
        }
        var low = 1
        var high = 1 + dungeon.joined().filter { $0 < 0 }.reduce(0) { $0 - $1 }
        while low < high {
            let mid = low + (high - low) / 2
            if survives(mid) { high = mid } else { low = mid + 1 }
        }
        return low
    }

    @Test("Examples and small dungeons", arguments: [
        ([[0, -8, 20], [-1, -1, -1], [-1, -1, 0]], 4),
        ([[-4, 3], [-2, -6]], 8),
        ([[0]], 1),
        ([[25]], 1),
        ([[-10]], 11),
        ([[2, -3, 4]], 2),
        ([[-5, 100]], 6),
        ([[100], [-5]], 1),
        ([[1, -3, 3], [0, -2, 0], [-3, -3, -3]], 3),
    ] as [([[Int]], Int)])
    func examples(dungeon: [[Int]], expected: Int) {
        #expect(KnightEntryHealth.minimumHealth(dungeon) == expected)
    }

    @Test("Matches trying every path on 300 small random dungeons")
    func randomSmall() {
        var random = KnightRandom(seed: 48)
        for _ in 0..<300 {
            let rows = Int.random(in: 1...6, using: &random)
            let cols = Int.random(in: 1...6, using: &random)
            let dungeon = (0..<rows).map { _ in (0..<cols).map { _ in Int.random(in: -12...8, using: &random) } }
            #expect(KnightEntryHealth.minimumHealth(dungeon) == everyPath(dungeon))
        }
    }

    @Test("The path with the best total isn't the safest")
    func bestTotalIsNotSafest() {
        // Going right first ends with far more health (+ 60) but opens with a -30 trap.
        let dungeon = [[0, -30, 90], [-2, -2, 0], [-2, -2, 0]]
        #expect(KnightEntryHealth.minimumHealth(dungeon) == 5)
    }

    @Test("200 × 200 random dungeons match binary search on the starting health")
    func largeRandom() {
        var random = KnightRandom(seed: 200)
        for (rows, cols) in [(200, 200), (1, 200), (200, 1), (150, 37)] {
            let dungeon = (0..<rows).map { _ in (0..<cols).map { _ in Int.random(in: -1_000...600, using: &random) } }
            #expect(KnightEntryHealth.minimumHealth(dungeon) == binarySearch(dungeon))
        }
    }
}
