import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GridRegionSumsTests {
    typealias Table = GridRegionSums.Table

    static let grid = [
        [3, 0, 1, 4],
        [5, 6, 3, 2],
        [1, 2, 0, 1],
    ]

    @Test("Sums rectangles of the example grid", arguments: [
        (1, 1, 2, 2, 11),
        (0, 0, 2, 3, 28),
        (0, 3, 1, 3, 6),
        (0, 0, 0, 0, 3),
        (2, 3, 2, 3, 1),
        (1, 0, 1, 3, 16),
        (0, 1, 2, 1, 8),
        (0, 0, 1, 1, 14),
    ])
    func example(top: Int, left: Int, bottom: Int, right: Int, expected: Int) {
        let table = Table(Self.grid)
        #expect(table.sum(top: top, left: left, bottom: bottom, right: right) == expected)
    }

    @Test("Handles negative numbers")
    func negatives() {
        let table = Table([
            [-1, 2, -3],
            [4, -5, 6],
        ])
        #expect(table.sum(top: 0, left: 0, bottom: 1, right: 2) == 3)
        #expect(table.sum(top: 0, left: 1, bottom: 1, right: 1) == -3)
        #expect(table.sum(top: 1, left: 0, bottom: 1, right: 2) == 5)
    }

    @Test("Works for a single row, a single column and a single cell")
    func thinGrids() {
        let row = Table([[1, 2, 3, 4]])
        #expect(row.sum(top: 0, left: 1, bottom: 0, right: 3) == 9)
        let column = Table([[1], [2], [3], [4]])
        #expect(column.sum(top: 2, left: 0, bottom: 3, right: 0) == 7)
        #expect(Table([[-9]]).sum(top: 0, left: 0, bottom: 0, right: 0) == -9)
    }

    @Test("Building a table for an empty grid doesn't crash")
    func empty() {
        _ = Table([])
    }

    @Test("Matches adding up every cell on many small grids")
    func matchesBruteForce() {
        var mismatches = 0
        for seed in 0..<25 {
            let rows = seed % 4 + 1
            let columns = seed % 5 + 1
            let grid = (0..<rows).map { r in (0..<columns).map { c in (r * 7 + c * 3 + seed) % 11 - 5 } }
            let table = Table(grid)
            for top in 0..<rows {
                for bottom in top..<rows {
                    for left in 0..<columns {
                        for right in left..<columns {
                            var expected = 0
                            for r in top...bottom {
                                for c in left...right {
                                    expected += grid[r][c]
                                }
                            }
                            if table.sum(top: top, left: left, bottom: bottom, right: right) != expected {
                                mismatches += 1
                            }
                        }
                    }
                }
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Answers 100,000 queries on a 300 × 300 grid quickly")
    func large() {
        let size = 300
        let grid = (0..<size).map { r in (0..<size).map { c in r + c } }
        let table = Table(grid)
        var mismatches = 0
        for q in 0..<100_000 {
            let top = (q * 31) % size
            let left = (q * 17) % size
            let bottom = min(size - 1, top + (q * 7) % 200)
            let right = min(size - 1, left + (q * 13) % 200)
            let height = bottom - top + 1
            let width = right - left + 1
            // Every cell is r + c: each row index appears width times, each column index height times
            let expected = width * (top + bottom) * height / 2 + height * (left + right) * width / 2
            if table.sum(top: top, left: left, bottom: bottom, right: right) != expected {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }
}
