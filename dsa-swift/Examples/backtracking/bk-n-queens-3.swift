// Generated from src/dsa/content/lessons/backtracking/bk-n-queens.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countQueensFast(_ n: Int) -> Int {
    let full = (1 << n) - 1                                      // n ones: every column

    func place(_ columns: Int, _ downRight: Int, _ downLeft: Int) -> Int {
        if columns == full { return 1 }                          // a queen in every column, so every row
        var total = 0
        var free = full & ~(columns | downRight | downLeft)
        while free != 0 {
            let square = free & -free                            // the lowest free column
            free &= free - 1                                     // cross it off
            total += place(columns | square, ((downRight | square) << 1) & full, (downLeft | square) >> 1)
        }
        return total
    }

    return place(0, 0, 0)
}

print((1...12).map(countQueensFast))
