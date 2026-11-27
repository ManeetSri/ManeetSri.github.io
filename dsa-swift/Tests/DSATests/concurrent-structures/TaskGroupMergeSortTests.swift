import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct MergeSortRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TaskGroupMergeSortTests {
    @Test("merge", arguments: [
        ([1, 4, 9], [2, 3, 10, 11], [1, 2, 3, 4, 9, 10, 11]),
        ([], [5, 6], [5, 6]),
        ([5, 6], [], [5, 6]),
        ([], [], []),
        ([2, 2, 2], [2, 2], [2, 2, 2, 2, 2]),
        ([-3, 0], [-5, -4, 8], [-5, -4, -3, 0, 8]),
    ] as [([Int], [Int], [Int])])
    func merges(first: [Int], second: [Int], expected: [Int]) {
        #expect(TaskGroupMergeSort.merge(first, second) == expected)
    }

    @Test("Small arrays with every threshold", arguments: [1, 2, 3, 100])
    func small(threshold: Int) async {
        let cases: [[Int]] = [[], [7], [2, 1], [5, 3, 8, 1, 9, 2], [4, 4, 4, 1, 1], [-2, 10, -30, 0, 7], Array((1...9).reversed())]
        for items in cases {
            #expect(await TaskGroupMergeSort.sorted(items, threshold: threshold) == items.sorted())
        }
    }

    @Test("Random arrays equal sorted()", arguments: [1, 7, 64, 5_000])
    func random(threshold: Int) async {
        var random = MergeSortRandom(seed: UInt64(threshold))
        for size in [10, 99, 1_000, 4_321] {
            let items = (0..<size).map { _ in Int.random(in: -500...500, using: &random) }
            #expect(await TaskGroupMergeSort.sorted(items, threshold: threshold) == items.sorted())
        }
    }

    @Test("200,000 elements, including already sorted and reversed input")
    func large() async {
        var random = MergeSortRandom(seed: 2_026)
        let items = (0..<200_000).map { _ in Int.random(in: Int.min...Int.max, using: &random) }
        #expect(await TaskGroupMergeSort.sorted(items, threshold: 4_096) == items.sorted())
        let ascending = Array(0..<50_000)
        #expect(await TaskGroupMergeSort.sorted(ascending, threshold: 1_000) == ascending)
        #expect(await TaskGroupMergeSort.sorted(ascending.reversed(), threshold: 1_000) == ascending)
    }
}
