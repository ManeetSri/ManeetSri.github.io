// Reference solution: Peaceful queens. Place one queen per row. A square is attacked through its
// column, its "\" diagonal (same row - column) and its "/" diagonal (same row + column).
// `boards` keeps three Bool arrays for those, so checking a square is O(1), and records each board.
// `count` keeps them as bitmasks for the current row instead: the free squares are
// full & ~(columns | left | right), the lowest set bit picks one, and moving down a row shifts the
// diagonal masks one place each way. Counting builds no boards at all.
// Both visit the same pruned tree: far fewer than n! nodes (about 856,000 for n = 12), O(n) space.

public enum PeacefulQueens {
    public static func boards(n: Int) -> [[String]] {
        var result: [[String]] = []
        var queenColumn: [Int] = []
        var columnTaken = Array(repeating: false, count: n)
        var downTaken = Array(repeating: false, count: 2 * n - 1)  // index row - column + n - 1
        var upTaken = Array(repeating: false, count: 2 * n - 1)    // index row + column

        func place(_ row: Int) {
            if row == n {
                result.append(queenColumn.map { column in
                    String(repeating: ".", count: column) + "Q" + String(repeating: ".", count: n - column - 1)
                })
                return
            }
            for column in 0..<n where !columnTaken[column] && !downTaken[row - column + n - 1] && !upTaken[row + column] {
                queenColumn.append(column)                          // choose
                columnTaken[column] = true
                downTaken[row - column + n - 1] = true
                upTaken[row + column] = true
                place(row + 1)                                      // explore
                queenColumn.removeLast()                            // unchoose
                columnTaken[column] = false
                downTaken[row - column + n - 1] = false
                upTaken[row + column] = false
            }
        }

        place(0)
        return result
    }

    public static func count(n: Int) -> Int {
        let full = (1 << n) - 1

        func place(_ columns: Int, _ left: Int, _ right: Int) -> Int {
            if columns == full { return 1 }                         // a queen in every column
            var total = 0
            var free = full & ~(columns | left | right)
            while free != 0 {
                let square = free & -free                           // the lowest free square
                free &= free - 1
                total += place(columns | square, ((left | square) << 1) & full, (right | square) >> 1)
            }
            return total
        }

        return place(0, 0, 0)
    }
}
