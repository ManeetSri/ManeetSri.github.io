import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SmallestSharedRangeTests {
    /// Tries every pair of values as the ends of a range. Fine for a few dozen values.
    private func bruteForce(_ lists: [[Int]]) -> [Int] {
        let values = Set(lists.flatMap { $0 }).sorted()
        var best: [Int] = []
        for low in values {
            for high in values where high >= low {
                let touchesAll = lists.allSatisfy { list in list.contains { $0 >= low && $0 <= high } }
                if touchesAll && (best.isEmpty || high - low < best[1] - best[0]) {
                    best = [low, high]
                }
            }
        }
        return best
    }

    @Test("Small cases", arguments: [
        ([[3, 10, 15, 24], [0, 9, 12, 20], [5, 18, 22, 30]], [20, 24]),
        ([[1, 2, 3], [1, 2, 3], [1, 2, 3]], [1, 1]),
        ([[1, 5], [3, 7]], [1, 3]),
        ([[4, 10]], [4, 4]),
        ([[1], [100]], [1, 100]),
        ([[1, 9], [5], [5, 20]], [1, 5]),
        ([[-8, -3, 4], [-6, 2, 9], [-7, 1, 3]], [-8, -6]),
    ])
    func small(lists: [[Int]], expected: [Int]) {
        #expect(SmallestSharedRange.range(lists) == expected)
    }

    @Test("Agrees with trying every range on hundreds of inputs")
    func matchesBruteForce() {
        var mismatches = 0
        for seed in 1...200 {
            let k = 1 + seed % 4
            let lists = (0..<k).map { i in
                (0..<(1 + (seed + i) % 5)).map { j in (j * 7_919 + i * 31 + seed * 104_729) % 40 - 10 }.sorted()
            }
            if SmallestSharedRange.range(lists) != bruteForce(lists) { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("1,000 lists of 100 values")
    func large() {
        let scattered = (0..<1_000).map { i in (0..<100).map { j in (i * 7_919 + j * 104_729) % 10_000_019 }.sorted() }
        #expect(SmallestSharedRange.range(scattered) == [432_486, 537_015])
        let crowded = (0..<1_000).map { i in (0..<100).map { j in (i * 31 + j * j * 7) % 1_000_003 }.sorted() }
        #expect(SmallestSharedRange.range(crowded) == [30_098, 30_988])
    }

    @Test("1,000 lists whose best range is at the start, or at the end")
    func largeKnown() {
        let atStart = (0..<1_000).map { i in [i, 5_000_000 + 2 * i, 9_000_000 + 3 * i] }
        #expect(SmallestSharedRange.range(atStart) == [0, 999])
        let atEnd = (0..<1_000).map { i in [3 * i, 5_000_000 + 2 * i, 9_000_000 + i] }
        #expect(SmallestSharedRange.range(atEnd) == [9_000_000, 9_000_999])
    }
}
