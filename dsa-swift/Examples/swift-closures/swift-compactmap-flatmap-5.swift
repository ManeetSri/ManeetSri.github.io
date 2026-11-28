// Generated from src/dsa/content/lessons/swift-closures/swift-compactmap-flatmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let grid = [
    [1, 2, 3],
    [4, 5],
    [],
    [6],
]

let allCells = grid.flatMap { $0 }
print(allCells)
print(grid.joined().count)
