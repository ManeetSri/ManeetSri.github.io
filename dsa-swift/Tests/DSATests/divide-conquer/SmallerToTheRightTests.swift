import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SmallerRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct SmallerToTheRightTests {
    /// Check every later position. Slow, but clearly right.
    private func bruteForce(_ numbers: [Int]) -> [Int] {
        numbers.indices.map { i in numbers[(i + 1)...].filter { $0 < numbers[i] }.count }
    }

    /// A different fast method: scan from the right, counting smaller values seen so far in a
    /// Fenwick tree indexed by each value's rank among the distinct values
    private func fenwickCounts(_ numbers: [Int]) -> [Int] {
        let distinct = Array(Set(numbers)).sorted()
        var tree = Array(repeating: 0, count: distinct.count + 1)
        var result = Array(repeating: 0, count: numbers.count)
        for index in stride(from: numbers.count - 1, through: 0, by: -1) {
            var low = 0
            var high = distinct.count
            while low < high {                  // rank = how many distinct values are smaller
                let mid = (low + high) / 2
                if distinct[mid] < numbers[index] { low = mid + 1 } else { high = mid }
            }
            var position = low
            var smaller = 0
            while position > 0 {
                smaller += tree[position]
                position -= position & -position
            }
            result[index] = smaller
            position = low + 1
            while position <= distinct.count {
                tree[position] += 1
                position += position & -position
            }
        }
        return result
    }

    @Test("Examples and small cases", arguments: [
        ([6, 3, 8, 2], [2, 1, 1, 0]),
        ([1, 2, 3], [0, 0, 0]),
        ([3, 3, 1], [1, 1, 0]),
        ([], []),
        ([-1, -2, -1], [1, 0, 0]),
        ([42], [0]),
        ([4, 3, 2, 1], [3, 2, 1, 0]),
        ([2, 0, 1, 0, 2], [3, 0, 1, 0, 0]),
        ([5, 5, 5, 5], [0, 0, 0, 0]),
    ] as [([Int], [Int])])
    func examples(numbers: [Int], expected: [Int]) {
        #expect(SmallerToTheRight.counts(numbers) == expected)
    }

    @Test("Matches the brute force on 400 small random arrays")
    func randomSmall() {
        var random = SmallerRandom(seed: 315)
        for _ in 0..<400 {
            let numbers = (0..<Int.random(in: 0...30, using: &random)).map { _ in Int.random(in: -6...6, using: &random) }
            #expect(SmallerToTheRight.counts(numbers) == bruteForce(numbers))
        }
    }

    @Test("50,000 random values match a Fenwick tree count")
    func largeRandom() {
        var random = SmallerRandom(seed: 2_026)
        let numbers = (0..<50_000).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
        #expect(SmallerToTheRight.counts(numbers) == fenwickCounts(numbers))
        let fewValues = (0..<50_000).map { _ in Int.random(in: 0...9, using: &random) }
        #expect(SmallerToTheRight.counts(fewValues) == fenwickCounts(fewValues))
    }

    @Test("30,000 values in decreasing, increasing and constant order")
    func largeShapes() {
        let n = 30_000
        #expect(SmallerToTheRight.counts(Array((0..<n).reversed())) == Array((0..<n).reversed()))
        #expect(SmallerToTheRight.counts(Array(0..<n)) == Array(repeating: 0, count: n))
        #expect(SmallerToTheRight.counts(Array(repeating: 7, count: n)) == Array(repeating: 0, count: n))
    }
}
