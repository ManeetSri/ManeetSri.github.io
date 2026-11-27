import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run builds the same grids
private struct PathCounterRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct ShortestPathCounterFixTests {
    private let modulus = 1_000_000_007

    /// Brute force without BFS: count the walks of length 1, 2, 3, ... from S, step by step. The first
    /// length at which some walk reaches G is the shortest distance, and every walk of that length to
    /// G is a shortest path. Only for small grids, where the counts stay small.
    private func walkCount(_ rows: [String]) -> Int {
        let grid = rows.map { Array($0) }
        let height = grid.count, width = grid[0].count
        var ways = Array(repeating: Array(repeating: 0, count: width), count: height)
        var goal = (0, 0)
        for r in 0..<height {
            for c in 0..<width {
                if grid[r][c] == "S" { ways[r][c] = 1 }
                if grid[r][c] == "G" { goal = (r, c) }
            }
        }
        for _ in 0..<(height * width) {
            var next = Array(repeating: Array(repeating: 0, count: width), count: height)
            for r in 0..<height {
                for c in 0..<width where grid[r][c] != "#" {
                    for (dr, dc) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                        let pr = r + dr, pc = c + dc
                        if pr >= 0, pr < height, pc >= 0, pc < width { next[r][c] += ways[pr][pc] }
                    }
                }
            }
            ways = next
            if ways[goal.0][goal.1] > 0 { return ways[goal.0][goal.1] }
        }
        return 0
    }

    @Test("Small grids, counted by hand", arguments: [
        (["SG"], 1),
        (["S.", ".G"], 2),
        (["S#", ".G"], 1),
        (["S#", "#G"], 0),
        (["S..", "...", "..G"], 6),
        (["S...G"], 1),
        (["S.#", "...", "#.G"], 4),
        ([".S.", "...", ".G."], 1),
        (["S..", ".#.", "..G"], 2),
        (["G..", "...", "..S"], 6),
        (["S", ".", ".", "G"], 1),
        (["...", "S#G", "..."], 2),
    ])
    func small(rows: [String], expected: Int) {
        #expect(ShortestPathCounterFix.count(rows) == expected)
    }

    @Test("Walls that cut the goal off give 0")
    func unreachable() {
        #expect(ShortestPathCounterFix.count(["S.#..", "..#.G", "..#.."]) == 0)
        #expect(ShortestPathCounterFix.count(["S", "#", "G"]) == 0)
    }

    @Test("Matches counting walks on random small grids")
    func randomGrids() {
        var random = PathCounterRandom(seed: 71)
        var firstMismatch: String? = nil
        for _ in 0..<300 where firstMismatch == nil {
            let height = Int.random(in: 1...5, using: &random)
            let width = Int.random(in: 1...5, using: &random)
            guard height * width >= 2 else { continue }
            var cells = (0..<(height * width)).map { _ -> Character in
                Int.random(in: 0..<4, using: &random) == 0 ? "#" : "."
            }
            let s = Int.random(in: 0..<cells.count, using: &random)
            var g = Int.random(in: 0..<(cells.count - 1), using: &random)
            if g >= s { g += 1 }
            cells[s] = "S"
            cells[g] = "G"
            let rows = (0..<height).map { String(cells[($0 * width)..<($0 * width + width)]) }
            let got = ShortestPathCounterFix.count(rows)
            let expected = walkCount(rows)
            if got != expected {
                firstMismatch = "\(rows): got \(got), expected \(expected)"
            }
        }
        #expect(firstMismatch == nil)
    }

    @Test("A 600 × 600 open grid: the count overflows Int long before the corner, so it's taken modulo 1,000,000,007")
    func largeOpenGrid() {
        let size = 600
        var rows = Array(repeating: String(repeating: ".", count: size), count: size)
        rows[0] = "S" + String(repeating: ".", count: size - 1)
        rows[size - 1] = String(repeating: ".", count: size - 1) + "G"
        // Corner to corner, every shortest path only moves right and down: Pascal's triangle
        var row = Array(repeating: 1, count: size)
        for _ in 1..<size {
            for c in 1..<size { row[c] = (row[c] + row[c - 1]) % modulus }
        }
        #expect(ShortestPathCounterFix.count(rows) == row[size - 1])
    }

    @Test("A 600 × 600 grid with walls in a regular pattern")
    func largeWalledGrid() {
        // A wall on every cell whose row and column are both odd: the open cells form a lattice. S and
        // G sit in the middle of opposite edges.
        let size = 601
        var rows: [String] = []
        rows.reserveCapacity(size)
        for r in 0..<size {
            var line = ""
            for c in 0..<size {
                if r == 0 && c == 300 { line.append("S") }
                else if r == size - 1 && c == 300 { line.append("G") }
                else { line.append(r % 2 == 1 && c % 2 == 1 ? "#" : ".") }
            }
            rows.append(line)
        }
        // Column 300 is even, so it's a straight open corridor of length 600: the only path that never
        // steps sideways. Any sideways step must be undone, which makes the path longer.
        #expect(ShortestPathCounterFix.count(rows) == 1)
    }

    @Test("A long thin grid is fast too")
    func longCorridor() {
        let width = 200_000
        let rows = ["S" + String(repeating: ".", count: width - 2) + "G",
                    String(repeating: ".", count: width)]
        #expect(ShortestPathCounterFix.count(rows) == 1)
        let twoRows = ["S" + String(repeating: ".", count: width - 1),
                       String(repeating: ".", count: width - 1) + "G"]
        // One step down somewhere along the way: width choices of where to take it
        #expect(ShortestPathCounterFix.count(twoRows) == width)
    }
}
