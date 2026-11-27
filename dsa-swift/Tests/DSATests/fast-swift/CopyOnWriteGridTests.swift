import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CopyOnWriteGridTests {
    typealias Grid = CopyOnWriteGrid.Grid
    typealias CopyCounter = CopyOnWriteGrid.CopyCounter

    /// Every cell, row by row
    private func cells(_ grid: Grid) -> [[Int]] {
        (0..<grid.rows).map { grid.row($0) }
    }

    @Test("Reading and writing cells")
    func readWrite() {
        var grid = Grid(rows: 2, columns: 3, repeating: 0, counter: CopyCounter())
        grid[0, 2] = 5
        grid[1, 0] = 7
        grid[1, 0] += 1
        #expect(grid[0, 2] == 5)
        #expect(grid[1, 0] == 8)
        #expect(grid[1, 1] == 0)
        #expect(cells(grid) == [[0, 0, 5], [8, 0, 0]])
    }

    @Test("A grid that isn't shared changes in place")
    func uniqueInPlace() {
        let counter = CopyCounter()
        var grid = Grid(rows: 3, columns: 3, repeating: 1, counter: counter)
        let id = grid.storageID
        grid[1, 1] = 9
        grid.add(2, toRow: 0)
        grid.swapRows(0, 2)
        grid.fill(4)
        #expect(grid.storageID == id, "a grid nobody shares must never get new storage")
        #expect(counter.copies == 0)
        #expect(cells(grid) == [[4, 4, 4], [4, 4, 4], [4, 4, 4]])
    }

    @Test("Copies share storage until one changes, and reading never copies")
    func copiesShare() {
        let counter = CopyCounter()
        let original = Grid(rows: 2, columns: 2, repeating: 3, counter: counter)
        let copy = original
        #expect(original.isSharingStorage(with: copy))
        #expect(copy[1, 1] == 3)
        #expect(copy.row(0) == [3, 3])
        #expect(original.isSharingStorage(with: copy), "reading must not copy")
        #expect(counter.copies == 0)
    }

    @Test("Separately created grids never share storage")
    func separateGrids() {
        let counter = CopyCounter()
        let first = Grid(rows: 1, columns: 1, repeating: 0, counter: counter)
        let second = Grid(rows: 1, columns: 1, repeating: 0, counter: counter)
        #expect(!first.isSharingStorage(with: second))
    }

    @Test("Writing a cell of a copy duplicates storage once")
    func writeCopy() {
        let counter = CopyCounter()
        let original = Grid(rows: 2, columns: 2, repeating: 0, counter: counter)
        var copy = original
        copy[0, 0] = 1
        #expect(counter.copies == 1)
        #expect(!original.isSharingStorage(with: copy))
        let id = copy.storageID
        copy[0, 1] = 2
        copy[1, 1] += 3
        #expect(counter.copies == 1, "after the first write the copy owns its storage")
        #expect(copy.storageID == id)
        #expect(cells(original) == [[0, 0], [0, 0]])
        #expect(cells(copy) == [[1, 2], [0, 3]])
    }

    @Test("Changing the original leaves the copy alone, and only one of them copies")
    func changeOriginal() {
        let counter = CopyCounter()
        var original = Grid(rows: 1, columns: 3, repeating: 5, counter: counter)
        let copy = original
        original[0, 1] = 6
        original[0, 2] = 7
        #expect(counter.copies == 1)
        #expect(copy.row(0) == [5, 5, 5])
        #expect(original.row(0) == [5, 6, 7])
    }

    @Test("Adding to a row of a copy")
    func addToRow() {
        let counter = CopyCounter()
        let original = Grid(rows: 2, columns: 3, repeating: 1, counter: counter)
        var copy = original
        copy.add(10, toRow: 1)
        #expect(counter.copies == 1)
        copy.add(5, toRow: 1)
        #expect(counter.copies == 1)
        #expect(cells(copy) == [[1, 1, 1], [16, 16, 16]])
        #expect(cells(original) == [[1, 1, 1], [1, 1, 1]])
    }

    @Test("Swapping rows of a copy")
    func swapRows() {
        let counter = CopyCounter()
        var original = Grid(rows: 3, columns: 2, repeating: 0, counter: counter)
        original[0, 0] = 1
        original[2, 1] = 9
        var copy = original
        copy.swapRows(1, 1)
        #expect(counter.copies == 0, "swapping a row with itself changes nothing")
        #expect(copy.isSharingStorage(with: original))
        copy.swapRows(0, 2)
        #expect(counter.copies == 1)
        #expect(cells(copy) == [[0, 9], [0, 0], [1, 0]])
        #expect(cells(original) == [[1, 0], [0, 0], [0, 9]])
    }

    @Test("Filling a shared grid builds new storage without duplicating the old cells")
    func fillShared() {
        let counter = CopyCounter()
        let original = Grid(rows: 2, columns: 2, repeating: 1, counter: counter)
        var copy = original
        copy.fill(8)
        #expect(counter.copies == 0, "fill overwrites every cell, so copying the old ones first is wasted work")
        #expect(!copy.isSharingStorage(with: original))
        #expect(cells(copy) == [[8, 8], [8, 8]])
        #expect(cells(original) == [[1, 1], [1, 1]])
        copy[0, 0] = 2
        #expect(counter.copies == 0, "after fill the copy owns its storage")
    }

    @Test("Three copies stay independent")
    func threeCopies() {
        let counter = CopyCounter()
        var a = Grid(rows: 1, columns: 2, repeating: 0, counter: counter)
        var b = a
        var c = a
        a[0, 0] = 1
        b[0, 1] = 2
        c.add(3, toRow: 0)
        #expect(a.row(0) == [1, 0])
        #expect(b.row(0) == [0, 2])
        #expect(c.row(0) == [3, 3])
        #expect(counter.copies == 2, "the last grid to change already owns the original storage")
    }

    @Test("Writing every cell of a copied 300 × 300 grid copies once")
    func largeWrites() {
        let counter = CopyCounter()
        let size = 300
        let original = Grid(rows: size, columns: size, repeating: 0, counter: counter)
        var copy = original
        for row in 0..<size {
            for column in 0..<size {
                copy[row, column] = row + column
            }
            if counter.copies > 1 {
                Issue.record("\(counter.copies) copies after \(row + 1) rows: each write is copying the whole grid")
                return
            }
        }
        #expect(counter.copies == 1)
        for row in stride(from: 0, to: size, by: 37) {
            #expect(original.row(row) == Array(repeating: 0, count: size))
            #expect(copy.row(row) == (0..<size).map { row + $0 })
        }
        // Many whole-row operations on the copy, which now owns its storage
        for round in 0..<2_000 {
            copy.add(1, toRow: round % size)
            copy.swapRows(round % size, (round * 7) % size)
        }
        #expect(counter.copies == 1)
        #expect(original.row(5) == Array(repeating: 0, count: size))
    }
}
