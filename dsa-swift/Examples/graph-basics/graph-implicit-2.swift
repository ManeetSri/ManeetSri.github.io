// Generated from src/dsa/content/lessons/graph-basics/graph-implicit.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Fix 1: a tiny struct. Swift writes == and hash(into:) for you.
struct Cell: Hashable {
    let row: Int
    let column: Int
}
var visited: Set<Cell> = [Cell(row: 0, column: 0)]
visited.insert(Cell(row: 2, column: 3))
print(visited.contains(Cell(row: 2, column: 3)), visited.count)

// Fix 2: one Int per cell, numbering the grid row by row
let columns = 4
func id(_ row: Int, _ column: Int) -> Int { row * columns + column }
func position(of id: Int) -> (row: Int, column: Int) { (id / columns, id % columns) }
print(id(2, 3), position(of: 11))

// With ids, a flat array of Bool replaces the set
var seen = Array(repeating: false, count: 3 * columns)
seen[id(2, 3)] = true
print(seen.filter { $0 }.count)
