import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct WallRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct FewestWallsToBreakTests {
    /// Relaxes every cell from its neighbours until nothing changes. Slow, but clearly right.
    private func reference(_ grid: [[Int]]) -> Int {
        let rows = grid.count, cols = grid[0].count
        var walls = Array(repeating: Array(repeating: Int.max, count: cols), count: rows)
        walls[0][0] = 0
        var changed = true
        while changed {
            changed = false
            for row in 0..<rows {
                for col in 0..<cols where walls[row][col] != Int.max {
                    for (dr, dc) in [(0, 1), (1, 0), (0, -1), (-1, 0)] {
                        let r = row + dr, c = col + dc
                        guard r >= 0, r < rows, c >= 0, c < cols else { continue }
                        if walls[row][col] + grid[r][c] < walls[r][c] {
                            walls[r][c] = walls[row][col] + grid[r][c]
                            changed = true
                        }
                    }
                }
            }
        }
        return walls[rows - 1][cols - 1]
    }

    /// A random grid with the start and end cells open
    private func randomGrid(rows: Int, cols: Int, wallChance: Int, using random: inout WallRandom) -> [[Int]] {
        var grid = (0..<rows).map { _ in (0..<cols).map { _ in Int.random(in: 0..<100, using: &random) < wallChance ? 1 : 0 } }
        grid[0][0] = 0
        grid[rows - 1][cols - 1] = 0
        return grid
    }

    @Test("Examples and small grids", arguments: [
        ([[0]], 0),
        ([[0, 0], [0, 0]], 0),
        ([[0, 1], [1, 0]], 1),
        ([[0, 1, 1], [1, 1, 0], [1, 1, 0]], 2),
        ([[0, 1, 0, 0], [0, 1, 0, 1], [0, 0, 0, 1], [1, 1, 1, 0]], 1),
        ([[0, 1, 1, 1, 0]], 3),
        ([[0], [1], [0], [1], [0]], 2),
        ([[0, 0, 0], [1, 1, 0], [0, 0, 0], [0, 1, 1], [0, 0, 0]], 0),
    ])
    func examples(grid: [[Int]], expected: Int) {
        #expect(FewestWallsToBreak.minimumWalls(grid) == expected)
    }

    @Test("Matches the slow reference on 300 small random grids")
    func randomSmall() {
        var random = WallRandom(seed: 27)
        for _ in 0..<300 {
            let grid = randomGrid(rows: Int.random(in: 1...7, using: &random), cols: Int.random(in: 1...7, using: &random),
                                  wallChance: Int.random(in: 0...90, using: &random), using: &random)
            #expect(FewestWallsToBreak.minimumWalls(grid) == reference(grid))
        }
    }

    @Test("300 × 300 grids with known answers")
    func large() {
        // Solid walls except the start and the end: every cell entered on the way is a wall except the last
        var solid = Array(repeating: Array(repeating: 1, count: 300), count: 300)
        solid[0][0] = 0
        solid[299][299] = 0
        #expect(FewestWallsToBreak.minimumWalls(solid) == 300 + 300 - 3)

        // Walls everywhere except a snake that winds down through every other row
        var snake = Array(repeating: Array(repeating: 1, count: 300), count: 300)
        for row in stride(from: 0, to: 300, by: 2) {
            for col in 0..<300 { snake[row][col] = 0 }
            if row + 1 < 300 { snake[row + 1][(row / 2) % 2 == 0 ? 299 : 0] = 0 }
        }
        snake[299][299] = 0
        #expect(FewestWallsToBreak.minimumWalls(snake) == 0)
        snake[298][299] = 1                     // block the last step: now one wall must go
        snake[299][0] = 1
        #expect(FewestWallsToBreak.minimumWalls(snake) == 1)

        // No walls at all
        #expect(FewestWallsToBreak.minimumWalls(Array(repeating: Array(repeating: 0, count: 300), count: 300)) == 0)
    }

    @Test("A random 120 × 120 grid matches the slow reference")
    func randomMedium() {
        var random = WallRandom(seed: 120)
        let grid = randomGrid(rows: 120, cols: 120, wallChance: 55, using: &random)
        #expect(FewestWallsToBreak.minimumWalls(grid) == reference(grid))
    }
}
