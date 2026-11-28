// Reference solution: perfect maze audit. A maze of n cells is perfect (a spanning tree) exactly when
// it has n - 1 passages and every cell is reachable from the first: count, then BFS. The longest route
// in a tree is found with two BFS passes: the cell farthest from any start is one end of a longest
// route, and the cell farthest from that end is the other. Everything is iterative, so a maze that's
// one 90,000-cell corridor is fine. O(rows × columns) time and space.

public enum PerfectMazeAudit {
    public static func isPerfect(openRight: [[Bool]], openDown: [[Bool]]) -> Bool {
        guard let maze = Maze(openRight: openRight, openDown: openDown) else { return false }
        guard maze.passageCount == maze.cellCount - 1 else { return false }
        return maze.distances(from: 0).allSatisfy { $0 >= 0 }
    }

    public static func longestRoute(openRight: [[Bool]], openDown: [[Bool]]) -> Int? {
        guard isPerfect(openRight: openRight, openDown: openDown),
              let maze = Maze(openRight: openRight, openDown: openDown) else { return nil }
        let fromFirst = maze.distances(from: 0)
        let end = fromFirst.indices.max { fromFirst[$0] < fromFirst[$1] }!
        return maze.distances(from: end).max()!
    }

    private struct Maze {
        let rows: Int
        let columns: Int
        let openRight: [[Bool]]
        let openDown: [[Bool]]

        init?(openRight: [[Bool]], openDown: [[Bool]]) {
            guard let width = openRight.first?.count, width > 0, openDown.count == openRight.count,
                  openRight.allSatisfy({ $0.count == width }), openDown.allSatisfy({ $0.count == width })
            else { return nil }
            rows = openRight.count
            columns = width
            self.openRight = openRight
            self.openDown = openDown
        }

        var cellCount: Int { rows * columns }

        /// Passages inside the grid (a passage out of the last column or row doesn't lead anywhere)
        var passageCount: Int {
            var count = 0
            for r in 0..<rows {
                for c in 0..<columns {
                    if c + 1 < columns && openRight[r][c] { count += 1 }
                    if r + 1 < rows && openDown[r][c] { count += 1 }
                }
            }
            return count
        }

        func exits(_ cell: Int) -> [Int] {
            let r = cell / columns, c = cell % columns
            var result: [Int] = []
            if c + 1 < columns && openRight[r][c] { result.append(cell + 1) }
            if c > 0 && openRight[r][c - 1] { result.append(cell - 1) }
            if r + 1 < rows && openDown[r][c] { result.append(cell + columns) }
            if r > 0 && openDown[r - 1][c] { result.append(cell - columns) }
            return result
        }

        /// BFS distances from `start`; -1 for cells it can't reach.
        func distances(from start: Int) -> [Int] {
            var distance = [Int](repeating: -1, count: cellCount)
            distance[start] = 0
            var queue = [start]
            var head = 0
            while head < queue.count {
                let cell = queue[head]
                head += 1
                for next in exits(cell) where distance[next] == -1 {
                    distance[next] = distance[cell] + 1
                    queue.append(next)
                }
            }
            return distance
        }
    }
}
