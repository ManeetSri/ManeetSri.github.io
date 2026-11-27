import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CrossingRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct LastDryCrossingDayTests {
    /// Breadth-first search from every dry top-row cell, after the first `days` floods
    private func canCross(_ rows: Int, _ cols: Int, _ floods: [[Int]], after days: Int) -> Bool {
        var dry = Array(repeating: true, count: rows * cols)
        for flood in floods.prefix(days) {
            dry[flood[0] * cols + flood[1]] = false
        }
        var seen = Array(repeating: false, count: rows * cols)
        var queue: [Int] = []
        for col in 0..<cols where dry[col] {
            seen[col] = true
            queue.append(col)
        }
        var head = 0
        while head < queue.count {
            let cell = queue[head]
            head += 1
            let row = cell / cols
            let col = cell % cols
            if row == rows - 1 { return true }
            for (dr, dc) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
                let r = row + dr
                let c = col + dc
                guard r >= 0, r < rows, c >= 0, c < cols else { continue }
                let next = r * cols + c
                if dry[next], !seen[next] {
                    seen[next] = true
                    queue.append(next)
                }
            }
        }
        return false
    }

    /// Check every day in turn: clearly right, O(days · cells)
    private func byEveryDay(_ rows: Int, _ cols: Int, _ floods: [[Int]]) -> Int {
        var last = 0
        for days in 0...floods.count where canCross(rows, cols, floods, after: days) {
            last = days
        }
        return last
    }

    /// Binary search on the day, with a BFS for each guess: O(cells · log cells)
    private func byBinarySearch(_ rows: Int, _ cols: Int, _ floods: [[Int]]) -> Int {
        var low = 0                       // always crossable: nothing has flooded
        var high = floods.count
        while low < high {
            let mid = (low + high + 1) / 2
            if canCross(rows, cols, floods, after: mid) { low = mid } else { high = mid - 1 }
        }
        return low
    }

    private func shuffledCells(_ rows: Int, _ cols: Int, using random: inout CrossingRandom) -> [[Int]] {
        var cells: [[Int]] = []
        for row in 0..<rows {
            for col in 0..<cols {
                cells.append([row, col])
            }
        }
        cells.shuffle(using: &random)
        return cells
    }

    @Test("Examples and small cases", arguments: [
        (2, 2, [[0, 0], [0, 1], [1, 0], [1, 1]], 1),
        (3, 3, [[1, 1], [0, 0], [2, 2], [1, 0], [0, 2], [1, 2]], 2),
        (3, 3, [[1, 0], [1, 2], [0, 1], [2, 1], [1, 1]], 2),
        (2, 2, [[0, 0]], 1),
        (1, 1, [[0, 0]], 0),
        (2, 3, [], 0),
        (1, 3, [[0, 1], [0, 0], [0, 2]], 2),
        (3, 1, [[2, 0]], 0),
    ] as [(Int, Int, [[Int]], Int)])
    func examples(rows: Int, cols: Int, floods: [[Int]], expected: Int) {
        #expect(LastDryCrossingDay.lastDay(rows: rows, cols: cols, floods: floods) == expected)
    }

    @Test("Matches checking every day, on 400 small fields")
    func randomSmall() {
        var random = CrossingRandom(seed: 359)
        for _ in 0..<400 {
            let rows = Int.random(in: 1...6, using: &random)
            let cols = Int.random(in: 1...6, using: &random)
            let all = shuffledCells(rows, cols, using: &random)
            let floods = Array(all.prefix(Int.random(in: 0...all.count, using: &random)))
            #expect(LastDryCrossingDay.lastDay(rows: rows, cols: cols, floods: floods) == byEveryDay(rows, cols, floods))
        }
    }

    @Test("A 300 × 300 field that floods completely, in random orders")
    func largeRandom() {
        var random = CrossingRandom(seed: 2_359)
        for (rows, cols) in [(300, 300), (100, 900), (900, 100)] {
            let floods = shuffledCells(rows, cols, using: &random)
            #expect(LastDryCrossingDay.lastDay(rows: rows, cols: cols, floods: floods) == byBinarySearch(rows, cols, floods))
        }
    }

    @Test("Thin fields and a planted path")
    func planted() {
        var random = CrossingRandom(seed: 3_359)
        // One row: any dry cell is a crossing, so it lasts until the final cell floods
        let row = shuffledCells(1, 100_000, using: &random)
        #expect(LastDryCrossingDay.lastDay(rows: 1, cols: 100_000, floods: row) == 99_999)
        // One column: the first flood cuts it
        let column = shuffledCells(100_000, 1, using: &random)
        #expect(LastDryCrossingDay.lastDay(rows: 100_000, cols: 1, floods: column) == 0)

        // A path from the top row to the bottom row stepping only down or right, touching each of those
        // rows once. Everything else floods first, in random order, then the path. Removing any path cell
        // cuts it, so the answer is the number of cells off the path.
        let rows = 250
        let cols = 400
        var onPath = Array(repeating: false, count: rows * cols)
        var r = 0
        var c = Int.random(in: 0..<100, using: &random)
        onPath[c] = true
        while r < rows - 1 {
            if r > 0, r < rows - 2, c < cols - 1, Bool.random(using: &random) {
                c += 1
            } else {
                r += 1
            }
            onPath[r * cols + c] = true
        }
        let cells = shuffledCells(rows, cols, using: &random)
        let off = cells.filter { !onPath[$0[0] * cols + $0[1]] }
        let path = cells.filter { onPath[$0[0] * cols + $0[1]] }
        #expect(LastDryCrossingDay.lastDay(rows: rows, cols: cols, floods: off + path) == off.count)
        // Without the path's floods, the field can still be crossed at the very end
        #expect(LastDryCrossingDay.lastDay(rows: rows, cols: cols, floods: off) == off.count)
    }
}
