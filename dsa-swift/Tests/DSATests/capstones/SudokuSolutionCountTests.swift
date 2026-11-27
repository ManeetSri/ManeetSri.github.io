import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run makes the same puzzles
private struct SudokuCountRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct SudokuSolutionCountTests {
    /// The puzzle the lesson's generator makes from seed 74: 23 clues, one solution, minimal
    private let lessonPuzzle = ["5.....74.", ".4...2.1.", ".6......5", ".16.7.9..", ".3.....87",
                                "...84....", ".....913.", "....81...", ".2......."]
    private let solved = ["145327698", "839654127", "672918543", "496185372", "218473956",
                          "753296481", "367542819", "984761235", "521839764"]
    private let empty = Array(repeating: ".........", count: 9)

    private func replacing(_ rows: [String], _ r: Int, _ c: Int, with character: Character) -> [String] {
        var grid = rows.map { Array($0) }
        grid[r][c] = character
        return grid.map { String($0) }
    }

    /// Brute force: plain backtracking in reading order, with no clever cell choice
    private func bruteCount(_ rows: [String], limit: Int) -> Int {
        var cells = rows.joined().map { $0 == "." ? 0 : $0.wholeNumberValue! }
        func fits(_ digit: Int, _ index: Int) -> Bool {
            let r = index / 9, c = index % 9
            for i in 0..<9 {
                if cells[r * 9 + i] == digit || cells[i * 9 + c] == digit { return false }
                if cells[(r / 3 * 3 + i / 3) * 9 + c / 3 * 3 + i % 3] == digit { return false }
            }
            return true
        }
        for index in 0..<81 where cells[index] != 0 {
            let digit = cells[index]
            cells[index] = 0
            if !fits(digit, index) { return 0 }
            cells[index] = digit
        }
        func search(_ index: Int) -> Int {
            if index == 81 { return 1 }
            if cells[index] != 0 { return search(index + 1) }
            var found = 0
            for digit in 1...9 where found < limit && fits(digit, index) {
                cells[index] = digit
                found += search(index + 1)
                cells[index] = 0
            }
            return found
        }
        return min(search(0), limit)
    }

    @Test("The lesson's generated puzzle has one solution and is minimal")
    func lessonPuzzleIsProper() {
        #expect(SudokuSolutionCount.solutions(lessonPuzzle, limit: 2) == 1)
        #expect(SudokuSolutionCount.solutions(lessonPuzzle, limit: 100) == 1)
        #expect(SudokuSolutionCount.isMinimal(lessonPuzzle))
    }

    @Test("Removing any clue from a minimal puzzle allows a second solution")
    func removingAClue() {
        #expect(SudokuSolutionCount.solutions(replacing(lessonPuzzle, 0, 0, with: "."), limit: 2) == 2)
        #expect(SudokuSolutionCount.solutions(replacing(lessonPuzzle, 8, 1, with: "."), limit: 2) == 2)
        #expect(!SudokuSolutionCount.isMinimal(replacing(lessonPuzzle, 8, 1, with: ".")))
    }

    @Test("A clue that isn't needed makes the puzzle not minimal, though still unique")
    func extraClue() {
        let withExtra = replacing(lessonPuzzle, 0, 1, with: "9")           // 9 is the right digit there
        #expect(SudokuSolutionCount.solutions(withExtra, limit: 2) == 1)
        #expect(!SudokuSolutionCount.isMinimal(withExtra))
        #expect(!SudokuSolutionCount.isMinimal(solved))
    }

    @Test("A wrong digit that clashes with nothing directly leaves no solution")
    func hiddenContradiction() {
        let wrong = replacing(lessonPuzzle, 0, 1, with: "8")
        #expect(SudokuSolutionCount.solutions(wrong, limit: 5) == 0)
        #expect(!SudokuSolutionCount.isMinimal(wrong))
    }

    @Test("The empty grid stops counting at the limit", arguments: [1, 2, 5, 300])
    func emptyGrid(limit: Int) {
        #expect(SudokuSolutionCount.solutions(empty, limit: limit) == limit)
    }

    @Test("A solved grid has exactly one solution: itself")
    func solvedGrid() {
        #expect(SudokuSolutionCount.solutions(solved, limit: 1) == 1)
        #expect(SudokuSolutionCount.solutions(solved, limit: 2) == 1)
    }

    @Test("An unavoidable rectangle: four blanks with exactly two ways to fill them")
    func twoSolutions() {
        // Rows 0 and 8, columns 0 and 2 hold 1, 5 / 5, 1: swapping them gives a second valid grid
        var puzzle = solved
        for (r, c) in [(0, 0), (0, 2), (8, 0), (8, 2)] { puzzle = replacing(puzzle, r, c, with: ".") }
        #expect(SudokuSolutionCount.solutions(puzzle, limit: 1) == 1)
        #expect(SudokuSolutionCount.solutions(puzzle, limit: 2) == 2)
        #expect(SudokuSolutionCount.solutions(puzzle, limit: 10) == 2)
        #expect(!SudokuSolutionCount.isMinimal(puzzle))
    }

    @Test("Givens that break the rules mean no solution", arguments: [
        ["55......."] + Array(repeating: ".........", count: 8),                                   // a row
        ["7........", ".........", ".........", "7........"] + Array(repeating: ".........", count: 5), // a column
        ["3........", ".3......."] + Array(repeating: ".........", count: 7),                       // a box
        ["12345678.", "........9"] + Array(repeating: ".........", count: 7),                       // no digit fits (0, 8)
    ])
    func brokenRules(rows: [String]) {
        #expect(SudokuSolutionCount.solutions(rows, limit: 3) == 0)
        #expect(!SudokuSolutionCount.isMinimal(rows))
    }

    @Test("Matches plain backtracking on puzzles made by blanking random cells of relabelled grids")
    func randomPuzzles() {
        var random = SudokuCountRandom(seed: 74)
        var firstMismatch: String? = nil
        for _ in 0..<40 where firstMismatch == nil {
            // Relabelling the digits of a valid grid gives another valid grid
            let relabel = Array("123456789".shuffled(using: &random))
            var grid = solved.map { row in Array(row.map { relabel[$0.wholeNumberValue! - 1] }) }
            let blanks = Int.random(in: 20...50, using: &random)
            for index in Array(0..<81).shuffled(using: &random).prefix(blanks) {
                grid[index / 9][index % 9] = "."
            }
            let rows = grid.map { String($0) }
            let limit = Int.random(in: 1...20, using: &random)
            let got = SudokuSolutionCount.solutions(rows, limit: limit)
            let expected = bruteCount(rows, limit: limit)
            if got != expected {
                firstMismatch = "\(rows) with limit \(limit): got \(got), expected \(expected)"
            }
        }
        #expect(firstMismatch == nil)
    }
}
