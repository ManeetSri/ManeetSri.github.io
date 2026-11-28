// Generated from src/dsa/content/lessons/capstones/cap-maze.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The course's seeded generator
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
    mutating func shuffle<T>(_ items: inout [T]) {
        for i in stride(from: items.count - 1, to: 0, by: -1) {
            items.swapAt(i, roll(0...i))
        }
    }
}

/// Union-find with path halving and union by size, as in "Path compression and union by rank"
struct UnionFind {
    private var parent: [Int]
    private var size: [Int]
    init(count: Int) {
        parent = Array(0..<count)
        size = Array(repeating: 1, count: count)
    }
    mutating func find(_ x: Int) -> Int {
        var x = x
        while parent[x] != x {
            parent[x] = parent[parent[x]]
            x = parent[x]
        }
        return x
    }
    mutating func union(_ a: Int, _ b: Int) -> Bool {
        var (ra, rb) = (find(a), find(b))
        if ra == rb { return false }
        if size[ra] < size[rb] { swap(&ra, &rb) }
        parent[rb] = ra
        size[ra] += size[rb]
        return true
    }
}

/// A grid of cells; cell r * columns + c. A passage is a wall that has been knocked down.
struct Maze {
    let rows: Int
    let columns: Int
    private(set) var openRight: [[Bool]]       // a passage from (r, c) to (r, c + 1)
    private(set) var openDown: [[Bool]]        // a passage from (r, c) to (r + 1, c)

    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        openRight = Array(repeating: Array(repeating: false, count: columns), count: rows)
        openDown = openRight
    }

    var cellCount: Int { rows * columns }

    /// Neighbouring cells inside the grid, whether or not a wall is in the way
    func around(_ cell: Int) -> [Int] {
        let r = cell / columns, c = cell % columns
        var result: [Int] = []
        if r > 0 { result.append(cell - columns) }
        if c < columns - 1 { result.append(cell + 1) }
        if r < rows - 1 { result.append(cell + columns) }
        if c > 0 { result.append(cell - 1) }
        return result
    }

    /// Neighbours in the same row share a right-hand wall. Comparing rows, not `high - low == 1`, keeps a
    /// one-column maze right: there, the cell below is also one number up.
    func isOpen(_ a: Int, _ b: Int) -> Bool {
        let (low, high) = (min(a, b), max(a, b))
        return low / columns == high / columns ? openRight[low / columns][low % columns] : openDown[low / columns][low % columns]
    }

    mutating func knockDown(_ a: Int, _ b: Int) {
        let (low, high) = (min(a, b), max(a, b))
        if low / columns == high / columns {
            openRight[low / columns][low % columns] = true
        } else {
            openDown[low / columns][low % columns] = true
        }
    }

    func exits(_ cell: Int) -> [Int] { around(cell).filter { isOpen(cell, $0) } }
}

/// Randomised depth-first search: walk to a random unvisited neighbour; back up when there's none
func depthFirstMaze(rows: Int, columns: Int, dice: inout Dice) -> Maze {
    var maze = Maze(rows: rows, columns: columns)
    var visited = Array(repeating: false, count: maze.cellCount)
    var stack = [0]                                       // an explicit stack: no recursion depth limit
    visited[0] = true
    while let cell = stack.last {
        let fresh = maze.around(cell).filter { !visited[$0] }
        if fresh.isEmpty {
            stack.removeLast()
            continue
        }
        let next = fresh[dice.roll(0...(fresh.count - 1))]
        maze.knockDown(cell, next)
        visited[next] = true
        stack.append(next)
    }
    return maze
}

/// Randomised Kruskal: knock down walls in random order, unless the two sides are already connected
func kruskalMaze(rows: Int, columns: Int, dice: inout Dice) -> Maze {
    var maze = Maze(rows: rows, columns: columns)
    var walls: [(Int, Int)] = []
    for cell in 0..<maze.cellCount {
        for other in maze.around(cell) where other > cell {
            walls.append((cell, other))
        }
    }
    dice.shuffle(&walls)
    var sets = UnionFind(count: maze.cellCount)
    for (a, b) in walls where sets.union(a, b) {
        maze.knockDown(a, b)
    }
    return maze
}

/// BFS from the top-left cell: the shortest path to the bottom-right one
func solve(_ maze: Maze) -> [Int] {
    var previous = Array(repeating: -1, count: maze.cellCount)
    var queue = [0], head = 0
    previous[0] = 0
    while head < queue.count {
        let cell = queue[head]
        head += 1
        for next in maze.exits(cell) where previous[next] == -1 {
            previous[next] = cell
            queue.append(next)
        }
    }
    var path = [maze.cellCount - 1]
    while path.last! != 0 { path.append(previous[path.last!]) }
    return path.reversed()
}

func draw(_ maze: Maze, path: [Int]) {
    let onPath = Set(path)
    print("+" + String(repeating: "---+", count: maze.columns))
    for r in 0..<maze.rows {
        var cells = "|", floor = "+"
        for c in 0..<maze.columns {
            let cell = r * maze.columns + c
            cells += (onPath.contains(cell) ? " o " : "   ") + (maze.openRight[r][c] ? " " : "|")
            floor += (maze.openDown[r][c] ? "   " : "---") + "+"
        }
        print(cells)
        print(floor)
    }
}

func stats(_ maze: Maze) -> (passages: Int, deadEnds: Int, pathLength: Int) {
    let passages = (0..<maze.cellCount).reduce(0) { $0 + maze.exits($1).count } / 2
    let deadEnds = (0..<maze.cellCount).filter { maze.exits($0).count == 1 }.count
    return (passages, deadEnds, solve(maze).count - 1)
}

var dice = Dice(seed: 10)
for (name, maze) in [("depth-first", depthFirstMaze(rows: 5, columns: 8, dice: &dice)),
                     ("Kruskal", kruskalMaze(rows: 5, columns: 8, dice: &dice))] {
    let s = stats(maze)
    print("\(name): \(s.passages) passages for \(maze.cellCount) cells, \(s.deadEnds) dead ends, path \(s.pathLength) steps")
    draw(maze, path: solve(maze))
}

// Texture over many mazes: 20 seeds of 20 × 20 each
var totals = (depthFirst: (0, 0), kruskal: (0, 0))
for seed in 1...20 {
    var d = Dice(seed: UInt64(seed))
    let a = stats(depthFirstMaze(rows: 20, columns: 20, dice: &d))
    let b = stats(kruskalMaze(rows: 20, columns: 20, dice: &d))
    totals.depthFirst = (totals.depthFirst.0 + a.deadEnds, totals.depthFirst.1 + a.pathLength)
    totals.kruskal = (totals.kruskal.0 + b.deadEnds, totals.kruskal.1 + b.pathLength)
}
print("20 × 20, average of 20 seeds: depth-first \(totals.depthFirst.0 / 20) dead ends, path \(totals.depthFirst.1 / 20);",
      "Kruskal \(totals.kruskal.0 / 20) dead ends, path \(totals.kruskal.1 / 20)")
