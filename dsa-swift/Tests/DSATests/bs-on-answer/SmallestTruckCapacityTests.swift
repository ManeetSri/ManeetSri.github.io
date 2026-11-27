import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SmallestTruckCapacityTests {
    /// A tiny deterministic generator, so the random-looking tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Days the loading rule takes at `capacity`, or nil if some parcel never fits.
    private func daysNeeded(_ parcels: [Int], capacity: Int) -> Int? {
        var days = 1
        var load = 0
        for weight in parcels {
            if weight > capacity { return nil }
            if load + weight > capacity {
                days += 1
                load = 0
            }
            load += weight
        }
        return days
    }

    /// Tries every capacity from 1 upwards: fine for small weights.
    private func bruteForce(_ parcels: [Int], _ days: Int) -> Int {
        var capacity = 1
        while (daysNeeded(parcels, capacity: capacity) ?? Int.max) > days { capacity += 1 }
        return capacity
    }

    @Test("Finds the smallest capacity in the examples", arguments: [
        ([3, 8, 1, 5, 6, 2], 2, 13),
        ([3, 8, 1, 5, 6, 2], 3, 11),
        ([3, 8, 1, 5, 6, 2], 1, 25),
        ([3, 8, 1, 5, 6, 2], 6, 8),
        ([6, 2, 9, 3, 5, 4, 8], 3, 17),
        ([4], 1, 4),
    ])
    func examples(parcels: [Int], days: Int, expected: Int) {
        #expect(SmallestTruckCapacity.minimumCapacity(parcels: parcels, days: days) == expected)
    }

    @Test("More days than parcels still needs room for the heaviest one")
    func spareDays() {
        #expect(SmallestTruckCapacity.minimumCapacity(parcels: [2, 9, 4], days: 10) == 9)
        #expect(SmallestTruckCapacity.minimumCapacity(parcels: [5, 5, 5, 5], days: 4) == 5)
    }

    @Test("Order matters: the same weights in a different order")
    func orderMatters() {
        #expect(SmallestTruckCapacity.minimumCapacity(parcels: [1, 9, 1, 9], days: 2) == 10)
        #expect(SmallestTruckCapacity.minimumCapacity(parcels: [1, 1, 9, 9], days: 2) == 11)
        #expect(SmallestTruckCapacity.minimumCapacity(parcels: [9, 1, 1, 9], days: 2) == 10)
    }

    @Test("Matches trying every capacity on many small inputs")
    func matchesBruteForce() {
        var steps = Steps(seed: 7)
        var firstMismatch: String? = nil
        for _ in 0..<400 {
            let parcels = (0..<(steps.next(below: 8) + 1)).map { _ in steps.next(below: 20) + 1 }
            let days = steps.next(below: parcels.count + 2) + 1
            if SmallestTruckCapacity.minimumCapacity(parcels: parcels, days: days) != bruteForce(parcels, days) {
                firstMismatch = firstMismatch ?? "\(parcels) in \(days) days"
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from the brute force")
    }

    @Test("Handles 100,000 parcels of up to a billion each")
    func large() {
        var steps = Steps(seed: 4_242)
        let parcels = (0..<100_000).map { _ in steps.next(below: 1_000_000_000) + 1 }
        for days in [1, 7, 365, 50_000, 100_000] {
            let capacity = SmallestTruckCapacity.minimumCapacity(parcels: parcels, days: days)
            #expect(capacity >= 1)
            guard capacity >= 1 else { continue }
            #expect((daysNeeded(parcels, capacity: capacity) ?? Int.max) <= days, "capacity \(capacity) should be enough")
            #expect((daysNeeded(parcels, capacity: capacity - 1) ?? Int.max) > days, "capacity \(capacity - 1) should be too small")
        }
    }
}
