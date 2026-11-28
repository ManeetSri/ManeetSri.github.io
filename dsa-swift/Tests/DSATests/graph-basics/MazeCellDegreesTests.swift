import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MazeCellDegreesTests {
    @Test("Small mazes", arguments: [
        ([".#.", "...", ".#."], [0, 4, 1, 2, 0]),                 // an H: four dead ends, two junctions
        ([".#.", "###", ".#."], [4, 0, 0, 0, 0]),                 // four cut-off cells
        (["#.#", "...", "#.#"], [0, 4, 0, 0, 1]),                 // a plus: the centre has 4
        (["...", "...", "..."], [0, 0, 4, 4, 1]),
        (["..", ".."], [0, 0, 4, 0, 0]),
        (["....."], [0, 2, 3, 0, 0]),
        (["#.##", "#..#", "##.#", "#..."], [0, 3, 3, 1, 0]),
        (["..#..", ".#...", "....#"], [0, 1, 9, 1, 1]),
    ])
    func small(maze: [String], expected: [Int]) {
        #expect(MazeCellDegrees.count(maze) == expected)
    }

    @Test("Mazes with no open cells")
    func nothingOpen() {
        #expect(MazeCellDegrees.count([]) == [0, 0, 0, 0, 0])
        #expect(MazeCellDegrees.count(["###", "###"]) == [0, 0, 0, 0, 0])
        #expect(MazeCellDegrees.count(["."]) == [1, 0, 0, 0, 0])
        #expect(MazeCellDegrees.count(["#"]) == [0, 0, 0, 0, 0])
    }

    @Test("Edges of the maze are not open cells")
    func borders() {
        // A cell on the border has fewer than four candidate neighbours: none wrap around
        #expect(MazeCellDegrees.count([".##.", "####", ".##."]) == [4, 0, 0, 0, 0])
        #expect(MazeCellDegrees.count([".", ".", "."]) == [0, 2, 1, 0, 0])
    }

    @Test("A 500 × 400 open field")
    func openField() {
        let rows = 500
        let columns = 400
        let maze = Array(repeating: String(repeating: ".", count: columns), count: rows)
        let edges = 2 * (rows - 2) + 2 * (columns - 2)
        #expect(MazeCellDegrees.count(maze) == [0, 0, 4, edges, (rows - 2) * (columns - 2)])
    }

    @Test("A corridor 100,000 cells long, both ways round")
    func corridors() {
        let wide = [String(repeating: ".", count: 100_000)]
        #expect(MazeCellDegrees.count(wide) == [0, 2, 99_998, 0, 0])
        let tall = Array(repeating: ".", count: 100_000)
        #expect(MazeCellDegrees.count(tall) == [0, 2, 99_998, 0, 0])
    }

    @Test("A 300 × 300 grid of pillars")
    func pillars() {
        // Walls at every (odd row, odd column): the open cells form a lattice of corridors
        let size = 300
        let maze = (0..<size).map { row in
            String((0..<size).map { column in row % 2 == 1 && column % 2 == 1 ? "#" : "." })
        }
        // Brute-force count with the same rules, written differently
        var expected = [0, 0, 0, 0, 0]
        let isOpen = { (r: Int, c: Int) -> Bool in
            r >= 0 && r < size && c >= 0 && c < size && !(r % 2 == 1 && c % 2 == 1)
        }
        for r in 0..<size {
            for c in 0..<size where isOpen(r, c) {
                let degree = [isOpen(r - 1, c), isOpen(r + 1, c), isOpen(r, c - 1), isOpen(r, c + 1)].filter { $0 }.count
                expected[degree] += 1
            }
        }
        #expect(MazeCellDegrees.count(maze) == expected)
    }
}
