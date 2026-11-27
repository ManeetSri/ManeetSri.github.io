import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GridSubscriptsTests {
    typealias Grid = GridSubscripts.Grid

    @Test("Starts with every cell set to the given value")
    func initialValues() {
        let grid = Grid(rows: 2, columns: 3, repeating: 7)
        #expect(grid.rows == 2)
        #expect(grid.columns == 3)
        #expect(grid.count == 6)
        #expect(Array(grid) == [7, 7, 7, 7, 7, 7])
        #expect(grid[1, 2] == 7)
    }

    @Test("Reads and writes cells by row and column")
    func readWrite() {
        var grid = Grid(rows: 3, columns: 4, repeating: 0)
        grid[1, 2] = 5
        grid[0, 0] = 1
        grid[2, 3] = 9
        #expect(grid[1, 2] == 5)
        #expect(grid[0, 0] == 1)
        #expect(grid[2, 3] == 9)
        #expect(grid[2, 1] == 0)
        grid[1, 2] += 10
        #expect(grid[1, 2] == 15)
    }

    @Test("Cells are stored row by row")
    func rowMajor() {
        var grid = Grid(rows: 2, columns: 3, repeating: 0)
        var value = 1
        for row in 0..<2 {
            for column in 0..<3 {
                grid[row, column] = value
                value += 1
            }
        }
        #expect(Array(grid) == [1, 2, 3, 4, 5, 6])
        #expect(grid[4] == 5)
        #expect(grid[grid.startIndex] == 1)
    }

    @Test("Extracts rows and columns")
    func rowsAndColumns() {
        var grid = Grid(rows: 3, columns: 2, repeating: 0)
        for row in 0..<3 {
            for column in 0..<2 {
                grid[row, column] = row * 10 + column
            }
        }
        #expect(grid.row(0) == [0, 1])
        #expect(grid.row(2) == [20, 21])
        #expect(grid.column(0) == [0, 10, 20])
        #expect(grid.column(1) == [1, 11, 21])
    }

    @Test("Gets Collection abilities for free")
    func collectionAbilities() {
        var grid = Grid(rows: 2, columns: 2, repeating: 3)
        grid[1, 0] = 8
        #expect(grid.max() == 8)
        #expect(grid.contains(8))
        #expect(!grid.contains(4))
        #expect(grid.reduce(0, +) == 17)
        #expect(grid.firstIndex(of: 8) == 2)
        #expect(grid.first == 3)
        var total = 0
        for cell in grid {
            total += cell
        }
        #expect(total == 17)
    }

    @Test("Thin and tiny grids")
    func shapes() {
        var single = Grid(rows: 1, columns: 1, repeating: 4)
        single[0, 0] = 2
        #expect(Array(single) == [2])
        let wide = Grid(rows: 1, columns: 5, repeating: 1)
        #expect(wide.row(0) == [1, 1, 1, 1, 1])
        #expect(wide.column(4) == [1])
        let tall = Grid(rows: 4, columns: 1, repeating: 6)
        #expect(tall.column(0) == [6, 6, 6, 6])
        #expect(tall.row(3) == [6])
    }

    @Test("A grid with no cells is empty")
    func empty() {
        let grid = Grid(rows: 0, columns: 5, repeating: 1)
        #expect(grid.isEmpty)
        #expect(grid.count == 0)
        #expect(Array(grid) == [])
    }

    @Test("Copies are independent")
    func valueSemantics() {
        let original = Grid(rows: 2, columns: 2, repeating: 0)
        var copy = original
        copy[0, 0] = 9
        #expect(original[0, 0] == 0)
        #expect(copy[0, 0] == 9)
    }

    @Test("Handles a 1,000 by 1,000 grid")
    func large() {
        var grid = Grid(rows: 1_000, columns: 1_000, repeating: 0)
        grid[999, 999] = 1
        grid[500, 250] = 2
        #expect(grid.count == 1_000_000)
        #expect(grid[999, 999] == 1)
        #expect(grid[500, 250] == 2)
        #expect(grid[500_250] == 2)
        #expect(grid.column(250).dropFirst(500).first == 2)
        #expect(grid.row(500).dropFirst(250).first == 2)
    }
}
