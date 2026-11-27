// Generated from src/dsa/content/lessons/patterns/pat-templates-trees-graphs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// DFS on a grid with an explicit stack: count the islands and measure the largest
func islands(_ grid: [[Character]]) -> (count: Int, largest: Int) {
    let rows = grid.count
    let cols = grid.first?.count ?? 0
    var seen = Array(repeating: Array(repeating: false, count: cols), count: rows)
    let moves = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    var count = 0
    var largest = 0
    for row in 0..<rows {
        for col in 0..<cols where grid[row][col] == "#" && !seen[row][col] {
            count += 1                            // a new island starts here
            var size = 0
            var stack = [(row, col)]
            seen[row][col] = true                 // mark when pushed, so nothing is pushed twice
            while let (r, c) = stack.popLast() {
                size += 1
                for (dr, dc) in moves {
                    let nr = r + dr
                    let nc = c + dc
                    guard nr >= 0, nr < rows, nc >= 0, nc < cols,
                          grid[nr][nc] == "#", !seen[nr][nc] else { continue }
                    seen[nr][nc] = true
                    stack.append((nr, nc))
                }
            }
            largest = max(largest, size)
        }
    }
    return (count, largest)
}

let map = ["##..#", "#...#", "..#..", "##.##"].map { Array($0) }
print(islands(map))
