// Reference solution: Count and measure the islands. Scan every cell; each land cell not yet visited
// starts a new island, and an iterative DFS (an explicit stack, not recursion, so a snake-shaped
// island of half a million cells is fine) visits all of it, counting its cells. The grid is first
// copied into a [[Bool]] of unvisited land, which the search clears as it goes. O(rows × columns)
// time and space.

public enum IslandSurvey {
    private static let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

    public static func count(_ grid: [[Character]]) -> Int {
        islandAreas(grid).count
    }

    public static func largestArea(_ grid: [[Character]]) -> Int {
        islandAreas(grid).max() ?? 0
    }

    /// The area of every island, in the order their first cells are met
    private static func islandAreas(_ grid: [[Character]]) -> [Int] {
        var unvisited = grid.map { row in row.map { $0 == "1" } }
        var areas: [Int] = []
        for row in unvisited.indices {
            for column in unvisited[row].indices where unvisited[row][column] {
                unvisited[row][column] = false
                var stack = [(row, column)]
                var area = 0
                while let cell = stack.popLast() {
                    area += 1
                    for (dr, dc) in directions {
                        let r = cell.0 + dr
                        let c = cell.1 + dc
                        guard r >= 0, r < unvisited.count, c >= 0, c < unvisited[r].count else { continue }
                        guard unvisited[r][c] else { continue }
                        unvisited[r][c] = false
                        stack.append((r, c))
                    }
                }
                areas.append(area)
            }
        }
        return areas
    }
}
