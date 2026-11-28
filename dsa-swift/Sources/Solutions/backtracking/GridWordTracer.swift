// Reference solution: Trace a word on a letter grid. Two cheap checks first: if the word needs more
// of some letter than the grid holds, it can't be there; and if its first letter is more common in
// the grid than its last, search for the word reversed, since that leaves fewer starting cells and
// cuts dead paths sooner. Then a depth-first search from every cell: match the letter, mark the cell
// in place with "#" (choose), try the four neighbours for the next letter (explore), and restore it
// on the way back (unchoose).
// O(cells · 3^L) time in the worst case for a word of length L; O(L) extra space for the recursion.

public enum GridWordTracer {
    public static func contains(_ grid: [String], word: String) -> Bool {
        var board = grid.map { Array($0) }
        var letters = Array(word)
        guard let columns = board.first?.count, !letters.isEmpty else { return letters.isEmpty }
        let rows = board.count

        var available: [Character: Int] = [:]
        for row in board {
            for letter in row {
                available[letter, default: 0] += 1
            }
        }
        var needed: [Character: Int] = [:]
        for letter in letters {
            needed[letter, default: 0] += 1
        }
        for (letter, count) in needed where available[letter, default: 0] < count {
            return false
        }
        if available[letters[0], default: 0] > available[letters[letters.count - 1], default: 0] {
            letters.reverse()
        }

        func trace(_ row: Int, _ column: Int, _ index: Int) -> Bool {
            guard row >= 0, row < rows, column >= 0, column < columns,
                  board[row][column] == letters[index] else { return false }
            if index == letters.count - 1 { return true }
            let saved = board[row][column]
            board[row][column] = "#"                                // mark: used in this trace
            defer { board[row][column] = saved }                    // unmark on the way back
            return trace(row - 1, column, index + 1) || trace(row + 1, column, index + 1)
                || trace(row, column - 1, index + 1) || trace(row, column + 1, index + 1)
        }

        for row in 0..<rows {
            for column in 0..<columns where trace(row, column, 0) {
                return true
            }
        }
        return false
    }
}
