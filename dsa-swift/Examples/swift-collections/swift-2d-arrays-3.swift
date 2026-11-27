// Generated from src/dsa/content/lessons/swift-collections/swift-2d-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let grid = [
    [3, 8, 1],
    [9, 2, 7],
]

for r in 0..<grid.count {
    for c in 0..<grid[r].count {
        print("(\(r), \(c)) = \(grid[r][c])")
    }
}
