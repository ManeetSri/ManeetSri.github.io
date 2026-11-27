import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SudokuGridSolverTests {
    /// Splits 81 characters into 9 rows of 9
    private func rows(_ cells: String) -> [String] {
        let characters = Array(cells)
        return (0..<9).map { String(characters[($0 * 9)..<($0 * 9 + 9)]) }
    }

    /// Whether `solution` is a completed, valid grid that keeps every given digit of `puzzle`
    private func solves(_ solution: [String], _ puzzle: [String]) -> Bool {
        guard solution.count == 9, solution.allSatisfy({ $0.count == 9 }) else { return false }
        let grid = solution.map { row in row.map { $0.wholeNumberValue ?? 0 } }
        let given = puzzle.map { row in row.map { $0.wholeNumberValue ?? 0 } }
        let digits = Set(1...9)
        for i in 0..<9 {
            guard Set(grid[i]) == digits, Set((0..<9).map { grid[$0][i] }) == digits else { return false }
            let top = i / 3 * 3, left = i % 3 * 3
            guard Set((0..<9).map { grid[top + $0 / 3][left + $0 % 3] }) == digits else { return false }
        }
        for r in 0..<9 {
            for c in 0..<9 where given[r][c] != 0 && given[r][c] != grid[r][c] {
                return false
            }
        }
        return true
    }

    @Test("A gentle puzzle with its known solution")
    func gentle() {
        let puzzle = rows("..53.....8......2..7..1.5..4....53...1..7...6..32...8..6.5....9..4....3......97..")
        let solution = rows("145327698839654127672918543496185372218473956753296481367542819984761235521839764")
        #expect(SudokuGridSolver.solve(puzzle) == solution)
    }

    @Test("Famous hard puzzles", arguments: [
        "8..........36......7..9.2...5...7.......457.....1...3...1....68..85...1..9....4..",
        "1.......2.9.4...5...6...7...5.9.3.......7.......85..4.7.....6...3...9.8...2.....1",
        "4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......",
    ])
    func hard(cells: String) {
        let puzzle = rows(cells)
        #expect(solves(SudokuGridSolver.solve(puzzle), puzzle))
    }

    @Test("A 17-clue puzzle built to defeat a row-by-row search: fill the most constrained cell first")
    func antiBruteForce() {
        let puzzle = rows("..............3.85..1.2.......5.7.....4...1...9.......5......73..2.1........4...9")
        let solution = rows("987654321246173985351928746128537694634892157795461832519286473472319568863745219")
        #expect(SudokuGridSolver.solve(puzzle) == solution)
    }

    @Test("One empty cell, and none at all")
    func nearlyDone() {
        let solution = rows("145327698839654127672918543496185372218473956753296481367542819984761235521839764")
        var oneGap = solution
        oneGap[4] = "2184739.6"
        #expect(SudokuGridSolver.solve(oneGap) == solution)
        #expect(SudokuGridSolver.solve(solution) == solution)
    }
}
