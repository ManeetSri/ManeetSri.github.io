// Generated from src/dsa/content/lessons/graph-traversals/gt-multi-source.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

// Every cell's distance to the nearest 0: all the 0s start in the queue at distance 0
func nearestZero(_ grid: [[Int]]) -> (distance: [[Int]], dequeued: Int) {
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
            guard r >= 0, r < grid.count, c >= 0, c < grid[r].count, distance[r][c] == -1 else { continue }
            distance[r][c] = distance[row][column] + 1
            queue.append((r, c))
        }
    }
    return (distance, head)
}

// The slow way, for comparison: a separate BFS from every 1, stopping at the first 0 it reaches
func dequeuedOneAtATime(_ grid: [[Int]]) -> Int {
    var total = 0
    for row in grid.indices {
        for column in grid[row].indices where grid[row][column] == 1 {
            var seen = grid.map { $0.map { _ in false } }
            seen[row][column] = true
            var queue = [(row, column)]
            var head = 0
            while head < queue.count {
                let (r, c) = queue[head]
                head += 1
                total += 1
                if grid[r][c] == 0 { break }
                for (dr, dc) in directions {
                    let nr = r + dr
                    let nc = c + dc
                    guard nr >= 0, nr < grid.count, nc >= 0, nc < grid[nr].count, !seen[nr][nc] else { continue }
                    seen[nr][nc] = true
                    queue.append((nr, nc))
                }
            }
        }
    }
    return total
}

let small = [
    [1, 1, 1, 1, 1],
    [1, 0, 1, 1, 1],
    [1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1],
]
for row in nearestZero(small).distance {
    print(row)
}

var big = Array(repeating: Array(repeating: 1, count: 30), count: 30)
big[0][0] = 0
print("30 × 30, one zero: multi-source dequeues \(nearestZero(big).dequeued), one BFS per cell dequeues \(dequeuedOneAtATime(big))")
