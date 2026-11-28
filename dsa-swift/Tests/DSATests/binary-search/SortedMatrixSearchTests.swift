import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SortedMatrixSearchTests {
    static let sample = [
        [2, 4, 7, 11],
        [14, 18, 21, 25],
        [30, 33, 41, 49],
    ]

    /// The answer as an array, so tests can compare it: [row, column], or [] for nil.
    private func found(_ target: Int, in grid: [[Int]]) -> [Int] {
        guard let (row, column) = SortedMatrixSearch.position(of: target, in: grid) else { return [] }
        return [row, column]
    }

    @Test("Finds every value in the sample")
    func findsEveryValue() {
        for (row, values) in Self.sample.enumerated() {
            for (column, value) in values.enumerated() {
                #expect(found(value, in: Self.sample) == [row, column], "looking for \(value)")
            }
        }
    }

    @Test("Reports missing values", arguments: [1, 3, 12, 13, 26, 29, 50, -4])
    func missing(target: Int) {
        #expect(found(target, in: Self.sample) == [])
    }

    @Test("Empty grids and empty rows")
    func empty() {
        #expect(found(3, in: []) == [])
        #expect(found(3, in: [[]]) == [])
        #expect(found(3, in: [[], []]) == [])
    }

    @Test("A single row, a single column and a single cell")
    func thinGrids() {
        #expect(found(9, in: [[1, 5, 9, 12]]) == [0, 2])
        #expect(found(9, in: [[1], [5], [9], [12]]) == [2, 0])
        #expect(found(10, in: [[1], [5], [9], [12]]) == [])
        #expect(found(6, in: [[6]]) == [0, 0])
        #expect(found(7, in: [[6]]) == [])
    }

    @Test("Every shape up to 5 × 5, every target")
    func exhaustive() {
        var firstMismatch: String? = nil
        for rows in 1...5 {
            for columns in 1...5 {
                let grid = (0..<rows).map { row in (0..<columns).map { column in (row * columns + column) * 3 } }
                for target in -1...(rows * columns * 3) {
                    let expected = target >= 0 && target % 3 == 0 && target / 3 < rows * columns ? [target / 3 / columns, target / 3 % columns] : []
                    if found(target, in: grid) != expected {
                        firstMismatch = firstMismatch ?? "\(target) in a \(rows) × \(columns) grid"
                    }
                }
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer is wrong")
    }

    @Test("10,000 searches in tall and wide grids of a million cells", arguments: [(100_000, 10), (10, 100_000)])
    func large(rows: Int, columns: Int) {
        let grid = (0..<rows).map { row in (0..<columns).map { column in (row * columns + column) * 2 } }
        let cells = rows * columns
        var wrong = 0
        for query in 0..<10_000 {
            let target = (query * 7_919) % (2 * cells + 2) - 1
            let expected = target >= 0 && target % 2 == 0 && target / 2 < cells ? [target / 2 / columns, target / 2 % columns] : []
            if found(target, in: grid) != expected {
                wrong += 1
            }
        }
        #expect(wrong == 0)
    }
}
