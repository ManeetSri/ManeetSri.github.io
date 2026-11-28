import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct MazeRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct MazeRunnerPathsTests {
    /// A search that carries a set of visited cells and a string, then sorts: slow, but clearly right
    private func reference(_ maze: [[Int]]) -> [String] {
        let rows = maze.count
        let columns = maze[0].count
        guard maze[0][0] == 1, maze[rows - 1][columns - 1] == 1 else { return [] }
        var found: [String] = []
        func walk(_ row: Int, _ column: Int, _ visited: Set<Int>, _ route: String) {
            if row == rows - 1 && column == columns - 1 {
                found.append(route)
                return
            }
            for (letter, dRow, dColumn) in [("U", -1, 0), ("R", 0, 1), ("L", 0, -1), ("D", 1, 0)] {
                let r = row + dRow, c = column + dColumn
                if r >= 0, r < rows, c >= 0, c < columns, maze[r][c] == 1, !visited.contains(r * columns + c) {
                    walk(r, c, visited.union([r * columns + c]), route + letter)
                }
            }
        }
        walk(0, 0, [0], "")
        return found.sorted()
    }

    @Test("Examples and small cases", arguments: [
        ([[1, 0, 0], [1, 1, 0], [0, 1, 1]], ["DRDR"]),
        ([[1, 1], [1, 1]], ["DR", "RD"]),
        ([[1, 1, 1], [1, 0, 1], [1, 1, 1]], ["DDRR", "RRDD"]),
        ([[1, 0], [0, 1]], []),
        ([[0, 1], [1, 1]], []),
        ([[1, 1], [1, 0]], []),
        ([[1]], [""]),
        ([[0]], []),
        ([[1, 1, 1, 1]], ["RRR"]),
    ] as [([[Int]], [String])])
    func examples(maze: [[Int]], expected: [String]) {
        #expect(MazeRunnerPaths.paths(maze) == expected)
    }

    @Test("A route can go up and left as well as down and right")
    func backwards() {
        let maze = [[1, 1, 1],
                    [0, 0, 1],
                    [1, 1, 1],
                    [1, 0, 0],
                    [1, 1, 1]]
        #expect(MazeRunnerPaths.paths(maze) == ["RRDDLLDDRR"])
        let open = [[1, 1, 1], [1, 1, 1]]
        #expect(MazeRunnerPaths.paths(open) == ["DRR", "DRURD", "RDR", "RRD"])
    }

    @Test("Matches a set-based search on 300 random mazes")
    func randomSmall() {
        var random = MazeRandom(seed: 48)
        for _ in 0..<300 {
            let rows = Int.random(in: 1...4, using: &random)
            let columns = Int.random(in: 1...4, using: &random)
            let maze = (0..<rows).map { _ in (0..<columns).map { _ in Int.random(in: 0..<4, using: &random) == 0 ? 0 : 1 } }
            #expect(MazeRunnerPaths.paths(maze) == reference(maze), "maze \(maze)")
        }
    }

    @Test("Open mazes: 184 routes across 4 × 4 and 8,512 across 5 × 5, in alphabetical order")
    func openMazes() {
        let four = MazeRunnerPaths.paths(Array(repeating: Array(repeating: 1, count: 4), count: 4))
        #expect(four == reference(Array(repeating: Array(repeating: 1, count: 4), count: 4)))
        #expect(four.count == 184)
        let five = MazeRunnerPaths.paths(Array(repeating: Array(repeating: 1, count: 5), count: 5))
        #expect(five.count == 8_512)
        #expect(five == five.sorted())
        #expect(Set(five).count == 8_512)
        #expect(five.first == "DDDDRRRR")
    }
}
