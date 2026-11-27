// Generated from src/dsa/content/lessons/queues/queue-bfs-preview.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let grid = [
    "S..#.",
    ".#...",
    ".#.#.",
    "...#T",
]
let cells = grid.map { Array($0) }
let rows = cells.count
let columns = cells[0].count
let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]     // up, down, left, right

var distance = Array(repeating: Array(repeating: -1, count: columns), count: rows)
var queue: [(Int, Int)] = [(0, 0)]                      // a head-index queue of (row, column)
var head = 0
distance[0][0] = 0

while head < queue.count {
    let (row, column) = queue[head]
    head += 1
    for (dr, dc) in directions {
        let r = row + dr
        let c = column + dc
        guard r >= 0, r < rows, c >= 0, c < columns else { continue }   // off the grid
        guard cells[r][c] != "#", distance[r][c] == -1 else { continue } // wall, or seen
        distance[r][c] = distance[row][column] + 1                       // mark as you enqueue
        queue.append((r, c))
    }
}

for r in 0..<rows {
    let line = (0..<columns).map { c in cells[r][c] == "#" ? "#" : String(distance[r][c]) }
    print(line.joined(separator: " "))
}
print("steps to T:", distance[3][4], "cells visited:", queue.count)
