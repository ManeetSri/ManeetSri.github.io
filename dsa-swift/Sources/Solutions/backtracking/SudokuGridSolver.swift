// Reference solution: Sudoku solver. Each row, column and 3 × 3 box keeps a bitmask of the digits it
// already holds (bit d for digit d), so a cell's candidates are the bits missing from all three.
// At every step, fill the empty cell with the fewest candidates: zero means this branch is already
// dead, one means the move is forced, and either way problems surface near the top of the tree,
// where cutting saves the most work. Try each candidate, recurse, and clear the bits if it fails.
// Exponential in the worst case, but a few thousand placements even on puzzles built to defeat a
// row-by-row search; O(81) extra space.

public enum SudokuGridSolver {
    public static func solve(_ rows: [String]) -> [String] {
        var grid = rows.map { row in row.map { $0.wholeNumberValue ?? 0 } }
        var rowDigits = Array(repeating: 0, count: 9)
        var columnDigits = Array(repeating: 0, count: 9)
        var boxDigits = Array(repeating: 0, count: 9)
        var empties: [(row: Int, column: Int)] = []
        for row in 0..<9 {
            for column in 0..<9 {
                let digit = grid[row][column]
                if digit == 0 {
                    empties.append((row, column))
                } else {
                    rowDigits[row] |= 1 << digit
                    columnDigits[column] |= 1 << digit
                    boxDigits[row / 3 * 3 + column / 3] |= 1 << digit
                }
            }
        }

        // empties[0..<remaining] are still to fill
        func fill(_ remaining: Int) -> Bool {
            if remaining == 0 { return true }
            var best = 0
            var bestCandidates = 0
            var bestCount = 10
            for index in 0..<remaining {
                let (row, column) = empties[index]
                let candidates = ~(rowDigits[row] | columnDigits[column] | boxDigits[row / 3 * 3 + column / 3]) & 0b11_1111_1110
                let count = candidates.nonzeroBitCount
                if count < bestCount {
                    (best, bestCandidates, bestCount) = (index, candidates, count)
                    if count <= 1 { break }                         // dead or forced: no need to look further
                }
            }
            if bestCount == 0 { return false }
            empties.swapAt(best, remaining - 1)                     // the chosen cell moves out of the way
            let (row, column) = empties[remaining - 1]
            let box = row / 3 * 3 + column / 3
            var candidates = bestCandidates
            while candidates != 0 {
                let bit = candidates & -candidates
                candidates &= candidates - 1
                rowDigits[row] |= bit                               // choose
                columnDigits[column] |= bit
                boxDigits[box] |= bit
                grid[row][column] = bit.trailingZeroBitCount
                if fill(remaining - 1) { return true }              // explore
                rowDigits[row] &= ~bit                              // unchoose
                columnDigits[column] &= ~bit
                boxDigits[box] &= ~bit
            }
            grid[row][column] = 0
            return false
        }

        _ = fill(empties.count)
        return grid.map { row in String(row.map { Character(String($0)) }) }
    }
}
