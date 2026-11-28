import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GridPathCountTests {
    @Test("Small grids", arguments: [
        (1, 1, 1),
        (1, 5, 1),
        (5, 1, 1),
        (2, 2, 2),
        (2, 3, 3),
        (3, 3, 6),
        (3, 7, 28),
        (5, 5, 70),
    ])
    func smallGrids(rows: Int, columns: Int, expected: Int) {
        #expect(GridPathCount.paths(rows: rows, columns: columns) == expected)
    }

    @Test("Swapping rows and columns gives the same count", arguments: [(2, 9), (4, 6), (7, 12)])
    func symmetric(rows: Int, columns: Int) {
        #expect(GridPathCount.paths(rows: rows, columns: columns) == GridPathCount.paths(rows: columns, columns: rows))
    }

    @Test("A 10 × 10 grid")
    func tenByTen() {
        #expect(GridPathCount.paths(rows: 10, columns: 10) == 48_620)
    }

    // Plain recursion would make hundreds of millions of calls here, or far more: memoise.
    @Test("Large grids finish quickly", .timeLimit(.minutes(1)), arguments: [
        (16, 16, 155_117_520),
        (20, 11, 20_030_010),
        (30, 30, 30_067_266_499_541_040),
    ])
    func largeGrids(rows: Int, columns: Int, expected: Int) {
        #expect(GridPathCount.paths(rows: rows, columns: columns) == expected)
    }
}
