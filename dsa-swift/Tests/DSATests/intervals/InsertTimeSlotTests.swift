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

@Suite struct InsertTimeSlotTests {
    /// A correct insert gives the same answer as appending the new slot, sorting and merging again
    private func appendAndMerge(_ newSlot: [Int], _ slots: [[Int]]) -> [[Int]] {
        var merged: [[Int]] = []
        for slot in (slots + [newSlot]).sorted(by: { $0[0] < $1[0] }) {
            if let last = merged.last, slot[0] <= last[1] {
                merged[merged.count - 1][1] = max(last[1], slot[1])
            } else {
                merged.append(slot)
            }
        }
        return merged
    }

    @Test("Inserts and merges", arguments: [
        ([4, 8], [[1, 2], [3, 5], [6, 7], [8, 10], [12, 16]], [[1, 2], [3, 10], [12, 16]]),
        ([0, 0], [[1, 2], [3, 5]], [[0, 0], [1, 2], [3, 5]]),
        ([17, 19], [[1, 2], [12, 16]], [[1, 2], [12, 16], [17, 19]]),
        ([0, 20], [[1, 2], [3, 5], [6, 7]], [[0, 20]]),
        ([5, 6], [[1, 2], [3, 5], [6, 7]], [[1, 2], [3, 7]]),
        ([3, 4], [[1, 2], [5, 6]], [[1, 2], [3, 4], [5, 6]]),
        ([2, 3], [[1, 5]], [[1, 5]]),
        ([-4, -1], [[-10, -8], [-1, 0]], [[-10, -8], [-4, 0]]),
    ] as [([Int], [[Int]], [[Int]])])
    func examples(newSlot: [Int], slots: [[Int]], expected: [[Int]]) {
        #expect(InsertTimeSlot.insert(newSlot, into: slots) == expected)
    }

    @Test("Inserting into an empty list gives just the new slot")
    func empty() {
        #expect(InsertTimeSlot.insert([4, 6], into: []) == [[4, 6]])
    }

    @Test("Touching at either end joins the slots")
    func touching() {
        #expect(InsertTimeSlot.insert([3, 5], into: [[1, 3]]) == [[1, 5]])
        #expect(InsertTimeSlot.insert([2, 5], into: [[5, 8]]) == [[2, 8]])
        #expect(InsertTimeSlot.insert([4, 4], into: [[1, 4], [6, 9]]) == [[1, 4], [6, 9]])
    }

    @Test("Matches append-and-merge on many small lists")
    func matchesAppendAndMerge() {
        var random = IntervalRandom(seed: 81)
        var firstMismatch: String? = nil
        for _ in 0..<600 {
            // A sorted list in which each slot starts at least 1 after the previous one ends
            var slots: [[Int]] = []
            var cursor = Int.random(in: -5...5, using: &random)
            for _ in 0..<Int.random(in: 0...7, using: &random) {
                let length = Int.random(in: 0...4, using: &random)
                slots.append([cursor, cursor + length])
                cursor += length + Int.random(in: 1...4, using: &random)
            }
            let start = Int.random(in: -8...(cursor + 3), using: &random)
            let newSlot = [start, start + Int.random(in: 0...8, using: &random)]
            if InsertTimeSlot.insert(newSlot, into: slots) != appendAndMerge(newSlot, slots) {
                firstMismatch = firstMismatch ?? "\(newSlot) into \(slots)"
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from append-and-merge")
    }

    @Test("Inserts into 200,000 slots in one pass")
    func large() {
        let n = 200_000
        let slots = (0..<n).map { [3 * $0, 3 * $0 + 1] }

        // Absorbs slots 50,000 through 150,000; the last of them, [450,000, 450,001], stretches the end
        let result = InsertTimeSlot.insert([150_001, 450_000], into: slots)
        #expect(result.count == 100_000)
        #expect(result.first == [0, 1])
        #expect(result.count > 50_001 && result[49_999] == [149_997, 149_998])
        #expect(result.count > 50_001 && result[50_000] == [150_000, 450_001])
        #expect(result.count > 50_001 && result[50_001] == [450_003, 450_004])
        #expect(result.last == [599_997, 599_998])

        let atFront = InsertTimeSlot.insert([-5, -2], into: slots)
        #expect(atFront.count == n + 1 && atFront.first == [-5, -2] && atFront.last == [599_997, 599_998])
        let atBack = InsertTimeSlot.insert([700_000, 700_001], into: slots)
        #expect(atBack.count == n + 1 && atBack.first == [0, 1] && atBack.last == [700_000, 700_001])
    }
}
