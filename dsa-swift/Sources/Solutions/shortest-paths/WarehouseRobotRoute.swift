// Reference solution: Robot route across the warehouse. A* search: pop the cell with the smallest
// f = g + h, where g is the cost so far and h is the Manhattan distance to the goal times the cheapest
// cost of any open cell. Every step costs at least that much, so h never overestimates (it's
// admissible, and consistent), and the first time the goal is popped its cost is final. Ties prefer
// the smaller h. Worst case the same as Dijkstra: O(R · C · log(R · C)) time, O(R · C) space.

import DSAKit

public enum WarehouseRobotRoute {
    public static func cheapestRoute(_ floor: [[Int]], start: [Int], goal: [Int]) -> Int {
        let rows = floor.count, cols = floor[0].count
        let cheapestCell = floor.joined().filter { $0 > 0 }.min() ?? 1
        func estimate(_ row: Int, _ col: Int) -> Int {
            (abs(row - goal[0]) + abs(col - goal[1])) * cheapestCell
        }
        var best = Array(repeating: Array(repeating: Int.max, count: cols), count: rows)
        best[start[0]][start[1]] = 0
        var open = Heap<(f: Int, h: Int, row: Int, col: Int)>(areInIncreasingOrder: { ($0.f, $0.h) < ($1.f, $1.h) })
        let startEstimate = estimate(start[0], start[1])
        open.insert((startEstimate, startEstimate, start[0], start[1]))
        let steps = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        while let (f, h, row, col) = open.pop() {
            let g = f - h
            if g > best[row][col] { continue }          // stale entry
            if row == goal[0] && col == goal[1] { return g }
            for (dr, dc) in steps {
                let r = row + dr, c = col + dc
                guard r >= 0, r < rows, c >= 0, c < cols, floor[r][c] > 0 else { continue }
                let candidate = g + floor[r][c]
                if candidate < best[r][c] {
                    best[r][c] = candidate
                    let guess = estimate(r, c)
                    open.insert((candidate + guess, guess, r, c))
                }
            }
        }
        return -1
    }
}
