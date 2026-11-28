import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CrateRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RobotRoutesAroundCratesTests {
    /// Walk every route recursively. Exponential, but clearly right on small floors.
    private func reference(_ floor: [[Int]]) -> Int {
        let rows = floor.count, cols = floor[0].count
        func walk(_ r: Int, _ c: Int) -> Int {
            if r >= rows || c >= cols || floor[r][c] == 1 { return 0 }
            if r == rows - 1 && c == cols - 1 { return 1 }
            return walk(r, c + 1) + walk(r + 1, c)
        }
        return walk(0, 0)
    }

    /// C(n, k) from Pascal's triangle, which only adds
    private func choose(_ n: Int, _ k: Int) -> Int {
        var row = [1]
        for _ in 0..<n {
            row = [1] + zip(row, row.dropFirst()).map { $0 + $1 } + [1]
        }
        return row[k]
    }

    @Test("Examples and small floors", arguments: [
        ([[0, 0, 1], [0, 0, 0]], 2),
        ([[0, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 0]], 4),
        ([[0, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1], [1, 0, 0, 0]], 3),
        ([[0]], 1),
        ([[1]], 0),
        ([[0, 1], [1, 0]], 0),
        ([[1, 0], [0, 0]], 0),
        ([[0, 0], [0, 1]], 0),
        ([[0, 0, 0, 0, 0]], 1),
        ([[0], [0], [1], [0]], 0),
        ([[0, 1, 0], [0, 0, 0], [0, 1, 0]], 1),
        ([[0, 0], [0, 0]], 2),
    ] as [([[Int]], Int)])
    func examples(floor: [[Int]], expected: Int) {
        #expect(RobotRoutesAroundCrates.routes(floor) == expected)
    }

    @Test("Matches walking every route on 500 small random floors")
    func randomSmall() {
        var random = CrateRandom(seed: 52)
        for _ in 0..<500 {
            let rows = Int.random(in: 1...7, using: &random)
            let cols = Int.random(in: 1...7, using: &random)
            let crateChance = Int.random(in: 0...35, using: &random)
            let floor = (0..<rows).map { _ in
                (0..<cols).map { _ in Int.random(in: 0..<100, using: &random) < crateChance ? 1 : 0 }
            }
            #expect(RobotRoutesAroundCrates.routes(floor) == reference(floor))
        }
    }

    @Test("Open floors match the combination formula")
    func openFloors() {
        for (rows, cols) in [(3, 7), (10, 10), (1, 33), (33, 1), (17, 17), (20, 33)] {
            let floor = Array(repeating: Array(repeating: 0, count: cols), count: rows)
            #expect(RobotRoutesAroundCrates.routes(floor) == choose(rows + cols - 2, rows - 1))
        }
    }

    @Test("The largest floor: 33 × 33 with no crates has about 1.8 × 10¹⁸ routes")
    func largestOpenFloor() {
        let floor = Array(repeating: Array(repeating: 0, count: 33), count: 33)
        #expect(RobotRoutesAroundCrates.routes(floor) == 1_832_624_140_942_590_534)
    }

    @Test("A wall with one gap: billions of routes, far too many to walk one by one")
    func wallWithGap() {
        // Row 10 of a 20 × 20 floor is all crates except column 7. Every route reaches (9, 7), steps
        // down through the gap to (10, 7), must step down again to (11, 7) (the cell to its right is a
        // crate), then crosses the rest of the lower half.
        var floor = Array(repeating: Array(repeating: 0, count: 20), count: 20)
        for c in 0..<20 where c != 7 {
            floor[10][c] = 1
        }
        #expect(RobotRoutesAroundCrates.routes(floor) == choose(16, 7) * choose(20, 8))

        // Close the gap and nothing gets through
        floor[10][7] = 1
        #expect(RobotRoutesAroundCrates.routes(floor) == 0)
    }

    @Test("A crate in the first row or column blocks everything beyond it on that edge")
    func edgeCrates() {
        // With a crate at (0, 2), the cells (0, 3) and (0, 4) can't be reached along the top
        var floor = Array(repeating: Array(repeating: 0, count: 5), count: 2)
        floor[0][2] = 1
        // Routes on a 2 × 5 floor drop down once; dropping at column 2 or later would pass the crate,
        // so only drops at columns 0 and 1 remain
        #expect(RobotRoutesAroundCrates.routes(floor) == 2)
    }
}
