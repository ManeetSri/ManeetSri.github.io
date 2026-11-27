// Generated from src/dsa/content/lessons/swift-collections/swift-2d-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let grid = [
    [1, 2, 3],
    [4, 5, 6],
]

let rowSums = grid.map { $0.reduce(0, +) }
print(rowSums)

var colSums = Array(repeating: 0, count: grid[0].count)
for r in 0..<grid.count {
    for c in 0..<grid[r].count {
        colSums[c] += grid[r][c]
    }
}
print(colSums)
