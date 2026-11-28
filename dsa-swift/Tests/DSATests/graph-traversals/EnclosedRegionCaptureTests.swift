import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct EnclosedRegionCaptureTests {
    private func board(_ rows: [String]) -> [[Character]] {
        rows.map { Array($0) }
    }

    @Test("Captures regions that don't touch the border", arguments: [
        (["XXXX", "XOOX", "XXOX", "XOXX"], ["XXXX", "XXXX", "XXXX", "XOXX"]),
        (["XXXXX", "XOOOX", "XOXOX", "XOOOX", "XXXXX"], ["XXXXX", "XXXXX", "XXXXX", "XXXXX", "XXXXX"]),
        (["XOXX", "XOXX", "XXXX", "XOOX", "XXXX"], ["XOXX", "XOXX", "XXXX", "XXXX", "XXXX"]),
        (["XXXX", "XOXX", "XXOX", "XXXO"], ["XXXX", "XXXX", "XXXX", "XXXO"]),
        (["XXXXX", "XOXOX", "XXOXX", "XOXOX", "XXXXX"], ["XXXXX", "XXXXX", "XXXXX", "XXXXX", "XXXXX"]),
    ])
    func captures(rows: [String], expected: [String]) {
        #expect(EnclosedRegionCapture.capture(board(rows)) == board(expected))
    }

    @Test("Regions joined to the border survive", arguments: [
        ["OOO", "OOO", "OOO"],
        ["XXXX", "XOOO", "XXXX"],
        ["XOX"],
        ["X", "O", "X"],
        ["XXXXX", "XOOOX", "XOXOX", "XOXOX", "XXXOX"],
        ["O"],
        ["X"],
    ])
    func survives(rows: [String]) {
        #expect(EnclosedRegionCapture.capture(board(rows)) == board(rows))
    }

    @Test("An empty board")
    func empty() {
        #expect(EnclosedRegionCapture.capture([]) == [])
    }

    @Test("A 1000 × 1000 board: one huge region, enclosed or not")
    func largeRegion() {
        let size = 1_000
        var enclosed = Array(repeating: Array(repeating: Character("O"), count: size), count: size)
        for i in 0..<size {
            enclosed[0][i] = "X"
            enclosed[size - 1][i] = "X"
            enclosed[i][0] = "X"
            enclosed[i][size - 1] = "X"
        }
        let allX = Array(repeating: Array(repeating: Character("X"), count: size), count: size)
        expectSameGrid(EnclosedRegionCapture.capture(enclosed), allX, "walled-in region")

        var open = enclosed
        open[0][500] = "O"                               // one gap in the wall
        expectSameGrid(EnclosedRegionCapture.capture(open), open, "region with a gap in the wall")
    }

    @Test("A snake of about 500,000 cells inside a wall")
    func largeSnake() {
        // A recursive search would go hundreds of thousands of calls deep: use an explicit stack or BFS
        let size = 1_000
        var snake = Array(repeating: Array(repeating: Character("X"), count: size), count: size)
        for row in stride(from: 1, to: size - 1, by: 2) {
            for column in 1..<(size - 1) {
                snake[row][column] = "O"
            }
        }
        for row in stride(from: 2, to: size - 1, by: 2) {
            snake[row][row % 4 == 2 ? size - 2 : 1] = "O"
        }
        let allX = Array(repeating: Array(repeating: Character("X"), count: size), count: size)
        expectSameGrid(EnclosedRegionCapture.capture(snake), allX, "walled-in snake")

        var escaping = snake
        escaping[0][1] = "O"                             // the snake's head reaches the border
        expectSameGrid(EnclosedRegionCapture.capture(escaping), escaping, "snake reaching the border")
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
