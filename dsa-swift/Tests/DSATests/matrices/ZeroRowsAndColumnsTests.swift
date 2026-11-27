import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ZeroRowsAndColumnsTests {
    static let spreadCases: [([[Int]], [[Int]])] = [
        ([[1, 1, 1], [1, 0, 1], [1, 1, 1]], [[1, 0, 1], [0, 0, 0], [1, 0, 1]]),
        ([[0, 2, 3, 0], [4, 5, 6, 7], [8, 9, 1, 2]], [[0, 0, 0, 0], [0, 5, 6, 0], [0, 9, 1, 0]]),
        ([[5, 6], [7, 0], [8, 9]], [[5, 0], [0, 0], [8, 0]]),
        ([[1, 2, 3], [4, 5, 6]], [[1, 2, 3], [4, 5, 6]]),
        ([[1, 0], [2, 3], [0, 4]], [[0, 0], [0, 0], [0, 0]]),
        ([[3, 4, 5], [0, 6, 7]], [[0, 4, 5], [0, 0, 0]]),
        ([[7, 8, 0], [1, 2, 3]], [[0, 0, 0], [1, 2, 0]]),
    ]

    static let thinCases: [([[Int]], [[Int]])] = [
        ([[1, 0, 2]], [[0, 0, 0]]),
        ([[3], [0], [4]], [[0], [0], [0]]),
        ([[0]], [[0]]),
        ([[9]], [[9]]),
        ([[1, 2, 3]], [[1, 2, 3]]),
    ]

    private func spread(_ grid: [[Int]]) -> [[Int]] {
        var copy = grid
        ZeroRowsAndColumns.spreadZeroes(&copy)
        return copy
    }

    // The obvious version, with a list of rows and columns to clear
    private func expectedSpread(_ grid: [[Int]]) -> [[Int]] {
        var zeroRows = Set<Int>()
        var zeroColumns = Set<Int>()
        for (row, values) in grid.enumerated() {
            for (column, value) in values.enumerated() where value == 0 {
                zeroRows.insert(row)
                zeroColumns.insert(column)
            }
        }
        return grid.enumerated().map { row, values in
            values.enumerated().map { column, value in
                zeroRows.contains(row) || zeroColumns.contains(column) ? 0 : value
            }
        }
    }

    @Test("Spreads each zero along its row and column", arguments: Self.spreadCases)
    func spreads(grid: [[Int]], expected: [[Int]]) {
        #expect(spread(grid) == expected)
    }

    @Test("Single rows, single columns and single cells", arguments: Self.thinCases)
    func thin(grid: [[Int]], expected: [[Int]]) {
        #expect(spread(grid) == expected)
    }

    @Test("Negative numbers are not zeroes")
    func negatives() {
        #expect(spread([[-1, 2], [3, -4]]) == [[-1, 2], [3, -4]])
        #expect(spread([[-1, 0], [3, -4]]) == [[0, 0], [3, 0]])
    }

    @Test("An empty grid stays empty")
    func empty() {
        #expect(spread([]) == [])
    }

    @Test("Matches the obvious version on many small grids")
    func matchesObvious() {
        var firstMismatch: [[Int]]? = nil
        for seed in 0..<300 {
            let rows = 1 + seed % 4
            let columns = 1 + (seed / 4) % 4
            let grid = (0..<rows).map { row in (0..<columns).map { column in (row * 7 + column * 3 + seed) % 6 } }
            if spread(grid) != expectedSpread(grid) {
                firstMismatch = firstMismatch ?? grid
            }
        }
        #expect(firstMismatch == nil, "the first grid where the zeroes spread wrongly")
    }

    @Test("Stays fast on a 400 × 400 grid")
    func large() {
        let size = 400
        var grid = (0..<size).map { row in (0..<size).map { row * size + $0 + 1 } }
        grid[123][45] = 0
        grid[399][399] = 0
        let result = spread(grid)
        #expect(result == expectedSpread(grid))
        #expect(result[123].allSatisfy { $0 == 0 })
        #expect(result[0][45] == 0)
        #expect(result[0][0] == 1)
    }
}
