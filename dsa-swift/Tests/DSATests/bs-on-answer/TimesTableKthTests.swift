import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TimesTableKthTests {
    /// Builds the whole table and sorts it: fine for small tables.
    private func sortedTable(rows: Int, columns: Int) -> [Int] {
        var entries: [Int] = []
        for i in 1...rows {
            for j in 1...columns {
                entries.append(i * j)
            }
        }
        return entries.sorted()
    }

    /// Entries ≤ x, counted row by row.
    private func entries(atMost x: Int, rows: Int, columns: Int) -> Int {
        var count = 0
        for i in 1...rows {
            count += min(x / i, columns)
        }
        return count
    }

    @Test("Finds the kth entry in the examples", arguments: [
        (2, 5, 6, 4),
        (2, 5, 10, 10),
        (4, 4, 9, 6),
        (1, 7, 3, 3),
        (3, 4, 7, 4),
        (3, 4, 8, 6),
        (1, 1, 1, 1),
    ])
    func examples(rows: Int, columns: Int, k: Int, expected: Int) {
        #expect(TimesTableKth.kthSmallest(rows: rows, columns: columns, k: k) == expected)
    }

    @Test("Rows and columns can be swapped")
    func symmetric() {
        #expect(TimesTableKth.kthSmallest(rows: 5, columns: 2, k: 6) == 4)
        #expect(TimesTableKth.kthSmallest(rows: 7, columns: 1, k: 3) == 3)
    }

    @Test("Matches sorting the whole table for every k in many small tables")
    func matchesSorting() {
        var firstMismatch: String? = nil
        for rows in 1...9 {
            for columns in 1...9 {
                let table = sortedTable(rows: rows, columns: columns)
                for k in 1...table.count where TimesTableKth.kthSmallest(rows: rows, columns: columns, k: k) != table[k - 1] {
                    firstMismatch = firstMismatch ?? "\(rows) × \(columns), k = \(k)"
                }
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from sorting")
    }

    @Test("A 100,000 × 100,000 table: the first, last and middle entries")
    func huge() {
        let n = 100_000
        #expect(TimesTableKth.kthSmallest(rows: n, columns: n, k: 1) == 1)
        #expect(TimesTableKth.kthSmallest(rows: n, columns: n, k: n * n) == n * n)
        #expect(TimesTableKth.kthSmallest(rows: n, columns: n, k: 2) == 2)
        #expect(TimesTableKth.kthSmallest(rows: n, columns: n, k: 3) == 2)
    }

    @Test("Large tables: the answer is in the table and has the right rank", arguments: [
        (30_000, 30_000, 123_456_789),
        (100_000, 3, 150_000),
        (1, 100_000, 77_777),
        (99_991, 65_537, 3_000_000_000),
    ])
    func large(rows: Int, columns: Int, k: Int) {
        let value = TimesTableKth.kthSmallest(rows: rows, columns: columns, k: k)
        #expect(value >= 1)
        guard value >= 1 else { return }
        #expect(entries(atMost: value, rows: rows, columns: columns) >= k, "at least k entries are ≤ \(value)")
        #expect(entries(atMost: value - 1, rows: rows, columns: columns) < k, "fewer than k entries are < \(value)")
    }
}
