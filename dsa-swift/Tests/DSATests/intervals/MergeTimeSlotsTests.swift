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

@Suite struct MergeTimeSlotsTests {
    /// Joins any two overlapping or touching slots until none are left, then sorts: slow, but clearly right
    private func bruteForce(_ slots: [[Int]]) -> [[Int]] {
        var pieces = slots
        var joined = true
        while joined {
            joined = false
            search: for i in pieces.indices {
                for j in pieces.indices where j > i {
                    if pieces[i][0] <= pieces[j][1] && pieces[j][0] <= pieces[i][1] {
                        pieces[i] = [min(pieces[i][0], pieces[j][0]), max(pieces[i][1], pieces[j][1])]
                        pieces.remove(at: j)
                        joined = true
                        break search
                    }
                }
            }
        }
        return pieces.sorted { $0[0] < $1[0] }
    }

    @Test("Merges overlapping and touching slots", arguments: [
        ([[9, 12], [1, 4], [3, 6], [12, 14], [20, 22]], [[1, 6], [9, 14], [20, 22]]),
        ([[5, 9], [6, 7]], [[5, 9]]),
        ([[1, 2], [3, 4]], [[1, 2], [3, 4]]),
        ([[4, 4], [4, 6]], [[4, 6]]),
        ([[8, 10], [1, 3], [2, 6], [15, 18], [6, 7], [17, 20]], [[1, 7], [8, 10], [15, 20]]),
        ([[1, 10], [2, 3], [4, 12]], [[1, 12]]),
        ([[-5, -2], [-3, 1], [2, 3]], [[-5, 1], [2, 3]]),
    ] as [([[Int]], [[Int]])])
    func examples(slots: [[Int]], expected: [[Int]]) {
        #expect(MergeTimeSlots.merge(slots) == expected)
    }

    @Test("Empty and single-slot lists")
    func tiny() {
        #expect(MergeTimeSlots.merge([]) == [])
        #expect(MergeTimeSlots.merge([[3, 7]]) == [[3, 7]])
        #expect(MergeTimeSlots.merge([[5, 5]]) == [[5, 5]])
    }

    @Test("Identical slots collapse into one")
    func duplicates() {
        #expect(MergeTimeSlots.merge([[2, 5], [2, 5], [2, 5]]) == [[2, 5]])
    }

    @Test("One long slot swallows the rest")
    func covering() {
        #expect(MergeTimeSlots.merge([[3, 4], [0, 100], [50, 60], [99, 101]]) == [[0, 101]])
    }

    @Test("A chain of touching slots joins end to end, in any order")
    func chain() {
        var random = IntervalRandom(seed: 7)
        let chain = (0..<50).map { [$0 * 2, $0 * 2 + 2] }.shuffled(using: &random)
        #expect(MergeTimeSlots.merge(chain) == [[0, 100]])
    }

    @Test("Matches a brute force on many small lists")
    func matchesBruteForce() {
        var random = IntervalRandom(seed: 33)
        var firstMismatch: String? = nil
        for _ in 0..<500 {
            let count = Int.random(in: 0...8, using: &random)
            let slots = (0..<count).map { _ -> [Int] in
                let start = Int.random(in: -10...20, using: &random)
                return [start, start + Int.random(in: 0...6, using: &random)]
            }
            if MergeTimeSlots.merge(slots) != bruteForce(slots) {
                firstMismatch = firstMismatch ?? "\(slots)"
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from the brute force")
    }

    @Test("Merges 190,000 slots in O(n log n)")
    func large() {
        // Groups of ten slots [2i, 2i + 1], joined inside each group by bridges [2i + 1, 2i + 2]. Group k
        // merges into [20k, 20k + 19], and a gap separates it from group k + 1, which starts at 20k + 20.
        let groups = 10_000
        var slots: [[Int]] = []
        for i in 0..<(groups * 10) {
            slots.append([2 * i, 2 * i + 1])
            if i % 10 != 9 {
                slots.append([2 * i + 1, 2 * i + 2])
            }
        }
        var random = IntervalRandom(seed: 2024)
        slots.shuffle(using: &random)
        let expected = (0..<groups).map { [20 * $0, 20 * $0 + 19] }
        #expect(MergeTimeSlots.merge(slots) == expected)
    }
}
