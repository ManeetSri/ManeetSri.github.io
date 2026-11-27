// Reference solution: Every route through the maze. Depth-first search from the top-left cell,
// marking each cell visited on the way in and unmarking it on the way out, so a route never crosses
// itself but different routes may share cells. Trying the moves in the order D, L, R, U makes the
// routes come out in alphabetical order with no sorting: no route can extend another, because the
// search stops as soon as it reaches the exit.
// Exponential in the worst case (8,512 routes across an open 5 × 5 maze); O(rows · columns) space.

public enum MazeRunnerPaths {
    public static func paths(_ maze: [[Int]]) -> [String] {
        guard let columns = maze.first?.count, columns > 0 else { return [] }
        let rows = maze.count
        guard maze[0][0] == 1, maze[rows - 1][columns - 1] == 1 else { return [] }
        let moves: [(letter: Character, dRow: Int, dColumn: Int)] = [("D", 1, 0), ("L", 0, -1), ("R", 0, 1), ("U", -1, 0)]
        var visited = Array(repeating: Array(repeating: false, count: columns), count: rows)
        var route: [Character] = []
        var result: [String] = []

        func walk(_ row: Int, _ column: Int) {
            if row == rows - 1 && column == columns - 1 {
                result.append(String(route))
                return
            }
            visited[row][column] = true                             // choose this cell
            for move in moves {
                let nextRow = row + move.dRow
                let nextColumn = column + move.dColumn
                guard nextRow >= 0, nextRow < rows, nextColumn >= 0, nextColumn < columns,
                      maze[nextRow][nextColumn] == 1, !visited[nextRow][nextColumn] else { continue }
                route.append(move.letter)
                walk(nextRow, nextColumn)                           // explore
                route.removeLast()
            }
            visited[row][column] = false                            // unchoose
        }

        walk(0, 0)
        return result
    }
}
