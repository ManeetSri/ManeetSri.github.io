// Generated from src/dsa/content/lessons/backtracking/bk-maze-colouring.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func mazeRoutes(_ maze: [[Int]]) -> [String] {
    let rows = maze.count
    let columns = maze[0].count
    guard maze[0][0] == 1, maze[rows - 1][columns - 1] == 1 else { return [] }
    let moves: [(letter: Character, dRow: Int, dColumn: Int)] = [("D", 1, 0), ("L", 0, -1), ("R", 0, 1), ("U", -1, 0)]
    var visited = Array(repeating: Array(repeating: false, count: columns), count: rows)
    var route: [Character] = []
    var routes: [String] = []

    func walk(_ row: Int, _ column: Int) {
        if row == rows - 1 && column == columns - 1 {       // reached the exit
            routes.append(String(route))
            return
        }
        visited[row][column] = true                         // choose: this cell is on the route
        for move in moves {
            let nextRow = row + move.dRow
            let nextColumn = column + move.dColumn
            guard nextRow >= 0, nextRow < rows, nextColumn >= 0, nextColumn < columns,
                  maze[nextRow][nextColumn] == 1, !visited[nextRow][nextColumn] else { continue }
            route.append(move.letter)
            walk(nextRow, nextColumn)                       // explore
            route.removeLast()
        }
        visited[row][column] = false                        // unchoose: free the cell for other routes
    }

    walk(0, 0)
    return routes
}

let maze = [
    [1, 0, 0, 0],
    [1, 1, 0, 1],
    [1, 1, 0, 0],
    [0, 1, 1, 1],
]
print(mazeRoutes(maze))
print(mazeRoutes([[1, 1, 1], [1, 1, 1], [1, 1, 1]]).count, "routes across an open 3 × 3 grid")
