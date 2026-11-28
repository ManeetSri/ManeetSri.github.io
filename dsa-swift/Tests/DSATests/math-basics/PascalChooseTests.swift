import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PascalChooseTests {
    @Test("The first rows", arguments: [
        (0, [1]),
        (1, [1, 1]),
        (2, [1, 2, 1]),
        (5, [1, 5, 10, 10, 5, 1]),
        (6, [1, 6, 15, 20, 15, 6, 1]),
    ])
    func rows(n: Int, expected: [Int]) {
        #expect(PascalChoose.row(n) == expected)
    }

    @Test("Row 1000 has 1001 entries and is symmetric")
    func row1000() throws {
        let row = PascalChoose.row(1000)
        try #require(row.count == 1001)
        #expect(row == row.reversed())
        #expect(Array(row.prefix(4)) == [1, 1000, 499_500, 166_167_000])
        #expect(row[500] == 159_835_829)
        #expect(row.allSatisfy { (0..<1_000_000_007).contains($0) })
    }

    @Test("A row sums to 2ⁿ modulo the prime")
    func rowSum() {
        let mod = 1_000_000_007
        let total = PascalChoose.row(1000).reduce(0) { ($0 + $1) % mod }
        var twoToTheN = 1
        for _ in 0..<1000 {
            twoToTheN = twoToTheN * 2 % mod
        }
        #expect(total == twoToTheN)
    }

    @Test("Choose", arguments: [
        (5, 2, 10),
        (52, 5, 2_598_960),
        (10, 0, 1),
        (10, 10, 1),
        (10, 1, 10),
        (30, 15, 155_117_520),
        (66, 33, 480_267_059),
        (100, 50, 538_992_043),
        (1000, 500, 159_835_829),
        (1000, 999, 1000),
        (0, 0, 1),
    ])
    func choose(n: Int, k: Int, expected: Int) {
        #expect(PascalChoose.choose(n, k) == expected)
    }

    @Test("Impossible choices give 0", arguments: [
        (4, 7),
        (4, -1),
        (0, 1),
        (1000, 1001),
        (5, Int.min),
        (5, Int.max),
    ])
    func impossible(n: Int, k: Int) {
        #expect(PascalChoose.choose(n, k) == 0)
    }
}
