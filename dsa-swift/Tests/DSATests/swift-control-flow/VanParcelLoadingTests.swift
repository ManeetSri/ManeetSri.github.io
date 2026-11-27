import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct VanParcelLoadingTests {
    @Test("Loads parcels until one doesn't fit", arguments: [
        ([5, 0, 8, 4, 2], 15, 2),
        ([5, 0, 8, 4, 3], 15, 2),
        ([4, -2, 6, 5], 15, 3),
        ([1, 2, 3, 4], 100, 4),
        ([3, 3, 3, 3], 10, 3),
    ])
    func loads(weights: [Int], capacity: Int, expected: Int) {
        #expect(VanParcelLoading.loadedCount(weights, capacity: capacity) == expected)
    }

    @Test("Stops at the first misfit even if later parcels would fit")
    func stopsAtFirstMisfit() {
        #expect(VanParcelLoading.loadedCount([20, 1, 1], capacity: 15) == 0)
        #expect(VanParcelLoading.loadedCount([6, 6, 9, 1, 1, 1], capacity: 14) == 2)
    }

    @Test("Skipping a misread parcel never stops loading")
    func skipsMisreads() {
        #expect(VanParcelLoading.loadedCount([0, -1, -1_000, 4], capacity: 10) == 1)
        #expect(VanParcelLoading.loadedCount([2, 0, 2, -5, 2], capacity: 6) == 3)
        #expect(VanParcelLoading.loadedCount([0, -1], capacity: 15) == 0)
    }

    @Test("A load exactly at capacity fits")
    func exactFill() {
        #expect(VanParcelLoading.loadedCount([10, 5], capacity: 15) == 2)
        #expect(VanParcelLoading.loadedCount([15], capacity: 15) == 1)
        #expect(VanParcelLoading.loadedCount([16], capacity: 15) == 0)
    }

    @Test("Empty conveyor or zero capacity loads nothing")
    func nothingToLoad() {
        #expect(VanParcelLoading.loadedCount([], capacity: 15) == 0)
        #expect(VanParcelLoading.loadedCount([1, 2, 3], capacity: 0) == 0)
        #expect(VanParcelLoading.loadedCount([0, 0], capacity: 0) == 0)
    }

    @Test("Handles a long conveyor")
    func longConveyor() {
        let heavy = Array(repeating: 1_000_000, count: 10_000)
        #expect(VanParcelLoading.loadedCount(heavy, capacity: 1_000_000_000) == 1_000)
        let light = Array(repeating: 100_000, count: 10_000)
        #expect(VanParcelLoading.loadedCount(light, capacity: 1_000_000_000) == 10_000)
    }
}
