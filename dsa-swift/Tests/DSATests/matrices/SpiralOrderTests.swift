import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SpiralOrderTests {
    static let spiralCases: [([[Int]], [Int])] = [
        ([[1, 2, 3], [4, 5, 6], [7, 8, 9]], [1, 2, 3, 6, 9, 8, 7, 4, 5]),
        ([[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]], [1, 2, 3, 4, 8, 12, 11, 10, 9, 5, 6, 7]),
        ([[1, 2], [3, 4], [5, 6], [7, 8]], [1, 2, 4, 6, 8, 7, 5, 3]),
        ([[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16]],
         [1, 2, 3, 4, 8, 12, 16, 15, 14, 13, 9, 5, 6, 7, 11, 10]),
        ([[1, 2], [3, 4]], [1, 2, 4, 3]),
    ]

    static let thinCases: [([[Int]], [Int])] = [
        ([[1, 2, 3, 4]], [1, 2, 3, 4]),
        ([[1], [2], [3]], [1, 2, 3]),
        ([[5]], [5]),
        ([[1, 2, 3], [4, 5, 6]], [1, 2, 3, 6, 5, 4]),
        ([[1, 2], [3, 4], [5, 6]], [1, 2, 4, 6, 5, 3]),
        ([[1, 2, 3, 4, 5], [6, 7, 8, 9, 10], [11, 12, 13, 14, 15]], [1, 2, 3, 4, 5, 10, 15, 14, 13, 12, 11, 6, 7, 8, 9]),
    ]

    @Test("Walks the grid in a clockwise spiral", arguments: Self.spiralCases)
    func spiral(grid: [[Int]], expected: [Int]) {
        #expect(SpiralOrder.values(grid) == expected)
    }

    @Test("A single row or column is walked once", arguments: Self.thinCases)
    func thin(grid: [[Int]], expected: [Int]) {
        #expect(SpiralOrder.values(grid) == expected)
    }

    @Test("An empty grid gives an empty list", arguments: [[[Int]](), [[]]])
    func empty(grid: [[Int]]) {
        #expect(SpiralOrder.values(grid) == [])
    }

    @Test("Visits every cell exactly once in many shapes")
    func everyCellOnce() {
        var firstFailure: String? = nil
        for rows in 1...7 {
            for columns in 1...7 {
                let grid = (0..<rows).map { row in (0..<columns).map { row * columns + $0 } }
                if SpiralOrder.values(grid).sorted() != Array(0..<(rows * columns)) {
                    firstFailure = firstFailure ?? "\(rows) × \(columns)"
                }
            }
        }
        #expect(firstFailure == nil, "the first grid shape that wasn't walked exactly once")
    }

    @Test("Stays fast on a 400 × 300 grid")
    func large() {
        let rows = 400
        let columns = 300
        let grid = (0..<rows).map { row in (0..<columns).map { row * columns + $0 } }
        let walked = SpiralOrder.values(grid)
        #expect(walked.count == rows * columns)
        #expect(walked.prefix(3) == [0, 1, 2])
        #expect(walked.dropFirst(columns).first == columns + (columns - 1))
    }
}
