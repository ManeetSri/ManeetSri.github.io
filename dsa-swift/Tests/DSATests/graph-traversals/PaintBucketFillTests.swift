import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PaintBucketFillTests {
    /// A size × size image of 0s with a one-pixel-wide path of 1s that zigzags across every other row
    private func snake(_ size: Int) -> [[Int]] {
        var image = Array(repeating: Array(repeating: 0, count: size), count: size)
        for row in stride(from: 0, to: size, by: 2) {
            for column in 0..<size {
                image[row][column] = 1
            }
        }
        for row in stride(from: 1, to: size, by: 2) {
            image[row][row % 4 == 1 ? size - 1 : 0] = 1
        }
        return image
    }

    @Test("Repaints the connected region")
    func examples() {
        #expect(PaintBucketFill.fill([[1, 1, 0], [1, 0, 1], [1, 1, 1]], row: 0, column: 0, with: 2)
            == [[2, 2, 0], [2, 0, 2], [2, 2, 2]])
        #expect(PaintBucketFill.fill([[1, 0, 0], [1, 1, 0], [0, 0, 1]], row: 0, column: 1, with: 4)
            == [[1, 4, 4], [1, 1, 4], [0, 0, 1]])
        #expect(PaintBucketFill.fill([[3, 3, 3, 8, 3]], row: 0, column: 4, with: 1) == [[3, 3, 3, 8, 1]])
        #expect(PaintBucketFill.fill([[2, 2], [2, 2], [5, 2]], row: 2, column: 0, with: 0) == [[2, 2], [2, 2], [0, 2]])
        #expect(PaintBucketFill.fill([[6], [6], [1], [6]], row: 1, column: 0, with: 2) == [[2], [2], [1], [6]])
    }

    @Test("Diagonal pixels aren't connected")
    func diagonals() {
        #expect(PaintBucketFill.fill([[0, 1], [1, 0]], row: 0, column: 0, with: 5) == [[5, 1], [1, 0]])
        #expect(PaintBucketFill.fill([[1, 0, 1], [0, 1, 0], [1, 0, 1]], row: 1, column: 1, with: 9)
            == [[1, 0, 1], [0, 9, 0], [1, 0, 1]])
    }

    @Test("A single pixel")
    func singlePixel() {
        #expect(PaintBucketFill.fill([[7]], row: 0, column: 0, with: 9) == [[9]])
    }

    @Test("Painting with the colour already there changes nothing")
    func sameColour() {
        #expect(PaintBucketFill.fill([[3, 3], [3, 3]], row: 1, column: 1, with: 3) == [[3, 3], [3, 3]])
        #expect(PaintBucketFill.fill([[1, 2], [2, 1]], row: 0, column: 1, with: 2) == [[1, 2], [2, 1]])
        let big = Array(repeating: Array(repeating: 4, count: 1_000), count: 1_000)
        expectSameGrid(PaintBucketFill.fill(big, row: 500, column: 500, with: 4), big, "1000 × 1000, same colour")
    }

    @Test("Fills a 1000 × 1000 image from the middle")
    func largeOpen() {
        let image = Array(repeating: Array(repeating: 0, count: 1_000), count: 1_000)
        let expected = Array(repeating: Array(repeating: 7, count: 1_000), count: 1_000)
        expectSameGrid(PaintBucketFill.fill(image, row: 500, column: 499, with: 7), expected, "1000 × 1000 open image")
    }

    @Test("Follows a snake of 500,500 pixels without running out of stack")
    func largeSnake() {
        // A recursive fill would go about 500,000 calls deep here, far past a test thread's stack
        let image = snake(1_000)
        let expected = image.map { row in row.map { $0 == 1 ? 2 : 0 } }
        expectSameGrid(PaintBucketFill.fill(image, row: 0, column: 0, with: 2), expected, "snake from (0, 0)")
        // Clicking a 0 pixel between two rows of the snake fills only that row's gap
        var pocket = image
        for column in 0..<999 {
            pocket[1][column] = 8
        }
        expectSameGrid(PaintBucketFill.fill(image, row: 1, column: 5, with: 8), pocket, "gap from (1, 5)")
    }
}

/// Compares two big grids and reports only the first difference, rather than printing a million
/// values when they don't match
private func expectSameGrid<T: Equatable>(_ actual: [[T]], _ expected: [[T]], _ what: String) {
    guard actual.count == expected.count else {
        Issue.record("\(what): expected \(expected.count) rows, got \(actual.count)")
        return
    }
    for row in expected.indices where actual[row] != expected[row] {
        guard actual[row].count == expected[row].count else {
            Issue.record("\(what): row \(row) should have \(expected[row].count) cells, not \(actual[row].count)")
            return
        }
        let column = expected[row].indices.first { actual[row][$0] != expected[row][$0] }!
        Issue.record("\(what): cell (\(row), \(column)) should be \(expected[row][column]), not \(actual[row][column])")
        return
    }
}
