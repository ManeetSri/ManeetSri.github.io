import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MinesweeperCountsTests {
    @Test("Counts neighbouring mines", arguments: [
        (["*..", ".*.", "..."], ["*21", "2*1", "111"]),
        (["...", ".*.", "..."], ["111", "1*1", "111"]),
        (["***", "*.*", "***"], ["***", "*8*", "***"]),
        (["*...*", ".....", "..*.."], ["*101*", "12121", "01*10"]),
        (["..", ".."], ["00", "00"]),
        (["**", "**"], ["**", "**"]),
    ])
    func counts(field: [String], expected: [String]) {
        #expect(MinesweeperCounts.annotate(field) == expected)
    }

    @Test("Single rows and columns", arguments: [
        ([".*.*."], ["1*2*1"]),
        ([".", "*", ".", "."], ["1", "*", "1", "0"]),
        (["."], ["0"]),
        (["*"], ["*"]),
    ])
    func thin(field: [String], expected: [String]) {
        #expect(MinesweeperCounts.annotate(field) == expected)
    }

    @Test("An empty field stays empty")
    func empty() {
        #expect(MinesweeperCounts.annotate([]) == [])
    }

    @Test("Corners, edges and the middle see 3, 5 and 8 neighbours")
    func neighbourCounts() {
        // Every cell is a mine except the one being counted
        for (row, column, expected) in [(0, 0, "3"), (0, 2, "5"), (2, 2, "8"), (4, 4, "3"), (4, 1, "5")] {
            var rows = Array(repeating: Array(repeating: Character("*"), count: 5), count: 5)
            rows[row][column] = "."
            let field = rows.map { String($0) }
            let result = MinesweeperCounts.annotate(field)
            let cells = result.map { Array($0) }
            let cell = cells.count == 5 && cells[row].count == 5 ? String(cells[row][column]) : "missing"
            #expect(cell == expected, "cell (\(row), \(column))")
        }
    }

    @Test("Stays fast on a 300 × 300 field")
    func large() {
        let size = 300
        // A mine on every cell where row + column is a multiple of 3
        let field = (0..<size).map { row in
            String((0..<size).map { column in (row + column) % 3 == 0 ? "*" : "." })
        }
        let result = MinesweeperCounts.annotate(field)
        #expect(result.count == size)
        #expect(result.first?.count == size)
        #expect(result.first?.hasPrefix("*22*22*") == true)
        #expect(result.count == size && result[150] == String((0..<size).map { column in
            (150 + column) % 3 == 0 ? "*" : (column == 0 || column == size - 1 ? "2" : "3")
        }))
    }
}
