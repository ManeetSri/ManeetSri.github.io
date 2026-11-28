import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ZigzagDiagonalsTests {
    static let zigzagCases: [([[Int]], [Int])] = [
        ([[1, 2, 3], [4, 5, 6], [7, 8, 9]], [1, 2, 4, 7, 5, 3, 6, 8, 9]),
        ([[1, 2], [3, 4]], [1, 2, 3, 4]),
        ([[1, 2, 3, 4], [5, 6, 7, 8]], [1, 2, 5, 6, 3, 4, 7, 8]),
        ([[1, 2], [3, 4], [5, 6]], [1, 2, 3, 5, 4, 6]),
        ([[1, 2, 3, 4, 5]], [1, 2, 3, 4, 5]),
        ([[1], [2], [3], [4]], [1, 2, 3, 4]),
        ([[7]], [7]),
        ([[-1, 0], [0, -1]], [-1, 0, 0, -1]),
    ]

    @Test("Walks the diagonals in zigzag order", arguments: Self.zigzagCases)
    func zigzag(grid: [[Int]], expected: [Int]) {
        #expect(ZigzagDiagonals.order(grid) == expected)
    }

    @Test("An empty grid gives an empty list", arguments: [[[Int]](), [[]]])
    func empty(grid: [[Int]]) {
        #expect(ZigzagDiagonals.order(grid) == [])
    }

    @Test("Visits every cell exactly once in a wide and a tall grid")
    func everyCellOnce() {
        for (rows, columns) in [(3, 7), (7, 3), (5, 5)] {
            let grid = (0..<rows).map { row in (0..<columns).map { row * columns + $0 } }
            let walked = ZigzagDiagonals.order(grid)
            #expect(walked.sorted() == Array(0..<(rows * columns)), "\(rows) × \(columns)")
        }
    }

    @Test("Diagonals are visited in order")
    func diagonalOrder() {
        let rows = 6
        let columns = 4
        let grid = (0..<rows).map { row in (0..<columns).map { row * columns + $0 } }
        let walked = ZigzagDiagonals.order(grid)
        #expect(walked.count == rows * columns)
        // Each value is row * columns + column, so its diagonal is row + column
        let diagonals = walked.map { $0 / columns + $0 % columns }
        #expect(diagonals == diagonals.sorted(), "diagonals are visited in order 0, 1, 2, …")
    }

    @Test("Stays fast on a 300 × 300 grid")
    func large() {
        let size = 300
        let grid = (0..<size).map { row in (0..<size).map { row * size + $0 } }
        let walked = ZigzagDiagonals.order(grid)
        #expect(walked.count == size * size)
        #expect(walked.prefix(4) == [0, 1, size, 2 * size])
        #expect(walked.last == size * size - 1)
    }
}
