import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct IslandSurveyTests {
    private func map(_ rows: [String]) -> [[Character]] {
        rows.map { Array($0) }
    }

    @Test("Counts islands and measures the biggest", arguments: [
        (["11000", "11000", "00100", "00011"], 3, 4),
        (["11110", "11010", "11000", "00000"], 1, 9),
        (["101", "010", "101"], 5, 1),
        (["111", "101", "111"], 1, 8),
        (["10101"], 3, 1),
        (["1", "1", "0", "1"], 2, 2),
        (["0110", "0000", "1111", "0001"], 2, 5),
    ])
    func examples(rows: [String], islands: Int, biggest: Int) {
        #expect(IslandSurvey.count(map(rows)) == islands)
        #expect(IslandSurvey.largestArea(map(rows)) == biggest)
    }

    @Test("Tiny and empty maps", arguments: [
        ([String](), 0, 0),
        (["0"], 0, 0),
        (["1"], 1, 1),
        (["0000", "0000"], 0, 0),
    ])
    func edges(rows: [String], islands: Int, biggest: Int) {
        #expect(IslandSurvey.count(map(rows)) == islands)
        #expect(IslandSurvey.largestArea(map(rows)) == biggest)
    }

    @Test("A 1000 × 1000 map that is all land")
    func allLand() {
        let grid = Array(repeating: Array(repeating: Character("1"), count: 1_000), count: 1_000)
        #expect(IslandSurvey.count(grid) == 1)
        #expect(IslandSurvey.largestArea(grid) == 1_000_000)
    }

    @Test("A 1000 × 1000 checkerboard has 500,000 islands")
    func checkerboard() {
        let grid = (0..<1_000).map { row in (0..<1_000).map { column in Character((row + column) % 2 == 0 ? "1" : "0") } }
        #expect(IslandSurvey.count(grid) == 500_000)
        #expect(IslandSurvey.largestArea(grid) == 1)
    }

    @Test("Stripes: 500 islands of 1,000 cells")
    func stripes() {
        let grid = (0..<1_000).map { row in Array(repeating: Character(row % 2 == 0 ? "1" : "0"), count: 1_000) }
        #expect(IslandSurvey.count(grid) == 500)
        #expect(IslandSurvey.largestArea(grid) == 1_000)
    }

    @Test("A snake-shaped island of 500,500 cells")
    func snake() {
        // Full rows of land joined at alternate ends. A recursive DFS would go about 500,000 calls
        // deep, far past a test thread's stack: use an explicit stack or BFS.
        var grid = Array(repeating: Array(repeating: Character("0"), count: 1_000), count: 1_000)
        for row in stride(from: 0, to: 1_000, by: 2) {
            grid[row] = Array(repeating: "1", count: 1_000)
        }
        for row in stride(from: 1, to: 1_000, by: 2) {
            grid[row][row % 4 == 1 ? 999 : 0] = "1"
        }
        #expect(IslandSurvey.count(grid) == 1)
        #expect(IslandSurvey.largestArea(grid) == 500_500)
    }
}
