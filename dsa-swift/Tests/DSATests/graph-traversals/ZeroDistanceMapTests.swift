import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ZeroDistanceMapTests {
    @Test("Distances to the nearest zero")
    func examples() {
        #expect(ZeroDistanceMap.distances([[0, 0, 0], [0, 1, 0], [1, 1, 1]]) == [[0, 0, 0], [0, 1, 0], [1, 2, 1]])
        #expect(ZeroDistanceMap.distances([[1, 1, 1], [1, 0, 1], [1, 1, 1]]) == [[2, 1, 2], [1, 0, 1], [2, 1, 2]])
        #expect(ZeroDistanceMap.distances([[0, 1, 1, 1, 1]]) == [[0, 1, 2, 3, 4]])
        #expect(ZeroDistanceMap.distances([[1, 1, 0, 1, 1]]) == [[2, 1, 0, 1, 2]])
        #expect(ZeroDistanceMap.distances([[0, 1, 1, 1, 1, 1, 0]]) == [[0, 1, 2, 3, 2, 1, 0]])
        #expect(ZeroDistanceMap.distances([[1], [1], [0]]) == [[2], [1], [0]])
        #expect(ZeroDistanceMap.distances([[1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 0]])
            == [[5, 4, 3, 2], [4, 3, 2, 1], [3, 2, 1, 0]])
    }

    @Test("Tiny grids and grids with no zero")
    func edges() {
        #expect(ZeroDistanceMap.distances([[0]]) == [[0]])
        #expect(ZeroDistanceMap.distances([[1]]) == [[-1]])
        #expect(ZeroDistanceMap.distances([[1, 1], [1, 1]]) == [[-1, -1], [-1, -1]])
        #expect(ZeroDistanceMap.distances([]) == [])
    }

    @Test("One zero in the corner of a 1000 × 1000 grid")
    func oneZero() {
        // BFS from every 1 separately would cost about 10¹² steps here
        let size = 1_000
        var grid = Array(repeating: Array(repeating: 1, count: size), count: size)
        grid[0][0] = 0
        let expected = (0..<size).map { row in (0..<size).map { row + $0 } }
        expectSameGrid(ZeroDistanceMap.distances(grid), expected, "one zero in the corner")
    }

    @Test("A whole row of zeros along the bottom")
    func zeroRow() {
        let size = 1_000
        var grid = Array(repeating: Array(repeating: 1, count: size), count: size)
        grid[size - 1] = Array(repeating: 0, count: size)
        let expected = (0..<size).map { row in Array(repeating: size - 1 - row, count: size) }
        expectSameGrid(ZeroDistanceMap.distances(grid), expected, "a row of zeros")
    }

    @Test("A checkerboard of zeros")
    func checkerboard() {
        let size = 1_000
        let grid = (0..<size).map { row in (0..<size).map { ($0 + row) % 2 } }
        expectSameGrid(ZeroDistanceMap.distances(grid), grid, "checkerboard")
    }
}

/// Compares two big grids and reports only the first difference, rather than printing a million
/// values when they don't match
private func expectSameGrid<T: Equatable>(_ actual: [[T]], _ expected: [[T]], _ what: String) {
    guard actual.count == expected.count else {
        Issue.record("\(what): expected \(expected.count) rows, got \(actual.count)")
        return
    }
    for row in expected.indices where actual[row] != expected[row] {
        guard actual[row].count == expected[row].count else {
            Issue.record("\(what): row \(row) should have \(expected[row].count) cells, not \(actual[row].count)")
            return
        }
        let column = expected[row].indices.first { actual[row][$0] != expected[row][$0] }!
        Issue.record("\(what): cell (\(row), \(column)) should be \(expected[row][column]), not \(actual[row][column])")
        return
    }
}
