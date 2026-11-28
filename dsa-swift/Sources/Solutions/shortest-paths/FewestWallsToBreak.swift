// Reference solution: Fewest walls to break. Entering an open cell costs 0 and entering a wall costs
// one swing, so the grid is a graph with edge weights 0 and 1: 0-1 BFS. A deque keeps cells in order
// of cost; a free move goes to the front and a wall to the back, so the front is always a cheapest
// unprocessed cell. O(R · C) time and space.

import DSAKit

public enum FewestWallsToBreak {
    public static func minimumWalls(_ grid: [[Int]]) -> Int {
        let rows = grid.count, cols = grid[0].count
        var walls = Array(repeating: Array(repeating: Int.max, count: cols), count: rows)
        walls[0][0] = 0
        var deque = Deque<(row: Int, col: Int, walls: Int)>()
        deque.append((0, 0, 0))
        let steps = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        while let (row, col, broken) = deque.popFirst() {
            if broken > walls[row][col] { continue }     // stale entry
            if row == rows - 1 && col == cols - 1 { return broken }
            for (dr, dc) in steps {
                let r = row + dr, c = col + dc
                guard r >= 0, r < rows, c >= 0, c < cols else { continue }
                let candidate = broken + grid[r][c]
                if candidate < walls[r][c] {
                    walls[r][c] = candidate
                    if grid[r][c] == 0 {
                        deque.prepend((r, c, candidate))
                    } else {
                        deque.append((r, c, candidate))
                    }
                }
            }
        }
        return walls[rows - 1][cols - 1]
    }
}
