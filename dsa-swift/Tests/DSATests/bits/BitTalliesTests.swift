import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BitTalliesTests {
    @Test("Small tables", arguments: [
        (0, [0]),
        (1, [0, 1]),
        (5, [0, 1, 1, 2, 1, 2]),
        (8, [0, 1, 1, 2, 1, 2, 2, 3, 1]),
        (15, [0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4]),
    ])
    func small(n: Int, expected: [Int]) {
        #expect(BitTallies.tallies(upTo: n) == expected)
    }

    @Test("Has one entry for every number from 0 to n", arguments: [0, 7, 64, 1_000])
    func length(n: Int) {
        #expect(BitTallies.tallies(upTo: n).count == n + 1)
    }

    @Test("Powers of two have one bit, and the number before has all ones")
    func powersOfTwo() {
        let counts = BitTallies.tallies(upTo: 1 << 16)
        guard counts.count == (1 << 16) + 1 else {
            Issue.record("expected \((1 << 16) + 1) counts, got \(counts.count)")
            return
        }
        for k in 1...16 {
            #expect(counts[1 << k] == 1)
            #expect(counts[(1 << k) - 1] == k)
        }
    }

    @Test("Matches nonzeroBitCount all the way to 100,000")
    func large() {
        let expected = (0...100_000).map(\.nonzeroBitCount)
        #expect(BitTallies.tallies(upTo: 100_000) == expected)
    }
}
