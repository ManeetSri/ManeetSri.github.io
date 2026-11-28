// Generated from src/dsa/content/lessons/graph-traversals/gt-islands.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A size × size grid whose land is one snake: full rows joined at alternate ends
func snake(_ size: Int) -> [[Bool]] {
    var land = Array(repeating: Array(repeating: false, count: size), count: size)
    for row in stride(from: 0, to: size, by: 2) {
        land[row] = Array(repeating: true, count: size)
    }
    for row in stride(from: 1, to: size, by: 2) {
        land[row][row % 4 == 1 ? size - 1 : 0] = true
    }
    return land
}

// The recursive island walk, measuring how deep the recursion gets
func deepestRecursion(_ land: [[Bool]]) -> (area: Int, depth: Int) {
    var land = land
    var area = 0
    var depth = 0
    var deepest = 0
    func visit(_ r: Int, _ c: Int) {
        guard r >= 0, r < land.count, c >= 0, c < land[r].count, land[r][c] else { return }
        land[r][c] = false
        area += 1
        depth += 1
        deepest = max(deepest, depth)
        visit(r - 1, c)
        visit(r + 1, c)
        visit(r, c - 1)
        visit(r, c + 1)
        depth -= 1
    }
    visit(0, 0)
    return (area, deepest)
}

for size in [10, 40, 100] {
    let result = deepestRecursion(snake(size))
    print("\(size) × \(size) snake: area \(result.area), recursion \(result.depth) calls deep")
}
let open = deepestRecursion(Array(repeating: Array(repeating: true, count: 100), count: 100))
print("100 × 100 all land: area \(open.area), recursion \(open.depth) calls deep")
