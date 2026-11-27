import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run builds the same mazes
private struct MazeAuditRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

/// A maze under construction: cells r * columns + c, and the two passage grids
private struct MazeGrid {
    let rows: Int
    let columns: Int
    var openRight: [[Bool]]
    var openDown: [[Bool]]

    init(_ rows: Int, _ columns: Int) {
        self.rows = rows
        self.columns = columns
        openRight = Array(repeating: Array(repeating: false, count: columns), count: rows)
        openDown = openRight
    }

    /// Opens or closes the wall between two neighbouring cells. Cells in the same row are side by
    /// side; otherwise one is above the other (in a one-column maze, those differ by 1 as well).
    mutating func set(_ a: Int, _ b: Int, open: Bool) {
        let low = min(a, b), high = max(a, b)
        if low / columns == high / columns { openRight[low / columns][low % columns] = open }
        else { openDown[low / columns][low % columns] = open }
    }

    mutating func open(_ a: Int, _ b: Int) { set(a, b, open: true) }

    func neighbours(_ cell: Int) -> [Int] {
        let r = cell / columns, c = cell % columns
        var result: [Int] = []
        if r > 0 { result.append(cell - columns) }
        if c + 1 < columns { result.append(cell + 1) }
        if r + 1 < rows { result.append(cell + columns) }
        if c > 0 { result.append(cell - 1) }
        return result
    }

    func isOpen(_ a: Int, _ b: Int) -> Bool {
        let low = min(a, b), high = max(a, b)
        return low / columns == high / columns ? openRight[low / columns][low % columns] : openDown[low / columns][low % columns]
    }

    func exits(_ cell: Int) -> [Int] { neighbours(cell).filter { isOpen(cell, $0) } }
}

@Suite struct PerfectMazeAuditTests {
    private func isPerfect(_ maze: MazeGrid) -> Bool {
        PerfectMazeAudit.isPerfect(openRight: maze.openRight, openDown: maze.openDown)
    }

    private func longest(_ maze: MazeGrid) -> Int? {
        PerfectMazeAudit.longestRoute(openRight: maze.openRight, openDown: maze.openDown)
    }

    /// Randomised depth-first search with an explicit stack, as in the lesson
    private func depthFirstMaze(_ rows: Int, _ columns: Int, _ random: inout MazeAuditRandom) -> MazeGrid {
        var maze = MazeGrid(rows, columns)
        var visited = Array(repeating: false, count: rows * columns)
        var stack = [0]
        visited[0] = true
        while let cell = stack.last {
            let fresh = maze.neighbours(cell).filter { !visited[$0] }
            guard let next = fresh.randomElement(using: &random) else {
                stack.removeLast()
                continue
            }
            maze.open(cell, next)
            visited[next] = true
            stack.append(next)
        }
        return maze
    }

    /// Brute force: BFS from every cell, keeping the largest distance; nil if some cell is unreachable
    private func bruteLongest(_ maze: MazeGrid) -> Int? {
        var best = 0
        for start in 0..<(maze.rows * maze.columns) {
            var distance = Array(repeating: -1, count: maze.rows * maze.columns)
            distance[start] = 0
            var queue = [start]
            var head = 0
            while head < queue.count {
                let cell = queue[head]
                head += 1
                for next in maze.exits(cell) where distance[next] == -1 {
                    distance[next] = distance[cell] + 1
                    queue.append(next)
                }
            }
            if distance.contains(-1) { return nil }
            best = max(best, distance.max()!)
        }
        return best
    }

    /// Brute force for "perfect": no passage closes a loop (union-find), and everything is joined
    private func brutePerfect(_ maze: MazeGrid) -> Bool {
        var parent = Array(0..<(maze.rows * maze.columns))
        func find(_ x: Int) -> Int {
            var x = x
            while parent[x] != x { x = parent[x] }
            return x
        }
        var unions = 0
        for cell in 0..<(maze.rows * maze.columns) {
            for next in maze.exits(cell) where next > cell {
                let (a, b) = (find(cell), find(next))
                if a == b { return false }
                parent[a] = b
                unions += 1
            }
        }
        return unions == maze.rows * maze.columns - 1
    }

    @Test("A single cell is a perfect maze with a longest route of 0")
    func singleCell() {
        let maze = MazeGrid(1, 1)
        #expect(isPerfect(maze))
        #expect(longest(maze) == 0)
    }

    @Test("2 × 2 mazes: too few passages, just right, and a loop")
    func twoByTwo() {
        var maze = MazeGrid(2, 2)
        #expect(!isPerfect(maze), "no passages at all")
        maze.open(0, 1)
        maze.open(0, 2)
        #expect(!isPerfect(maze), "cell 3 is cut off")
        #expect(longest(maze) == nil)
        maze.open(1, 3)
        #expect(isPerfect(maze))
        #expect(longest(maze) == 3)
        maze.open(2, 3)
        #expect(!isPerfect(maze), "a loop")
        #expect(longest(maze) == nil)
    }

    @Test("A corridor and a comb")
    func shapes() {
        var corridor = MazeGrid(1, 6)
        for c in 0..<5 { corridor.open(c, c + 1) }
        #expect(isPerfect(corridor))
        #expect(longest(corridor) == 5)

        var column = MazeGrid(5, 1)                           // one column: neighbours differ by 1 too
        for r in 0..<4 { column.open(r, r + 1) }
        #expect(isPerfect(column))
        #expect(longest(column) == 4)

        // A comb: the top row is a corridor, and every column hangs down from it
        var comb = MazeGrid(4, 5)
        for c in 0..<4 { comb.open(c, c + 1) }
        for c in 0..<5 { for r in 0..<3 { comb.open(r * 5 + c, (r + 1) * 5 + c) } }
        #expect(isPerfect(comb))
        #expect(longest(comb) == 3 + 4 + 3)                  // down a tooth, along the top, down another
    }

    @Test("The right number of passages isn't enough: a loop plus a cut-off cell")
    func countIsNotEnough() {
        var maze = MazeGrid(3, 3)
        // 8 passages for 9 cells, but cells 0, 1, 3, 4 form a loop and cell 8 is cut off
        for (a, b) in [(0, 1), (1, 4), (4, 3), (3, 0), (1, 2), (2, 5), (3, 6), (6, 7)] { maze.open(a, b) }
        #expect(!isPerfect(maze))
        #expect(longest(maze) == nil)
    }

    @Test("Random depth-first mazes match brute force")
    func randomPerfect() {
        var random = MazeAuditRandom(seed: 74)
        var firstMismatch: String? = nil
        for _ in 0..<80 where firstMismatch == nil {
            let maze = depthFirstMaze(Int.random(in: 1...7, using: &random), Int.random(in: 1...7, using: &random), &random)
            let got = longest(maze)
            let expected = bruteLongest(maze)
            if !isPerfect(maze) || got != expected {
                firstMismatch = "\(maze.rows) × \(maze.columns) maze \(maze.openRight) \(maze.openDown): got \(String(describing: got)), expected \(String(describing: expected))"
            }
        }
        #expect(firstMismatch == nil)
    }

    @Test("Random passages, perfect or not, match brute force")
    func randomPassages() {
        var random = MazeAuditRandom(seed: 2_024)
        var firstMismatch: String? = nil
        var perfectSeen = 0
        for _ in 0..<400 where firstMismatch == nil {
            // A depth-first maze with a few random walls opened or closed, so near-misses are common
            var maze = depthFirstMaze(Int.random(in: 1...5, using: &random), Int.random(in: 1...5, using: &random), &random)
            let cells = maze.rows * maze.columns
            for _ in 0..<Int.random(in: 0...2, using: &random) where cells > 1 {
                let cell = Int.random(in: 0..<cells, using: &random)
                if let next = maze.neighbours(cell).randomElement(using: &random) {
                    maze.set(cell, next, open: Bool.random(using: &random))
                }
            }
            let perfect = brutePerfect(maze)
            if perfect { perfectSeen += 1 }
            let expectedLongest = perfect ? bruteLongest(maze) : nil
            if isPerfect(maze) != perfect || longest(maze) != expectedLongest {
                firstMismatch = "\(maze.openRight) \(maze.openDown): expected perfect \(perfect), longest \(String(describing: expectedLongest))"
            }
        }
        #expect(firstMismatch == nil)
        #expect(perfectSeen > 50 && perfectSeen < 350)
    }

    @Test("A 300 × 300 serpentine: one corridor 90,000 cells long")
    func serpentine() {
        let size = 300
        var maze = MazeGrid(size, size)
        for r in 0..<size {
            for c in 0..<(size - 1) { maze.open(r * size + c, r * size + c + 1) }
            if r + 1 < size {
                let c = r % 2 == 0 ? size - 1 : 0                    // turn at alternate ends
                maze.open(r * size + c, (r + 1) * size + c)
            }
        }
        #expect(isPerfect(maze))
        #expect(longest(maze) == size * size - 1)
    }

    @Test("A 200 × 250 depth-first maze")
    func largeRandom() {
        var random = MazeAuditRandom(seed: 300)
        let maze = depthFirstMaze(200, 250, &random)
        // An independent answer: in a tree, the longest route through a cell joins its two deepest
        // branches. Process the cells children-first (reverse BFS order from cell 0).
        let count = 200 * 250
        var parent = Array(repeating: -1, count: count)
        var order = [0]
        var head = 0
        parent[0] = 0
        while head < order.count {
            let cell = order[head]
            head += 1
            for next in maze.exits(cell) where parent[next] == -1 {
                parent[next] = cell
                order.append(next)
            }
        }
        var depth = Array(repeating: 0, count: count)                 // deepest branch below each cell
        var best = 0
        for cell in order.reversed() {
            for next in maze.exits(cell) where parent[next] == cell && next != cell {
                best = max(best, depth[cell] + depth[next] + 1)
                depth[cell] = max(depth[cell], depth[next] + 1)
            }
        }
        #expect(isPerfect(maze))
        #expect(longest(maze) == best)
    }
}
