// Reference solution: Sudoku solution count. Each row, column and box keeps a bitmask of the digits it
// already holds, so a cell's candidates are one OR and one NOT. The search always branches on the empty
// cell with the fewest candidates (a cell with none fails at once), places each candidate in turn,
// and stops as soon as `limit` solutions have been counted. isMinimal asks the same question once per
// clue with a limit of 2: "zero, one, or more than one?"

public enum SudokuSolutionCount {
    public static func solutions(_ rows: [String], limit: Int) -> Int {
        guard limit > 0, var board = Board(rows) else { return 0 }
        return board.count(limit: limit)
    }

    public static func isMinimal(_ rows: [String]) -> Bool {
        guard solutions(rows, limit: 2) == 1 else { return false }
        var grid = rows.map { Array($0) }
        for r in 0..<9 {
            for c in 0..<9 where grid[r][c] != "." {
                let clue = grid[r][c]
                grid[r][c] = "."
                let stillUnique = solutions(grid.map { String($0) }, limit: 2) == 1
                grid[r][c] = clue
                if stillUnique { return false }                 // that clue wasn't needed
            }
        }
        return true
    }

    private struct Board {
        var cells = [Int](repeating: 0, count: 81)              // 0 means empty
        var rowUsed = [Int](repeating: 0, count: 9)             // bit d set: digit d is in that row
        var columnUsed = [Int](repeating: 0, count: 9)
        var boxUsed = [Int](repeating: 0, count: 9)

        /// Nil when the grid isn't 9 × 9 of "1"..."9" and ".", or when two givens clash.
        init?(_ rows: [String]) {
            guard rows.count == 9 else { return nil }
            for (r, row) in rows.enumerated() {
                let characters = Array(row)
                guard characters.count == 9 else { return nil }
                for (c, character) in characters.enumerated() where character != "." {
                    guard let digit = character.wholeNumberValue, (1...9).contains(digit),
                          character.isASCII, candidates(r * 9 + c) & (1 << digit) != 0 else { return nil }
                    place(digit, at: r * 9 + c)
                }
            }
        }

        func candidates(_ cell: Int) -> Int {
            let r = cell / 9, c = cell % 9
            return ~(rowUsed[r] | columnUsed[c] | boxUsed[r / 3 * 3 + c / 3]) & 0b11_1111_1110
        }

        mutating func place(_ digit: Int, at cell: Int) {
            let r = cell / 9, c = cell % 9
            cells[cell] = digit
            rowUsed[r] |= 1 << digit
            columnUsed[c] |= 1 << digit
            boxUsed[r / 3 * 3 + c / 3] |= 1 << digit
        }

        mutating func remove(_ digit: Int, at cell: Int) {
            let r = cell / 9, c = cell % 9
            cells[cell] = 0
            rowUsed[r] &= ~(1 << digit)
            columnUsed[c] &= ~(1 << digit)
            boxUsed[r / 3 * 3 + c / 3] &= ~(1 << digit)
        }

        /// Counts completions, stopping at `limit`. Depth is at most 81, so recursion is safe.
        mutating func count(limit: Int) -> Int {
            var best = -1
            var bestMask = 0
            var fewest = 10
            for cell in 0..<81 where cells[cell] == 0 {
                let mask = candidates(cell)
                let options = mask.nonzeroBitCount
                if options < fewest {
                    (best, bestMask, fewest) = (cell, mask, options)
                    if options == 0 { return 0 }                 // a dead end: no digit fits here
                }
            }
            if best == -1 { return 1 }                           // no empty cell left: one solution
            var found = 0
            var mask = bestMask
            while mask != 0 && found < limit {
                let digit = mask.trailingZeroBitCount
                mask &= mask - 1
                place(digit, at: best)
                found += count(limit: limit - found)
                remove(digit, at: best)
            }
            return found
        }
    }
}
