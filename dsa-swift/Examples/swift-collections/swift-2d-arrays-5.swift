// Generated from src/dsa/content/lessons/swift-collections/swift-2d-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

func landNeighbours(_ grid: [[Int]], _ row: Int, _ col: Int) -> Int {
    var count = 0
    for (dr, dc) in directions {
        let r = row + dr
        let c = col + dc
        if r >= 0 && r < grid.count && c >= 0 && c < grid[r].count && grid[r][c] == 1 {
            count += 1
        }
    }
    return count
}

let map = [
    [0, 1, 0],
    [1, 1, 1],
    [0, 1, 0],
]
print(landNeighbours(map, 1, 1))
print(landNeighbours(map, 0, 0))
print(landNeighbours(map, 0, 1))
