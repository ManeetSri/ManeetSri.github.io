import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TargetSumSubmatricesTests {
    /// Tries every rectangle, adding up its cells.
    private static func slowCount(_ grid: [[Int]], _ target: Int) -> Int {
        let rows = grid.count
        let columns = grid.first?.count ?? 0
        var count = 0
        for top in 0..<rows {
            for bottom in top..<rows {
                for left in 0..<columns {
                    for right in left..<columns {
                        var sum = 0
                        for r in top...bottom {
                            for c in left...right {
                                sum += grid[r][c]
                            }
                        }
                        if sum == target { count += 1 }
                    }
                }
            }
        }
        return count
    }

    @Test("Counts the example grids")
    func examples() {
        #expect(TargetSumSubmatrices.count(in: [[1, -1], [-1, 1]], summingTo: 0) == 5)
        #expect(TargetSumSubmatrices.count(in: [[2, 1, 3], [0, 3, 1]], summingTo: 3) == 4)
        #expect(TargetSumSubmatrices.count(in: [[4]], summingTo: 4) == 1)
        #expect(TargetSumSubmatrices.count(in: [[4]], summingTo: 3) == 0)
    }

    @Test("A single row or column behaves like a 1D array")
    func thinGrids() {
        #expect(TargetSumSubmatrices.count(in: [[1, 2, -1, 3, -2, 2]], summingTo: 3) == 4)
        #expect(TargetSumSubmatrices.count(in: [[1], [2], [-1], [3], [-2], [2]], summingTo: 3) == 4)
    }

    @Test("Every block of a zero grid sums to zero")
    func zeros() {
        // A 3 × 4 grid has (3 · 4 / 2) × (4 · 5 / 2) = 6 × 10 = 60 rectangles
        let grid = Array(repeating: Array(repeating: 0, count: 4), count: 3)
        #expect(TargetSumSubmatrices.count(in: grid, summingTo: 0) == 60)
        #expect(TargetSumSubmatrices.count(in: grid, summingTo: 1) == 0)
    }

    @Test("Matches trying every rectangle on many small grids")
    func matchesBruteForce() {
        var firstMismatch: [[Int]]? = nil
        for seed in 0..<80 {
            let rows = seed % 4 + 1
            let columns = (seed / 4) % 5 + 1
            let grid = (0..<rows).map { r in (0..<columns).map { c in (r * 5 + c * 3 + seed) % 5 - 2 } }
            let target = seed % 3 - 1
            if TargetSumSubmatrices.count(in: grid, summingTo: target) != Self.slowCount(grid, target) {
                firstMismatch = firstMismatch ?? grid
            }
        }
        #expect(firstMismatch == nil, "the first grid where the answer differs from the brute force")
    }

    @Test("Stays fast on a 100 × 100 grid")
    func large() {
        let zeros = Array(repeating: Array(repeating: 0, count: 100), count: 100)
        #expect(TargetSumSubmatrices.count(in: zeros, summingTo: 0) == 5_050 * 5_050)

        // Ones: a block sums to 6 exactly when its area is 6 (1 × 6, 2 × 3, 3 × 2 or 6 × 1)
        let ones = Array(repeating: Array(repeating: 1, count: 100), count: 100)
        let expected = 100 * 95 + 99 * 98 + 98 * 99 + 95 * 100
        #expect(TargetSumSubmatrices.count(in: ones, summingTo: 6) == expected)
    }
}
