// Generated from src/dsa/content/lessons/swift-control-flow/swift-break-continue.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let grid = [
    [3, 7, 2],
    [5, -1, 9],
    [8, 4, 6],
]

rows: for row in 0..<grid.count {
    var rowTotal = 0
    for value in grid[row] {
        if value < 0 {
            print("Row \(row) has a bad value, skipping it")
            continue rows
        }
        rowTotal += value
    }
    print("Row \(row) total: \(rowTotal)")
}
