import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TwoSeaDrainageTests {
    /// The slow, obvious answer for small maps: from every cell, follow water downhill and see
    /// which edges it reaches
    private func bruteForce(_ heights: [[Int]]) -> [[Int]] {
        guard let columns = heights.first?.count, columns > 0 else { return [] }
        let rows = heights.count
        var result: [[Int]] = []
        for row in 0..<rows {
            for column in 0..<columns {
                var seen = Set([row * columns + column])
                var stack = [(row, column)]
                var northWest = false
                var southEast = false
                while let cell = stack.popLast() {
                    let (r, c) = cell
                    if r == 0 || c == 0 { northWest = true }
                    if r == rows - 1 || c == columns - 1 { southEast = true }
                    for (nr, nc) in [(r - 1, c), (r + 1, c), (r, c - 1), (r, c + 1)]
                    where nr >= 0 && nr < rows && nc >= 0 && nc < columns && heights[nr][nc] <= heights[r][c] {
                        if seen.insert(nr * columns + nc).inserted {
                            stack.append((nr, nc))
                        }
                    }
                }
                if northWest && southEast { result.append([row, column]) }
            }
        }
        return result
    }

    @Test("Small maps")
    func examples() {
        #expect(TwoSeaDrainage.cells([[1, 2, 3], [8, 9, 4], [7, 6, 5]])
            == [[0, 2], [1, 0], [1, 1], [1, 2], [2, 0], [2, 1], [2, 2]])
        #expect(TwoSeaDrainage.cells([[5, 5, 5], [5, 1, 5], [5, 5, 5]])
            == [[0, 0], [0, 1], [0, 2], [1, 0], [1, 2], [2, 0], [2, 1], [2, 2]])
        #expect(TwoSeaDrainage.cells([[3, 1, 2]]) == [[0, 0], [0, 1], [0, 2]])
        #expect(TwoSeaDrainage.cells([[2], [9], [4]]) == [[0, 0], [1, 0], [2, 0]])
        #expect(TwoSeaDrainage.cells([[7]]) == [[0, 0]])
        #expect(TwoSeaDrainage.cells([[4, 4], [4, 4]]) == [[0, 0], [0, 1], [1, 0], [1, 1]])
    }

    @Test("An empty map")
    func empty() {
        #expect(TwoSeaDrainage.cells([]) == [])
    }

    @Test("Matches the slow answer on 300 small random maps")
    func randomMaps() {
        var seed: UInt64 = 42
        func random(_ bound: Int) -> Int {
            seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return Int((seed >> 33) % UInt64(bound))
        }
        for _ in 0..<300 {
            let rows = 1 + random(7)
            let columns = 1 + random(7)
            let heights = (0..<rows).map { _ in (0..<columns).map { _ in random(5) } }
            let expected = bruteForce(heights)
            let actual = TwoSeaDrainage.cells(heights)
            if actual != expected {
                Issue.record("heights \(heights) should give \(expected), not \(actual)")
                return                                   // one wrong map is enough to look at
            }
        }
    }

    @Test("A 1000 × 1000 slope rising to the south-east")
    func slope() {
        // Height row + column: everything drains north-west, but only the bottom row and right
        // column touch the south-east sea, since water can't flow uphill to reach it
        let size = 1_000
        let heights = (0..<size).map { row in (0..<size).map { row + $0 } }
        var expected = (0..<(size - 1)).map { [$0, size - 1] }
        expected += (0..<size).map { [size - 1, $0] }
        expectSameCells(TwoSeaDrainage.cells(heights), expected, "slope")
    }

    @Test("A flat 600 × 600 plain drains everywhere")
    func plain() {
        // Level ground lets water go anywhere. A recursive search could go 360,000 calls deep here.
        let size = 600
        let heights = Array(repeating: Array(repeating: 3, count: size), count: size)
        let expected = (0..<size).flatMap { row in (0..<size).map { [row, $0] } }
        expectSameCells(TwoSeaDrainage.cells(heights), expected, "flat plain")
    }
}

/// Compares two long lists of cells and reports only the first difference, rather than printing
/// hundreds of thousands of cells when they don't match
private func expectSameCells(_ actual: [[Int]], _ expected: [[Int]], _ what: String) {
    guard actual.count == expected.count else {
        Issue.record("\(what): expected \(expected.count) cells, got \(actual.count)")
        return
    }
    if let index = expected.indices.first(where: { actual[$0] != expected[$0] }) {
        Issue.record("\(what): entry \(index) should be \(expected[index]), not \(actual[index])")
    }
}
