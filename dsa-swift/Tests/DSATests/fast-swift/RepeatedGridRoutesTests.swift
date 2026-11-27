import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same grids
private struct RouteRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RepeatedGridRoutesTests {
    typealias Router = RepeatedGridRoutes.Router

    /// A plain BFS with fresh arrays for every query. Fine for small grids.
    private func reference(_ grid: [[Character]], _ from: (Int, Int), _ to: (Int, Int)) -> Int {
        let rows = grid.count, columns = grid[0].count
        var distance = Array(repeating: Array(repeating: -1, count: columns), count: rows)
        distance[from.0][from.1] = 0
        var queue = [from]
        var head = 0
        while head < queue.count {
            let (row, column) = queue[head]
            head += 1
            for (dr, dc) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                let r = row + dr, c = column + dc
                if r >= 0, r < rows, c >= 0, c < columns, grid[r][c] == ".", distance[r][c] == -1 {
                    distance[r][c] = distance[row][column] + 1
                    queue.append((r, c))
                }
            }
        }
        return distance[to.0][to.1]
    }

    @Test("Examples")
    func examples() {
        var router = Router(grid: [
            "....",
            ".##.",
            "...#",
            "#...",
        ])
        #expect(router.distance(fromRow: 0, fromColumn: 0, toRow: 3, toColumn: 3) == 6)
        #expect(router.distance(fromRow: 0, fromColumn: 3, toRow: 3, toColumn: 3) == 9)
        #expect(router.distance(fromRow: 1, fromColumn: 0, toRow: 2, toColumn: 2) == 3)
        #expect(router.distance(fromRow: 2, fromColumn: 1, toRow: 2, toColumn: 1) == 0)
        #expect(router.distance(fromRow: 3, fromColumn: 3, toRow: 0, toColumn: 3) == 9)
    }

    @Test("Unreachable targets give -1, and later queries still work")
    func unreachable() {
        var router = Router(grid: [
            ".#.",
            "##.",
            "...",
        ])
        #expect(router.distance(fromRow: 0, fromColumn: 0, toRow: 2, toColumn: 2) == -1)
        #expect(router.distance(fromRow: 2, fromColumn: 2, toRow: 0, toColumn: 0) == -1)
        #expect(router.distance(fromRow: 0, fromColumn: 2, toRow: 2, toColumn: 0) == 4)
        #expect(router.distance(fromRow: 0, fromColumn: 0, toRow: 0, toColumn: 0) == 0)
    }

    @Test("A single row and a single column")
    func thinGrids() {
        var row = Router(grid: [".....#."])
        #expect(row.distance(fromRow: 0, fromColumn: 0, toRow: 0, toColumn: 4) == 4)
        #expect(row.distance(fromRow: 0, fromColumn: 4, toRow: 0, toColumn: 6) == -1)
        var column = Router(grid: [".", ".", "."])
        #expect(column.distance(fromRow: 2, fromColumn: 0, toRow: 0, toColumn: 0) == 2)
    }

    @Test("One router answers 6,000 queries on 200 random grids, matching a fresh BFS each time")
    func randomSmall() {
        var random = RouteRandom(seed: 68)
        for _ in 0..<200 {
            let rows = Int.random(in: 1...9, using: &random)
            let columns = Int.random(in: 1...9, using: &random)
            let grid: [[Character]] = (0..<rows).map { _ in
                (0..<columns).map { _ in Int.random(in: 0..<10, using: &random) < 3 ? "#" : "." }
            }
            let openCells = (0..<rows).flatMap { r in (0..<columns).compactMap { c in grid[r][c] == "." ? (r, c) : nil } }
            if openCells.isEmpty { continue }
            var router = Router(grid: grid.map { String($0) })
            for _ in 0..<30 {
                let from = openCells.randomElement(using: &random)!
                let to = openCells.randomElement(using: &random)!
                let got = router.distance(fromRow: from.0, fromColumn: from.1, toRow: to.0, toColumn: to.1)
                #expect(got == reference(grid, from, to), "from \(from) to \(to)")
            }
        }
    }

    /// A size × size grid of open cells, with a wall down column size / 2 that has one gap in the bottom
    /// row, and a walled-in room whose border is rows and columns `room` (in both directions).
    private func walledGrid(size: Int, room: ClosedRange<Int>) -> [String] {
        let open = UInt8(ascii: "."), wall = UInt8(ascii: "#")
        var cells = Array(repeating: Array(repeating: open, count: size), count: size)
        for row in 0..<(size - 1) {
            cells[row][size / 2] = wall
        }
        for i in room {
            cells[room.lowerBound][i] = wall
            cells[room.upperBound][i] = wall
            cells[i][room.lowerBound] = wall
            cells[i][room.upperBound] = wall
        }
        return cells.map { String(decoding: $0, as: UTF8.self) }
    }

    @Test("Long routes: around a wall, and into and out of a closed room")
    func longRoutes() {
        var router = Router(grid: walledGrid(size: 200, room: 20...30))
        // Across the wall at column 100: down to the gap at row 199 and back up
        #expect(router.distance(fromRow: 0, fromColumn: 99, toRow: 0, toColumn: 101) == 400)
        #expect(router.distance(fromRow: 100, fromColumn: 0, toRow: 100, toColumn: 199) == 397)
        // Inside the room, out of it, and into it
        #expect(router.distance(fromRow: 25, fromColumn: 25, toRow: 21, toColumn: 29) == 8)
        #expect(router.distance(fromRow: 25, fromColumn: 25, toRow: 0, toColumn: 0) == -1)
        #expect(router.distance(fromRow: 0, fromColumn: 0, toRow: 25, toColumn: 25) == -1)
        // Short queries still work after the long ones
        #expect(router.distance(fromRow: 10, fromColumn: 10, toRow: 12, toColumn: 9) == 3)
        #expect(router.distance(fromRow: 199, fromColumn: 99, toRow: 199, toColumn: 101) == 2)
    }

    @Test("20,000 short queries on a 1000 × 1000 grid")
    func manyShortQueries() {
        let size = 1_000
        var router = Router(grid: walledGrid(size: size, room: 100...110))

        // In open space, the route is the straight-line (Manhattan) distance whenever the rectangle
        // spanned by the two cells contains no wall.
        func rectangleIsOpen(_ r1: Int, _ c1: Int, _ r2: Int, _ c2: Int) -> Bool {
            let rowRange = min(r1, r2)...max(r1, r2), columnRange = min(c1, c2)...max(c1, c2)
            if columnRange.contains(size / 2) { return false }
            if rowRange.overlaps(99...111) && columnRange.overlaps(99...111) { return false }
            return true
        }
        var random = RouteRandom(seed: 2_026)
        var asked = 0
        var wrong = 0
        while asked < 20_000 {
            let r1 = Int.random(in: 0..<size, using: &random), c1 = Int.random(in: 0..<size, using: &random)
            let r2 = r1 + Int.random(in: -2...2, using: &random), c2 = c1 + Int.random(in: -2...2, using: &random)
            guard r2 >= 0, r2 < size, c2 >= 0, c2 < size, rectangleIsOpen(r1, c1, r2, c2) else { continue }
            asked += 1
            if router.distance(fromRow: r1, fromColumn: c1, toRow: r2, toColumn: c2) != abs(r1 - r2) + abs(c1 - c2) {
                wrong += 1
            }
        }
        #expect(wrong == 0)
        // A few around the walls that are still cheap to answer
        #expect(router.distance(fromRow: 999, fromColumn: 499, toRow: 999, toColumn: 501) == 2)
        #expect(router.distance(fromRow: 105, fromColumn: 105, toRow: 101, toColumn: 109) == 8)
        #expect(router.distance(fromRow: 105, fromColumn: 105, toRow: 0, toColumn: 0) == -1)
    }
}
