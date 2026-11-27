// Generated from src/dsa/content/lessons/shortest-paths/sp-a-star.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The heap from "Build a generic Heap<T>", cut down to insert and pop
struct Heap<Element> {
    private var items: [Element] = []
    private let areInIncreasingOrder: (Element, Element) -> Bool

    init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }

    mutating func insert(_ element: Element) {
        items.append(element)
        var child = items.count - 1
        while child > 0 && areInIncreasingOrder(items[child], items[(child - 1) / 2]) {
            items.swapAt(child, (child - 1) / 2)
            child = (child - 1) / 2
        }
    }

    mutating func pop() -> Element? {
        guard !items.isEmpty else { return nil }
        items.swapAt(0, items.count - 1)
        let top = items.removeLast()
        var parent = 0
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var first = parent
            if left < items.count && areInIncreasingOrder(items[left], items[first]) { first = left }
            if right < items.count && areInIncreasingOrder(items[right], items[first]) { first = right }
            if first == parent { break }
            items.swapAt(parent, first)
            parent = first
        }
        return top
    }
}

let rows = [
    "S....#......",
    ".....#......",
    ".....#......",
    ".....#....#.",
    ".....#....#G",
    "..........#.",
]
let grid = rows.map { Array($0) }
let height = grid.count, width = grid[0].count
let start = (row: 0, col: 0), goal = (row: 4, col: 11)

/// Cheapest number of steps from start to goal. Each step costs 1; `heuristic` estimates the rest.
func search(heuristic: (Int, Int) -> Int) -> (cost: Int, expanded: [[Bool]]) {
    var best = Array(repeating: Array(repeating: Int.max, count: width), count: height)
    var expanded = Array(repeating: Array(repeating: false, count: width), count: height)
    // Entries are (f, h, row, col): smallest f = g + h first, then the one that looks closer to the goal
    var open = Heap<(f: Int, h: Int, row: Int, col: Int)>(areInIncreasingOrder: { ($0.f, $0.h, $0.row, $0.col) < ($1.f, $1.h, $1.row, $1.col) })
    best[start.row][start.col] = 0
    open.insert((heuristic(start.row, start.col), heuristic(start.row, start.col), start.row, start.col))
    while let entry = open.pop() {
        let g = entry.f - entry.h
        if g > best[entry.row][entry.col] { continue }             // stale
        expanded[entry.row][entry.col] = true
        if (entry.row, entry.col) == (goal.row, goal.col) { return (g, expanded) }
        for (dr, dc) in [(0, 1), (1, 0), (0, -1), (-1, 0)] {
            let r = entry.row + dr, c = entry.col + dc
            guard r >= 0, r < height, c >= 0, c < width, grid[r][c] != "#" else { continue }
            if g + 1 < best[r][c] {
                best[r][c] = g + 1
                let h = heuristic(r, c)
                open.insert((g + 1 + h, h, r, c))
            }
        }
    }
    return (-1, expanded)
}

func report(_ name: String, _ result: (cost: Int, expanded: [[Bool]])) {
    let count = result.expanded.joined().filter { $0 }.count
    print("\(name): cost \(result.cost), expanded \(count) cells")
    for r in 0..<height {
        print(String((0..<width).map { c in
            grid[r][c] != "." ? grid[r][c] : (result.expanded[r][c] ? "*" : ".")
        }))
    }
}

report("Dijkstra", search(heuristic: { _, _ in 0 }))
report("A* with Manhattan distance", search(heuristic: { r, c in abs(r - goal.row) + abs(c - goal.col) }))
