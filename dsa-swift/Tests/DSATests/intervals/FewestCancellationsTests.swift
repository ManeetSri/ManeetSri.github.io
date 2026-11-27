import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct IntervalRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct FewestCancellationsTests {
    /// Tries every subset of the bookings and keeps the largest one with no overlaps
    private func bruteForce(_ bookings: [[Int]]) -> Int {
        let n = bookings.count
        var mostKept = 0
        for mask in 0..<(1 << n) {
            let chosen = (0..<n).filter { mask & (1 << $0) != 0 }.map { bookings[$0] }
            var clash = false
            for i in chosen.indices {
                for j in chosen.indices where j > i {
                    if chosen[i][0] < chosen[j][1] && chosen[j][0] < chosen[i][1] {
                        clash = true
                    }
                }
            }
            if !clash {
                mostKept = max(mostKept, chosen.count)
            }
        }
        return n - mostKept
    }

    @Test("Cancels as few bookings as possible", arguments: [
        ([[0, 4], [3, 6], [5, 9], [8, 12]], 2),
        ([[1, 2], [2, 3], [3, 4]], 0),
        ([[1, 10], [2, 3], [4, 5], [6, 7]], 1),
        ([[5, 8], [5, 8], [5, 8]], 2),
        ([[1, 3], [2, 4], [3, 5], [1, 8], [6, 7], [5, 9]], 3),
        ([[1, 5], [4, 7], [6, 10]], 1),
        ([[-3, 0], [-1, 2], [0, 3]], 1),
    ] as [([[Int]], Int)])
    func examples(bookings: [[Int]], expected: Int) {
        #expect(FewestCancellations.minimumCancellations(bookings) == expected)
    }

    @Test("No bookings, or just one, need no cancellations")
    func tiny() {
        #expect(FewestCancellations.minimumCancellations([]) == 0)
        #expect(FewestCancellations.minimumCancellations([[4, 9]]) == 0)
    }

    @Test("Touching bookings never clash")
    func touching() {
        let chain = (0..<100).map { [$0 * 3, $0 * 3 + 3] }.reversed()
        #expect(FewestCancellations.minimumCancellations(Array(chain)) == 0)
    }

    @Test("Matches trying every subset on many small inputs")
    func matchesBruteForce() {
        var random = IntervalRandom(seed: 5)
        var firstMismatch: String? = nil
        for _ in 0..<400 {
            let count = Int.random(in: 0...8, using: &random)
            let bookings = (0..<count).map { _ -> [Int] in
                let start = Int.random(in: 0...15, using: &random)
                return [start, start + Int.random(in: 1...6, using: &random)]
            }
            if FewestCancellations.minimumCancellations(bookings) != bruteForce(bookings) {
                firstMismatch = firstMismatch ?? "\(bookings)"
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from the brute force")
    }

    @Test("Handles 100,000 bookings in O(n log n)")
    func large() {
        let n = 100_000
        var random = IntervalRandom(seed: 99)
        // Booking k overlaps bookings k - 1 and k + 1 only, so every other booking can stay
        let staggered = (0..<n).map { [2 * $0, 2 * $0 + 3] }.shuffled(using: &random)
        #expect(FewestCancellations.minimumCancellations(staggered) == n / 2)
        // Nested bookings all overlap in the middle, so only one can stay
        let nested = (0..<n).map { [$0, 2 * n - $0] }.shuffled(using: &random)
        #expect(FewestCancellations.minimumCancellations(nested) == n - 1)
    }
}
