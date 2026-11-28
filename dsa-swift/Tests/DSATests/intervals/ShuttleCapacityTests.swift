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

@Suite struct ShuttleCapacityTests {
    /// Adds up the riders on board just after each stop
    private func bruteForce(_ trips: [[Int]], _ capacity: Int) -> Bool {
        let lastStop = trips.map { $0[2] }.max() ?? 0
        for stop in 0...lastStop {
            let onBoard = trips.filter { $0[1] <= stop && stop < $0[2] }.reduce(0) { $0 + $1[0] }
            if onBoard > capacity {
                return false
            }
        }
        return true
    }

    @Test("Checks the load at every stop", arguments: [
        ([[2, 1, 5], [3, 3, 7]], 4, false),
        ([[2, 1, 5], [3, 3, 7]], 5, true),
        ([[2, 1, 5], [3, 5, 7]], 3, true),
        ([[4, 0, 2], [4, 2, 4], [4, 1, 3]], 8, true),
        ([[4, 0, 2], [4, 2, 4], [4, 1, 3]], 7, false),
        ([[5, 0, 1]], 4, false),
        ([[5, 0, 1]], 5, true),
        ([[3, 0, 4], [2, 2, 6], [4, 4, 8]], 5, false),
        ([[3, 0, 4], [2, 2, 6], [4, 4, 8]], 6, true),
    ] as [([[Int]], Int, Bool)])
    func examples(trips: [[Int]], capacity: Int, expected: Bool) {
        #expect(ShuttleCapacity.canCarryAll(trips, capacity: capacity) == expected)
    }

    @Test("No trips fit any shuttle, even one with no seats")
    func noTrips() {
        #expect(ShuttleCapacity.canCarryAll([], capacity: 0))
        #expect(ShuttleCapacity.canCarryAll([], capacity: 10))
    }

    @Test("Riders leave before new riders board at the same stop")
    func leaveFirst() {
        // Full at every stretch, but never over: everyone leaves where the next group boards
        #expect(ShuttleCapacity.canCarryAll([[6, 0, 3], [6, 3, 5], [6, 5, 9]], capacity: 6))
        #expect(!ShuttleCapacity.canCarryAll([[6, 0, 3], [6, 3, 5], [6, 4, 9]], capacity: 6))
    }

    @Test("Matches counting riders at every stop on many small inputs")
    func matchesBruteForce() {
        var random = IntervalRandom(seed: 3)
        var firstMismatch: String? = nil
        for _ in 0..<500 {
            let count = Int.random(in: 0...8, using: &random)
            let trips = (0..<count).map { _ -> [Int] in
                let pickUp = Int.random(in: 0...15, using: &random)
                return [Int.random(in: 1...5, using: &random), pickUp, pickUp + Int.random(in: 1...6, using: &random)]
            }
            let capacity = Int.random(in: 0...14, using: &random)
            if ShuttleCapacity.canCarryAll(trips, capacity: capacity) != bruteForce(trips, capacity) {
                firstMismatch = firstMismatch ?? "\(trips) with capacity \(capacity)"
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from the brute force")
    }

    @Test("Handles 100,000 trips over 100,000 stops")
    func large() {
        var random = IntervalRandom(seed: 17)
        // Trip k carries one rider from stop k to stop k + 50,000: all 50,000 are on board at stop 49,999
        let long = (0..<50_000).map { [1, $0, $0 + 50_000] }.shuffled(using: &random)
        #expect(ShuttleCapacity.canCarryAll(long, capacity: 50_000))
        #expect(!ShuttleCapacity.canCarryAll(long, capacity: 49_999))
        // 100,000 back-to-back groups of 100 riders: always full, never over
        let relay = (0..<100_000).map { [100, $0, $0 + 1] }.shuffled(using: &random)
        #expect(ShuttleCapacity.canCarryAll(relay, capacity: 100))
        #expect(!ShuttleCapacity.canCarryAll(relay, capacity: 99))
    }
}
