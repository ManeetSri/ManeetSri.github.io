import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LifeStepTests {
    static let ruleCases: [([[Int]], [[Int]])] = [
        ([[0, 1, 0], [0, 0, 1], [1, 1, 1], [0, 0, 0]], [[0, 0, 0], [1, 0, 1], [0, 1, 1], [0, 1, 0]]),
        ([[1, 1], [1, 0]], [[1, 1], [1, 1]]),
        ([[1, 0], [0, 0]], [[0, 0], [0, 0]]),
        ([[1, 1, 1], [1, 1, 1], [1, 1, 1]], [[1, 0, 1], [0, 0, 0], [1, 0, 1]]),
        ([[1, 1, 0], [1, 0, 0], [0, 0, 1]], [[1, 1, 0], [1, 0, 0], [0, 0, 0]]),
    ]

    private func stepped(_ board: [[Int]]) -> [[Int]] {
        var copy = board
        LifeStep.advance(&copy)
        return copy
    }

    // The straightforward version: read the old board, write a new one
    private func expectedStep(_ board: [[Int]]) -> [[Int]] {
        let rows = board.count
        guard let columns = board.first?.count else { return board }
        var next = board
        for row in 0..<rows {
            for column in 0..<columns {
                var alive = 0
                for r in max(0, row - 1)...min(rows - 1, row + 1) {
                    for c in max(0, column - 1)...min(columns - 1, column + 1) where (r, c) != (row, column) {
                        alive += board[r][c]
                    }
                }
                next[row][column] = alive == 3 || (board[row][column] == 1 && alive == 2) ? 1 : 0
            }
        }
        return next
    }

    @Test("A blinker flips between horizontal and vertical")
    func blinker() {
        let horizontal = [[0, 0, 0], [1, 1, 1], [0, 0, 0]]
        let vertical = [[0, 1, 0], [0, 1, 0], [0, 1, 0]]
        #expect(stepped(horizontal) == vertical)
        #expect(stepped(vertical) == horizontal)
    }

    @Test("A block never changes")
    func block() {
        let board = [[0, 0, 0, 0], [0, 1, 1, 0], [0, 1, 1, 0], [0, 0, 0, 0]]
        #expect(stepped(board) == board)
    }

    @Test("Births, survival, loneliness and overcrowding", arguments: Self.ruleCases)
    func rules(board: [[Int]], expected: [[Int]]) {
        #expect(stepped(board) == expected)
    }

    @Test("Single rows, single cells and empty boards")
    func tiny() {
        #expect(stepped([[1, 1, 1]]) == [[0, 1, 0]])
        #expect(stepped([[1]]) == [[0]])
        #expect(stepped([[0]]) == [[0]])
        #expect(stepped([]) == [])
    }

    @Test("Matches the straightforward version on many small boards")
    func matchesStraightforward() {
        var firstMismatch: [[Int]]? = nil
        for seed in 0..<300 {
            let rows = 1 + seed % 5
            let columns = 1 + (seed / 5) % 5
            let board = (0..<rows).map { row in (0..<columns).map { column in (row * 5 + column * 3 + seed) % 3 == 0 ? 1 : 0 } }
            if stepped(board) != expectedStep(board) {
                firstMismatch = firstMismatch ?? board
            }
        }
        #expect(firstMismatch == nil, "the first board that stepped wrongly")
    }

    @Test("A glider moves one cell diagonally every four steps")
    func glider() {
        var board = Array(repeating: Array(repeating: 0, count: 8), count: 8)
        for (row, column) in [(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)] {
            board[row][column] = 1
        }
        let start = board
        for _ in 0..<4 {
            LifeStep.advance(&board)
        }
        var moved = Array(repeating: Array(repeating: 0, count: 8), count: 8)
        for row in 0..<7 {
            for column in 0..<7 {
                moved[row + 1][column + 1] = start[row][column]
            }
        }
        #expect(board == moved)
    }

    @Test("Stays fast on a 300 × 300 board")
    func large() {
        let size = 300
        let board = (0..<size).map { row in (0..<size).map { column in (row * column + row) % 7 < 3 ? 1 : 0 } }
        #expect(stepped(board) == expectedStep(board))
    }
}
