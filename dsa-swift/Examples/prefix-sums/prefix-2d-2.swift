// Generated from src/dsa/content/lessons/prefix-sums/prefix-2d.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let grid = [
    [3, 0, 1, 4],
    [5, 6, 3, 2],
    [1, 2, 0, 1],
]
var prefix = Array(repeating: Array(repeating: 0, count: 5), count: 4)
for r in 0..<3 {
    for c in 0..<4 {
        prefix[r + 1][c + 1] = grid[r][c] + prefix[r][c + 1] + prefix[r + 1][c] - prefix[r][c]
    }
}

func regionSum(top: Int, left: Int, bottom: Int, right: Int) -> Int {
    prefix[bottom + 1][right + 1] - prefix[top][right + 1] - prefix[bottom + 1][left] + prefix[top][left]
}

print(regionSum(top: 1, left: 1, bottom: 2, right: 2))
print(regionSum(top: 0, left: 0, bottom: 2, right: 3))
print(regionSum(top: 0, left: 3, bottom: 1, right: 3))
