import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RisingIslandsTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Counts the islands the slow way after every addition: a fresh flood fill of the whole grid.
    private func modelCounts(rows: Int, columns: Int, _ land: [[Int]]) -> [Int] {
        var grid = Array(repeating: Array(repeating: false, count: columns), count: rows)
        return land.map { cell in
            grid[cell[0]][cell[1]] = true
            var seen = grid.map { $0.map { _ in false } }
            var islands = 0
            for r in 0..<rows {
                for c in 0..<columns where grid[r][c] && !seen[r][c] {
                    islands += 1
                    seen[r][c] = true
                    var stack = [(r, c)]
                    while let (row, column) = stack.popLast() {
                        for (nr, nc) in [(row - 1, column), (row + 1, column), (row, column - 1), (row, column + 1)]
                        where nr >= 0 && nr < rows && nc >= 0 && nc < columns && grid[nr][nc] && !seen[nr][nc] {
                            seen[nr][nc] = true
                            stack.append((nr, nc))
                        }
                    }
                }
            }
            return islands
        }
    }

    @Test("The example from the statement")
    func example() {
        #expect(RisingIslands.counts(rows: 3, columns: 4, [[0, 0], [0, 1], [2, 2], [1, 3], [2, 3], [1, 0], [0, 3], [1, 2], [1, 1]])
            == [1, 1, 2, 3, 2, 2, 2, 2, 1])
    }

    @Test("Diagonal cells don't join")
    func diagonals() {
        #expect(RisingIslands.counts(rows: 2, columns: 2, [[0, 0], [1, 1], [0, 1]]) == [1, 2, 1])
        #expect(RisingIslands.counts(rows: 3, columns: 3, [[0, 0], [1, 1], [2, 2], [0, 2], [2, 0], [1, 0], [1, 2]])
            == [1, 2, 3, 4, 5, 3, 1])
    }

    @Test("A cell that's already land changes nothing")
    func repeats() {
        #expect(RisingIslands.counts(rows: 1, columns: 1, [[0, 0], [0, 0]]) == [1, 1])
        #expect(RisingIslands.counts(rows: 2, columns: 3, [[0, 0], [0, 2], [0, 0], [0, 1], [0, 2]]) == [1, 2, 2, 1, 1])
    }

    @Test("No land at all")
    func empty() {
        #expect(RisingIslands.counts(rows: 4, columns: 5, []) == [])
    }

    @Test("Joining four islands at once")
    func fourWayJoin() {
        #expect(RisingIslands.counts(rows: 3, columns: 3, [[0, 1], [1, 0], [1, 2], [2, 1], [1, 1]]) == [1, 2, 3, 4, 1])
    }

    @Test("Random additions match a fresh flood fill each time", arguments: Array(1...8))
    func random(seed: UInt64) {
        var steps = Steps(seed: seed)
        let rows = 1 + steps.next(below: 7)
        let columns = 1 + steps.next(below: 8)
        let land = (0..<steps.next(below: rows * columns + 5)).map { _ in [steps.next(below: rows), steps.next(below: columns)] }
        #expect(RisingIslands.counts(rows: rows, columns: columns, land) == modelCounts(rows: rows, columns: columns, land))
    }

    @Test("A 300 × 300 checkerboard fills in")
    func checkerboard() throws {
        // First every cell with (row + column) even: 45,000 separate islands. Then the rest, which
        // joins them all into one. Re-counting with a flood fill after each step would take billions of steps.
        let size = 300
        var land: [[Int]] = []
        for parity in [0, 1] {
            for row in 0..<size {
                for column in 0..<size where (row + column) % 2 == parity {
                    land.append([row, column])
                }
            }
        }
        let counts = RisingIslands.counts(rows: size, columns: size, land)
        try #require(counts.count == size * size)
        #expect(counts[44_999] == 45_000)
        #expect(counts[45_000] == 45_000 - 2)          // (0, 1) joins (0, 0), (0, 2) and (1, 1)
        #expect(counts.last == 1)
    }
}
