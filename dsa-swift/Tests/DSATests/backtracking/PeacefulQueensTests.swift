import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PeacefulQueensTests {
    /// How many peaceful boards there are for n = 0 ... 12 (index 0 is unused)
    private let known = [1, 1, 0, 0, 2, 10, 4, 40, 92, 352, 724, 2_680, 14_200]

    /// Whether a board is n rows of n squares with exactly one queen per row and no two queens attacking
    private func isPeaceful(_ board: [String], _ n: Int) -> Bool {
        guard board.count == n, board.allSatisfy({ $0.count == n && $0.allSatisfy { $0 == "Q" || $0 == "." } }) else { return false }
        var columns: [Int] = []
        for row in board {
            let queens = row.indices.filter { row[$0] == "Q" }
            guard queens.count == 1 else { return false }
            columns.append(row.distance(from: row.startIndex, to: queens[0]))
        }
        for a in 0..<n {
            for b in (a + 1)..<n where columns[a] == columns[b] || abs(columns[a] - columns[b]) == b - a {
                return false
            }
        }
        return true
    }

    @Test("The two boards for n = 4")
    func fourQueens() {
        let expected = [["..Q.", "Q...", "...Q", ".Q.."], [".Q..", "...Q", "Q...", "..Q."]]
        #expect(PeacefulQueens.boards(n: 4).sorted { $0.lexicographicallyPrecedes($1) } == expected)
    }

    @Test("Tiny boards", arguments: [(1, [["Q"]]), (2, []), (3, [])] as [(Int, [[String]])])
    func tiny(n: Int, expected: [[String]]) {
        #expect(PeacefulQueens.boards(n: n) == expected)
    }

    @Test("Every board is valid and different, and there are the right number", arguments: 1...9)
    func allBoards(n: Int) {
        let boards = PeacefulQueens.boards(n: n)
        #expect(boards.count == known[n])
        #expect(Set(boards).count == known[n])
        #expect(boards.allSatisfy { isPeaceful($0, n) })
    }

    @Test("Counting up to n = 12, where trying all 12! column orders is far too slow", arguments: 1...12)
    func counts(n: Int) {
        #expect(PeacefulQueens.count(n: n) == known[n])
    }
}
