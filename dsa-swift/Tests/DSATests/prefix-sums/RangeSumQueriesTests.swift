import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RangeSumQueriesTests {
    typealias Table = RangeSumQueries.Table

    @Test("Sums ranges of the example array", arguments: [
        (2, 5, 19),
        (0, 6, 25),
        (4, 4, 5),
        (0, 0, 3),
        (6, 6, 2),
        (0, 2, 8),
        (3, 6, 17),
    ])
    func example(start: Int, end: Int, expected: Int) {
        let table = Table([3, 1, 4, 1, 5, 9, 2])
        #expect(table.sum(from: start, through: end) == expected)
    }

    @Test("Handles negative numbers and zeros")
    func negatives() {
        let table = Table([-4, 7, 0, -3, -3, 10])
        #expect(table.sum(from: 0, through: 5) == 7)
        #expect(table.sum(from: 0, through: 1) == 3)
        #expect(table.sum(from: 2, through: 2) == 0)
        #expect(table.sum(from: 3, through: 4) == -6)
        #expect(table.sum(from: 1, through: 4) == 1)
    }

    @Test("Works for a single value")
    func single() {
        #expect(Table([42]).sum(from: 0, through: 0) == 42)
        #expect(Table([-7]).sum(from: 0, through: 0) == -7)
    }

    @Test("Building a table for an empty array doesn't crash")
    func empty() {
        _ = Table([])
    }

    @Test("Handles sums far bigger than any single value")
    func bigValues() {
        let values = Array(repeating: 1_000_000_000, count: 1_000)
        let table = Table(values)
        #expect(table.sum(from: 0, through: 999) == 1_000_000_000_000)
        #expect(table.sum(from: 500, through: 999) == 500_000_000_000)
    }

    @Test("Matches adding up the range on many small arrays")
    func matchesBruteForce() {
        var mismatches = 0
        for seed in 0..<60 {
            let values = (0..<(seed % 12 + 1)).map { ($0 * 37 + seed * 11) % 21 - 10 }
            let table = Table(values)
            for start in values.indices {
                for end in start..<values.count where table.sum(from: start, through: end) != values[start...end].reduce(0, +) {
                    mismatches += 1
                }
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Answers 100,000 queries on 100,000 values quickly")
    func large() {
        let n = 100_000
        let table = Table(Array(1...n))      // values[i] is i + 1
        var mismatches = 0
        for q in 0..<100_000 {
            let start = (q * 7_919) % n
            let end = min(n - 1, start + (q * 104_729) % 50_000)
            let first = start + 1
            let last = end + 1
            let expected = (first + last) * (last - first + 1) / 2
            if table.sum(from: start, through: end) != expected {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }
}
