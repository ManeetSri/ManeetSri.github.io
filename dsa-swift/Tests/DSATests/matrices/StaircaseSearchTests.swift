import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct StaircaseSearchTests {
    static let sample = [
        [1, 4, 7, 11, 15],
        [2, 5, 8, 12, 19],
        [3, 6, 9, 16, 22],
        [10, 13, 14, 17, 24],
        [18, 21, 23, 26, 30],
    ]

    // True when `find` reports a real cell holding the target
    private func finds(_ target: Int, in grid: [[Int]]) -> Bool {
        guard let (row, column) = StaircaseSearch.find(target, in: grid) else { return false }
        return grid.indices.contains(row) && grid[row].indices.contains(column) && grid[row][column] == target
    }

    @Test("Finds every value in the sample grid")
    func findsEveryValue() {
        for value in Self.sample.joined() {
            #expect(finds(value, in: Self.sample), "looking for \(value)")
        }
    }

    @Test("Reports missing values", arguments: [0, 20, 25, 31, -5, 1_000])
    func missing(target: Int) {
        #expect(StaircaseSearch.find(target, in: Self.sample) == nil)
    }

    @Test("Rectangular grids and repeated values")
    func shapes() {
        let wide = [[1, 3, 5, 7], [2, 4, 6, 8]]
        #expect(finds(6, in: wide))
        #expect(finds(1, in: wide))
        #expect(finds(8, in: wide))
        #expect(StaircaseSearch.find(9, in: wide) == nil)

        let tall = [[1], [3], [5], [7]]
        #expect(finds(5, in: tall))
        #expect(StaircaseSearch.find(4, in: tall) == nil)

        let repeats = [[1, 2, 2], [2, 2, 3], [2, 3, 3]]
        #expect(finds(2, in: repeats))
        #expect(finds(3, in: repeats))
        #expect(StaircaseSearch.find(4, in: repeats) == nil)
    }

    @Test("Single cells and empty grids")
    func tiny() {
        #expect(finds(5, in: [[5]]))
        #expect(StaircaseSearch.find(4, in: [[5]]) == nil)
        #expect(StaircaseSearch.find(1, in: []) == nil)
        #expect(StaircaseSearch.find(1, in: [[]]) == nil)
    }

    @Test("Stays fast with 2,000 searches in a 1,000 × 1,000 grid")
    func large() {
        // Row r, column c holds 2r + 3c: every row and column is increasing
        let size = 1_000
        let grid = (0..<size).map { row in (0..<size).map { column in 2 * row + 3 * column } }
        var found = 0
        var missingFound = 0
        for query in 0..<2_000 {
            let target = query * 2
            if finds(target, in: grid) {
                found += 1
            }
            // Negative numbers are never in the grid
            if StaircaseSearch.find(-1 - query, in: grid) != nil {
                missingFound += 1
            }
        }
        #expect(found == 2_000)
        #expect(missingFound == 0)
        #expect(finds(2 * 999 + 3 * 999, in: grid))
        #expect(StaircaseSearch.find(2 * 999 + 3 * 999 + 1, in: grid) == nil)
    }
}
