// Generated from src/dsa/content/lessons/matrices/matrix-staircase-search.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Counts the cells holding at most `target`, walking a staircase from the top-right
func countAtMost(_ target: Int, in grid: [[Int]]) -> Int {
    guard let width = grid.first?.count else { return 0 }
    var column = width - 1
    var count = 0
    for row in grid.indices {
        while column >= 0 && grid[row][column] > target {
            column -= 1          // too big here, so too big in every row below as well
        }
        count += column + 1      // grid[row][0...column] are all at most target
    }
    return count
}

let grid = [
    [1, 4, 7, 11, 15],
    [2, 5, 8, 12, 19],
    [3, 6, 9, 16, 22],
    [10, 13, 14, 17, 24],
    [18, 21, 23, 26, 30],
]
for target in [0, 5, 14, 30] {
    let bruteForce = grid.joined().filter { $0 <= target }.count
    print(target, countAtMost(target, in: grid), bruteForce)
}
