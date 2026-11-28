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

@Suite struct RoomsNeededTests {
    /// The busiest moment is always some meeting's start: count the meetings running at each start
    private func bruteForce(_ meetings: [[Int]]) -> Int {
        meetings.map { meeting in
            meetings.filter { $0[0] <= meeting[0] && meeting[0] < $0[1] }.count
        }.max() ?? 0
    }

    @Test("Finds the fewest rooms", arguments: [
        ([[9, 12], [10, 11], [11, 13], [12, 14]], 2),
        ([[0, 5], [1, 6], [2, 7]], 3),
        ([[1, 3], [3, 5], [5, 7]], 1),
        ([[4, 9]], 1),
        ([[0, 30], [5, 10], [15, 20], [10, 15], [25, 35], [8, 12]], 3),
        ([[1, 10], [2, 3], [4, 5], [6, 7]], 2),
        ([[3, 4], [3, 4], [3, 4]], 3),
        ([[-10, -5], [-6, 0], [0, 5]], 2),
    ] as [([[Int]], Int)])
    func examples(meetings: [[Int]], expected: Int) {
        #expect(RoomsNeeded.minimumRooms(meetings) == expected)
    }

    @Test("No meetings need no rooms")
    func empty() {
        #expect(RoomsNeeded.minimumRooms([]) == 0)
    }

    @Test("A meeting ending as another starts frees its room")
    func endBeforeStart() {
        #expect(RoomsNeeded.minimumRooms([[5, 10], [1, 5]]) == 1)
        #expect(RoomsNeeded.minimumRooms([[1, 5], [5, 10], [1, 5], [5, 10]]) == 2)
    }

    @Test("Matches counting at every start on many small inputs")
    func matchesBruteForce() {
        var random = IntervalRandom(seed: 12)
        var firstMismatch: String? = nil
        for _ in 0..<500 {
            let count = Int.random(in: 0...10, using: &random)
            let meetings = (0..<count).map { _ -> [Int] in
                let start = Int.random(in: 0...20, using: &random)
                return [start, start + Int.random(in: 1...8, using: &random)]
            }
            if RoomsNeeded.minimumRooms(meetings) != bruteForce(meetings) {
                firstMismatch = firstMismatch ?? "\(meetings)"
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from the brute force")
    }

    @Test("Handles 100,000 meetings in O(n log n)")
    func large() {
        let n = 100_000
        var random = IntervalRandom(seed: 61)
        // Meeting k runs from k to k + 100, so at any moment after 99 exactly 100 are running
        let sliding = (0..<n).map { [$0, $0 + 100] }.shuffled(using: &random)
        #expect(RoomsNeeded.minimumRooms(sliding) == 100)
        // Back-to-back meetings all fit in one room
        let chain = (0..<n).map { [$0, $0 + 1] }.shuffled(using: &random)
        #expect(RoomsNeeded.minimumRooms(chain) == 1)
        // Everyone at once
        let together = Array(repeating: [0, 10], count: n)
        #expect(RoomsNeeded.minimumRooms(together) == n)
    }
}
