import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RotateSquareGridTests {
    static let rotationCases: [([[Int]], [[Int]])] = [
        ([[1, 2], [3, 4]], [[3, 1], [4, 2]]),
        ([[1, 2, 3], [4, 5, 6], [7, 8, 9]], [[7, 4, 1], [8, 5, 2], [9, 6, 3]]),
        ([[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16]],
         [[13, 9, 5, 1], [14, 10, 6, 2], [15, 11, 7, 3], [16, 12, 8, 4]]),
        ([[0, -1], [-2, 0]], [[-2, 0], [0, -1]]),
    ]

    private func rotated(_ grid: [[Int]]) -> [[Int]] {
        var copy = grid
        RotateSquareGrid.rotateClockwise(&copy)
        return copy
    }

    // Builds the rotation the slow, obvious way: new[c][n - 1 - r] = old[r][c]
    private func expectedRotation(_ grid: [[Int]]) -> [[Int]] {
        let size = grid.count
        var result = grid
        for row in 0..<size {
            for column in 0..<size {
                result[column][size - 1 - row] = grid[row][column]
            }
        }
        return result
    }

    @Test("Rotates a quarter turn clockwise", arguments: Self.rotationCases)
    func rotates(grid: [[Int]], expected: [[Int]]) {
        #expect(rotated(grid) == expected)
    }

    @Test("Tiny grids", arguments: [[[Int]](), [[42]]])
    func tiny(grid: [[Int]]) {
        #expect(rotated(grid) == grid)
    }

    @Test("Four turns bring the grid back")
    func fourTurns() {
        let original = (0..<5).map { row in (0..<5).map { row * 5 + $0 } }
        var grid = original
        for _ in 0..<4 {
            RotateSquareGrid.rotateClockwise(&grid)
        }
        #expect(grid == original)
        RotateSquareGrid.rotateClockwise(&grid)
        #expect(grid != original)
    }

    @Test("Matches the obvious rotation for sizes 1 to 9")
    func matchesObvious() {
        for size in 1...9 {
            let grid = (0..<size).map { row in (0..<size).map { row * 31 + $0 * 7 } }
            #expect(rotated(grid) == expectedRotation(grid), "size \(size)")
        }
    }

    @Test("Stays fast on a 400 × 400 grid")
    func large() {
        let size = 400
        let grid = (0..<size).map { row in (0..<size).map { row * size + $0 } }
        let result = rotated(grid)
        #expect(result.count == size)
        #expect(result[0][0] == (size - 1) * size)
        #expect(result[0][size - 1] == 0)
        #expect(result[size - 1][size - 1] == size - 1)
        #expect(result == expectedRotation(grid))
    }
}
