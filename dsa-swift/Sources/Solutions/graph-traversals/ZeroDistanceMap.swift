// Reference solution: Steps to the nearest zero. Multi-source BFS: every 0 goes into the queue at
// distance 0 before the search starts, and every other cell starts at -1 (not reached). The rings
// then grow from all the zeros at once, so each cell is first reached from its nearest zero. Each
// cell is enqueued once: O(rows × columns) time and space. With no zeros, nothing is ever reached
// and every cell stays -1.

public enum ZeroDistanceMap {
    private static let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

    public static func distances(_ grid: [[Int]]) -> [[Int]] {
        var distance = grid.map { row in row.map { $0 == 0 ? 0 : -1 } }
        var queue: [(Int, Int)] = []
        for row in grid.indices {
            for column in grid[row].indices where grid[row][column] == 0 {
                queue.append((row, column))
            }
        }
        var head = 0
        while head < queue.count {
            let (row, column) = queue[head]
            head += 1
            for (dr, dc) in directions {
                let r = row + dr
                let c = column + dc
                guard r >= 0, r < distance.count, c >= 0, c < distance[r].count else { continue }
                guard distance[r][c] == -1 else { continue }
                distance[r][c] = distance[row][column] + 1
                queue.append((r, c))
            }
        }
        return distance
    }
}
