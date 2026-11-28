import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct EqualXorTriplesTests {
    /// A tiny deterministic generator, so the random cases are the same every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Checks every triple directly: O(n³), for small arrays only.
    private func bruteForce(_ items: [Int]) -> Int {
        var total = 0
        for i in items.indices {
            for j in (i + 1)..<items.count {
                for k in j..<items.count {
                    let left = items[i..<j].reduce(0, ^)
                    let right = items[j...k].reduce(0, ^)
                    if left == right { total += 1 }
                }
            }
        }
        return total
    }

    @Test("Counts the triples", arguments: [
        ([6, 2, 4, 6], 4),
        ([1, 2, 3], 2),
        ([3, 3], 1),
        ([0, 0, 0], 4),
        ([5, 9, 12, 1, 1], 7),
        ([4], 0),
        ([7, 7, 7, 7], 6),
        ([1, 2, 4, 8], 0),
        ([0], 0),
        ([1_000_000_000, 1_000_000_000], 1),
    ])
    func examples(items: [Int], expected: Int) {
        #expect(EqualXorTriples.count(in: items) == expected)
    }

    @Test("Matches checking every triple on small random arrays")
    func matchesBruteForce() {
        var steps = Steps(seed: 20)
        var mismatches = 0
        for _ in 0..<300 {
            let length = 1 + steps.next(below: 12)
            let items = (0..<length).map { _ in steps.next(below: 4) }
            if EqualXorTriples.count(in: items) != bruteForce(items) { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("Stays O(n) on 100,000 items")
    func large() {
        // All zeros: every triple works, so the count is C(100,001, 3)
        #expect(EqualXorTriples.count(in: Array(repeating: 0, count: 100_000)) == 166_666_666_650_000)
        // One repeated value: the prefix XOR alternates, so only even-length stretches have XOR 0
        #expect(EqualXorTriples.count(in: Array(repeating: 6, count: 100_000)) == 83_333_333_350_000)
        #expect(EqualXorTriples.count(in: Array(repeating: 7, count: 99_999)) == 83_330_833_350_000)
    }
}
