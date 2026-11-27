// Generated from src/dsa/content/lessons/graph-traversals/gt-islands.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

/// The area of every island, in the order the scan meets them
func islandAreas(_ map: [[Character]]) -> [Int] {
    var grid = map                                      // a copy we're free to change
    var areas: [Int] = []
    for row in grid.indices {
        for column in grid[row].indices where grid[row][column] == "#" {
            grid[row][column] = "~"                     // sink it: land becomes water
            var stack = [(row, column)]
            var area = 0
            while let cell = stack.popLast() {
                area += 1
                for (dr, dc) in directions {
                    let r = cell.0 + dr
                    let c = cell.1 + dc
                    guard r >= 0, r < grid.count, c >= 0, c < grid[r].count else { continue }
                    guard grid[r][c] == "#" else { continue }
                    grid[r][c] = "~"
                    stack.append((r, c))
                }
            }
            areas.append(area)
        }
    }
    return areas
}

let map = [
    "##..#",
    "#...#",
    "..#..",
    ".###.",
    "#....",
].map { Array($0) }

let areas = islandAreas(map)
print("islands:", areas.count)
print("areas:", areas)
print("largest:", areas.max() ?? 0)
print("map unchanged:", String(map[0]))
