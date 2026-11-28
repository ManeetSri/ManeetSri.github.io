import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct OrchardRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

/// An independent fast reference for the large test: a 2D Fenwick tree stored flat, built by adding
/// each plot in turn, with values set by adding the difference from a copy of the grid.
private struct FlatFenwickOrchard {
    private var tree: [Int]                       // slot (i, j), both from 1, is at i * (columns + 1) + j
    private var plots: [Int]
    private let rows: Int, columns: Int

    init(_ grid: [[Int]]) {
        rows = grid.count
        columns = grid[0].count
        tree = Array(repeating: 0, count: (rows + 1) * (columns + 1))
        plots = Array(repeating: 0, count: rows * columns)
        for r in 0..<rows {
            for c in 0..<columns { set(row: r, column: c, to: grid[r][c]) }
        }
    }

    mutating func set(row: Int, column: Int, to value: Int) {
        let delta = value - plots[row * columns + column]
        plots[row * columns + column] = value
        var i = row + 1
        while i <= rows {
            var j = column + 1
            while j <= columns {
                tree[i * (columns + 1) + j] += delta
                j += j & -j
            }
            i += i & -i
        }
    }

    private func prefix(_ rowCount: Int, _ columnCount: Int) -> Int {
        var total = 0
        var i = rowCount
        while i > 0 {
            var j = columnCount
            while j > 0 {
                total += tree[i * (columns + 1) + j]
                j -= j & -j
            }
            i -= i & -i
        }
        return total
    }

    func total(top: Int, left: Int, bottom: Int, right: Int) -> Int {
        prefix(bottom + 1, right + 1) - prefix(top, right + 1) - prefix(bottom + 1, left) + prefix(top, left)
    }
}

@Suite struct OrchardPlotSumsTests {
    /// Adds up every plot of the rectangle.
    private func direct(_ grid: [[Int]], _ top: Int, _ left: Int, _ bottom: Int, _ right: Int) -> Int {
        var total = 0
        for r in top...bottom {
            for c in left...right { total += grid[r][c] }
        }
        return total
    }

    @Test("The example from the statement")
    func example() {
        var orchard = OrchardPlotSums.Orchard([
            [3, 0, 1, 4],
            [5, 6, 3, 2],
            [1, 2, 0, 1],
        ])
        #expect(orchard.total(top: 0, left: 0, bottom: 2, right: 3) == 28)
        #expect(orchard.total(top: 1, left: 1, bottom: 2, right: 2) == 11)
        orchard.set(row: 1, column: 2, to: 10)
        #expect(orchard.total(top: 1, left: 1, bottom: 2, right: 2) == 18)
        #expect(orchard.total(top: 0, left: 3, bottom: 2, right: 3) == 7)
    }

    @Test("One plot, one row and one column")
    func thin() {
        var single = OrchardPlotSums.Orchard([[9]])
        #expect(single.total(top: 0, left: 0, bottom: 0, right: 0) == 9)
        single.set(row: 0, column: 0, to: 2)
        single.set(row: 0, column: 0, to: 5)
        #expect(single.total(top: 0, left: 0, bottom: 0, right: 0) == 5)

        var row = OrchardPlotSums.Orchard([[1, 2, 3, 4, 5]])
        #expect(row.total(top: 0, left: 1, bottom: 0, right: 3) == 9)
        row.set(row: 0, column: 4, to: 0)
        #expect(row.total(top: 0, left: 0, bottom: 0, right: 4) == 10)

        let column = OrchardPlotSums.Orchard([[1], [2], [3], [4]])
        #expect(column.total(top: 2, left: 0, bottom: 3, right: 0) == 7)
    }

    @Test("Matches adding up every plot on 200 small random orchards")
    func randomSmall() {
        var random = OrchardRandom(seed: 68)
        for _ in 0..<200 {
            let rows = Int.random(in: 1...7, using: &random), columns = Int.random(in: 1...7, using: &random)
            var grid = (0..<rows).map { _ in (0..<columns).map { _ in Int.random(in: 0...20, using: &random) } }
            var orchard = OrchardPlotSums.Orchard(grid)
            for _ in 0..<30 {
                if Bool.random(using: &random) {
                    let r = Int.random(in: 0..<rows, using: &random), c = Int.random(in: 0..<columns, using: &random)
                    let value = Int.random(in: 0...20, using: &random)
                    grid[r][c] = value
                    orchard.set(row: r, column: c, to: value)
                } else {
                    let r1 = Int.random(in: 0..<rows, using: &random), r2 = Int.random(in: 0..<rows, using: &random)
                    let c1 = Int.random(in: 0..<columns, using: &random), c2 = Int.random(in: 0..<columns, using: &random)
                    let top = min(r1, r2), bottom = max(r1, r2), left = min(c1, c2), right = max(c1, c2)
                    #expect(orchard.total(top: top, left: left, bottom: bottom, right: right) == direct(grid, top, left, bottom, right))
                }
            }
        }
    }

    @Test("A 500 × 500 orchard with 100,000 changes and large rectangles")
    func large() {
        // Adding up every plot would visit about 10¹⁰ plots. The reference is a separately written 2D
        // Fenwick tree, stored flat.
        var random = OrchardRandom(seed: 2_034)
        let size = 500
        let grid = (0..<size).map { _ in (0..<size).map { _ in Int.random(in: 0...1_000_000_000, using: &random) } }
        var orchard = OrchardPlotSums.Orchard(grid)
        var reference = FlatFenwickOrchard(grid)
        var mismatches = 0
        for step in 0..<100_000 {
            if step % 2 == 0 {
                let r = Int.random(in: 0..<size, using: &random), c = Int.random(in: 0..<size, using: &random)
                let value = Int.random(in: 0...1_000_000_000, using: &random)
                orchard.set(row: r, column: c, to: value)
                reference.set(row: r, column: c, to: value)
            } else {
                let top = Int.random(in: 0..<50, using: &random), bottom = size - 1 - Int.random(in: 0..<50, using: &random)
                let left = Int.random(in: 0..<50, using: &random), right = size - 1 - Int.random(in: 0..<50, using: &random)
                if orchard.total(top: top, left: left, bottom: bottom, right: right)
                    != reference.total(top: top, left: left, bottom: bottom, right: right) {
                    mismatches += 1
                }
            }
        }
        #expect(mismatches == 0)
    }
}
