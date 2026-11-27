import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SeatBookingRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TrainSeatBookingsTests {
    /// Checks every stretch of every request. Slow, but clearly right.
    private func reference(_ seats: [Int], _ requests: [[Int]]) -> [Bool] {
        var free = seats
        return requests.map { request in
            let stretches = request[0]..<request[1]
            guard stretches.allSatisfy({ free[$0] >= request[2] }) else { return false }
            for stretch in stretches { free[stretch] -= request[2] }
            return true
        }
    }

    @Test("The example from the statement")
    func example() {
        let seats = [3, 5, 2, 4]
        let requests = [[0, 2, 3], [1, 4, 2], [1, 3, 1], [3, 4, 4], [3, 4, 2]]
        #expect(TrainSeatBookings.process(seats: seats, requests: requests) == [true, true, false, false, true])
    }

    @Test("Small cases", arguments: [
        ([1], [[0, 1, 1], [0, 1, 1]], [true, false]),
        ([0, 10], [[0, 2, 1], [1, 2, 10], [1, 2, 1]], [false, true, false]),
        ([4, 4, 4], [[0, 3, 4], [0, 1, 1]], [true, false]),
        ([5, 5, 5], [[0, 1, 2], [2, 3, 2], [0, 3, 3], [1, 2, 1]], [true, true, true, true]),
        ([2, 9, 9, 2], [[1, 3, 9], [0, 4, 1], [3, 4, 2]], [true, false, true]),
        ([7, 7], [], []),
    ] as [([Int], [[Int]], [Bool])])
    func small(seats: [Int], requests: [[Int]], expected: [Bool]) {
        #expect(TrainSeatBookings.process(seats: seats, requests: requests) == expected)
    }

    @Test("Large seat counts and groups")
    func largeNumbers() {
        let billion = 1_000_000_000
        let seats = Array(repeating: billion, count: 6)
        let requests = [[0, 6, billion - 1], [2, 4, 1], [3, 5, 1], [0, 1, 2], [5, 6, 1]]
        #expect(TrainSeatBookings.process(seats: seats, requests: requests) == [true, true, false, false, true])
    }

    @Test("Matches checking every stretch on 400 small random trains")
    func randomSmall() {
        var random = SeatBookingRandom(seed: 62)
        for _ in 0..<400 {
            let count = Int.random(in: 1...10, using: &random)
            let seats = (0..<count).map { _ in Int.random(in: 0...12, using: &random) }
            let requests = (0..<Int.random(in: 0...25, using: &random)).map { _ -> [Int] in
                let from = Int.random(in: 0..<count, using: &random)
                let to = Int.random(in: (from + 1)...count, using: &random)
                return [from, to, Int.random(in: 1...6, using: &random)]
            }
            #expect(TrainSeatBookings.process(seats: seats, requests: requests) == reference(seats, requests))
        }
    }

    @Test("100,000 stretches and 100,000 long requests")
    func large() {
        // Checking every stretch of every request would be about 3 × 10⁹ steps. The reference keeps the
        // free seats in DSAKit's LazySegmentTree.
        var random = SeatBookingRandom(seed: 2_028)
        let count = 100_000
        let seats = (0..<count).map { _ in Int.random(in: 50_000...60_000, using: &random) }
        var requests: [[Int]] = []
        for _ in 0..<100_000 {
            let a = Int.random(in: 0..<count, using: &random), b = Int.random(in: 0..<count, using: &random)
            requests.append([min(a, b), max(a, b) + 1, Int.random(in: 1...3, using: &random)])
        }
        var free = LazySegmentTree(seats)
        let expected = requests.map { request -> Bool in
            let stretches = request[0]..<request[1]
            guard free.minimum(in: stretches) >= request[2] else { return false }
            free.add(-request[2], to: stretches)
            return true
        }
        let accepted = expected.filter { $0 }.count
        #expect(accepted > 1_000 && accepted < 100_000)        // the test really mixes both outcomes
        #expect(TrainSeatBookings.process(seats: seats, requests: requests) == expected)
    }
}
