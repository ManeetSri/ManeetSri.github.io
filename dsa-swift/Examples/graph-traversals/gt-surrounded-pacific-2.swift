// Generated from src/dsa/content/lessons/graph-traversals/gt-surrounded-pacific.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
let heights = [
    [3, 3, 4, 5, 6],
    [2, 1, 4, 3, 5],
    [4, 7, 8, 2, 4],
    [6, 5, 3, 1, 2],
]
let rows = heights.count
let columns = heights[0].count

/// Every cell whose water can reach the given edge cells, found by climbing from them
func reaches(from edge: [(Int, Int)]) -> [[Bool]] {
    var reached = Array(repeating: Array(repeating: false, count: columns), count: rows)
    var stack: [(Int, Int)] = []
    for (row, column) in edge where !reached[row][column] {
        reached[row][column] = true
        stack.append((row, column))
    }
    while let cell = stack.popLast() {
        for (dr, dc) in directions {
            let r = cell.0 + dr
            let c = cell.1 + dc
            guard r >= 0, r < rows, c >= 0, c < columns, !reached[r][c] else { continue }
            guard heights[r][c] >= heights[cell.0][cell.1] else { continue }   // climb: uphill or level
            reached[r][c] = true
            stack.append((r, c))
        }
    }
    return reached
}

let pacific = reaches(from: (0..<rows).map { ($0, 0) } + (0..<columns).map { (0, $0) })      // left and top
let atlantic = reaches(from: (0..<rows).map { ($0, columns - 1) } + (0..<columns).map { (rows - 1, $0) })  // right and bottom

var both: [[Int]] = []
for row in 0..<rows {
    var marks: [String] = []
    for column in 0..<columns {
        switch (pacific[row][column], atlantic[row][column]) {
        case (true, true):
            marks.append("B")
            both.append([row, column])
        case (true, false): marks.append("P")
        case (false, true): marks.append("A")
        case (false, false): marks.append(".")
        }
    }
    print(marks.joined(separator: " "))
}
print("both:", both)
