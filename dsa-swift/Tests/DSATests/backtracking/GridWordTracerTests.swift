import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct TraceRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct GridWordTracerTests {
    /// A plain depth-first search with a set of used cells and no pruning: slow, but clearly right
    private func reference(_ grid: [String], _ word: String) -> Bool {
        let board = grid.map { Array($0) }
        let letters = Array(word)
        let rows = board.count
        let columns = board[0].count
        var used = Set<Int>()
        func trace(_ row: Int, _ column: Int, _ index: Int) -> Bool {
            if index == letters.count { return true }
            guard row >= 0, row < rows, column >= 0, column < columns,
                  !used.contains(row * columns + column), board[row][column] == letters[index] else { return false }
            used.insert(row * columns + column)
            defer { used.remove(row * columns + column) }
            return [(-1, 0), (1, 0), (0, -1), (0, 1)].contains { trace(row + $0.0, column + $0.1, index + 1) }
        }
        return (0..<rows).contains { row in (0..<columns).contains { trace(row, $0, 0) } }
    }

    @Test("Examples and small cases", arguments: [
        (["CATS", "ROPE", "DUSK"], "ROPE", true),
        (["CATS", "ROPE", "DUSK"], "CROP", true),
        (["CATS", "ROPE", "DUSK"], "CAPE", false),
        (["CATS", "ROPE", "DUSK"], "DROPS", true),
        (["CATS", "ROPE", "DUSK"], "PEST", true),
        (["CATS", "ROPE", "DUSK"], "STEP", false),
        (["CATS", "ROPE", "DUSK"], "POP", false),
        (["CATS", "ROPE", "DUSK"], "CATC", false),
        (["CATS", "ROPE", "DUSK"], "KSUD", true),
        (["CATS", "ROPE", "DUSK"], "ROUSE", false),
        (["A"], "A", true),
        (["A"], "AA", false),
        (["AB", "BA"], "ABAB", true),
        (["AAA", "ABA", "AAA"], "AAAAAAAAB", true),
        (["AAA", "ABA", "AAA"], "AAAAAAAAAB", false),
    ] as [([String], String, Bool)])
    func examples(grid: [String], word: String, expected: Bool) {
        #expect(GridWordTracer.contains(grid, word: word) == expected)
    }

    @Test("Matches a plain search on 500 random grids and words")
    func randomSmall() {
        var random = TraceRandom(seed: 48)
        let alphabet = Array("ABC")
        for _ in 0..<500 {
            let rows = Int.random(in: 1...4, using: &random)
            let columns = Int.random(in: 1...4, using: &random)
            let grid = (0..<rows).map { _ in String((0..<columns).map { _ in alphabet.randomElement(using: &random)! }) }
            var word: String
            if Bool.random(using: &random) {
                // Letters along a random walk, which may or may not revisit a cell
                var row = Int.random(in: 0..<rows, using: &random)
                var column = Int.random(in: 0..<columns, using: &random)
                var letters: [Character] = []
                for _ in 0..<Int.random(in: 1...7, using: &random) {
                    letters.append(Array(grid[row])[column])
                    let (dRow, dColumn) = [(-1, 0), (1, 0), (0, -1), (0, 1)].randomElement(using: &random)!
                    row = min(max(row + dRow, 0), rows - 1)
                    column = min(max(column + dColumn, 0), columns - 1)
                }
                word = String(letters)
            } else {
                word = String((0..<Int.random(in: 1...6, using: &random)).map { _ in alphabet.randomElement(using: &random)! })
            }
            #expect(GridWordTracer.contains(grid, word: word) == reference(grid, word), "grid \(grid), word \(word)")
        }
    }

    @Test("A long word in a grid of one letter: found along a snake")
    func longWordFound() {
        let grid = Array(repeating: "AAAAAA", count: 6)
        #expect(GridWordTracer.contains(grid, word: String(repeating: "A", count: 30)))
        #expect(GridWordTracer.contains(grid, word: String(repeating: "A", count: 36)))
        #expect(!GridWordTracer.contains(grid, word: String(repeating: "A", count: 37)))
    }

    @Test("The last letter isn't in the grid: compare letter counts before searching millions of paths")
    func missingLetter() {
        let grid = Array(repeating: "AAAAAA", count: 6)
        #expect(!GridWordTracer.contains(grid, word: String(repeating: "A", count: 23) + "B"))
    }

    @Test("The only B is fenced in: start from the rarer end of the word")
    func rareEnd() {
        let grid = ["BCAAAA", "CAAAAA", "AAAAAA", "AAAAAA", "AAAAAA", "AAAAAA"]
        #expect(!GridWordTracer.contains(grid, word: String(repeating: "A", count: 23) + "B"))
        #expect(!GridWordTracer.contains(grid, word: "B" + String(repeating: "A", count: 23)))
        #expect(GridWordTracer.contains(grid, word: "BC" + String(repeating: "A", count: 22)))
    }
}
