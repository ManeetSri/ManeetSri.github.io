import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NearlySortedArrayTests {
    /// A tiny deterministic generator, so the randomised tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Takes a sorted array and reverses every block of k + 1 values: nothing moves more than k.
    private static func scrambled(_ sorted: [Int], k: Int) -> [Int] {
        var numbers = sorted
        var start = 0
        while start < numbers.count {
            let end = min(start + k + 1, numbers.count)
            numbers[start..<end].reverse()
            start = end
        }
        return numbers
    }

    @Test("Sorts the examples", arguments: [
        ([2, 1, 4, 3, 6, 5], 1, [1, 2, 3, 4, 5, 6]),
        ([3, 1, 2, 6, 4, 5], 2, [1, 2, 3, 4, 5, 6]),
        ([10, 20, 30], 0, [10, 20, 30]),
        ([5, 5, 4], 2, [4, 5, 5]),
        ([-2, -4, -3, 0], 2, [-4, -3, -2, 0]),
        ([9], 0, [9]),
        ([], 3, []),
    ])
    func examples(numbers: [Int], k: Int, expected: [Int]) {
        var copy = numbers
        NearlySortedArray.sort(&copy, maxDistance: k)
        #expect(copy == expected)
    }

    @Test("A k as large as the array still works")
    func wholeArray() {
        var numbers = [6, 5, 4, 3, 2, 1]
        NearlySortedArray.sort(&numbers, maxDistance: 5)
        #expect(numbers == [1, 2, 3, 4, 5, 6])
    }

    @Test("Sorts hundreds of random nearly sorted arrays")
    func randomised() {
        var steps = Steps(seed: 4)
        var firstFailure: [Int]? = nil
        for _ in 0..<300 {
            let count = steps.next(below: 40)
            let sorted = (0..<count).map { _ in steps.next(below: 50) }.sorted()
            let k = steps.next(below: 6)
            var numbers = Self.scrambled(sorted, k: k)
            let original = numbers
            NearlySortedArray.sort(&numbers, maxDistance: k)
            if numbers != sorted {
                firstFailure = firstFailure ?? original
            }
        }
        #expect(firstFailure == nil, "the first array that wasn't sorted")
    }

    @Test("Stays fast on 200,000 values with k = 6")
    func large() {
        let sorted = (0..<200_000).map { $0 / 3 }               // with plenty of repeats
        var numbers = Self.scrambled(sorted, k: 6)
        NearlySortedArray.sort(&numbers, maxDistance: 6)
        #expect(numbers == sorted)
    }

    @Test("Stays fast on 200,000 values that are already sorted")
    func largeSorted() {
        var numbers = Array(0..<200_000)
        NearlySortedArray.sort(&numbers, maxDistance: 0)
        #expect(numbers == Array(0..<200_000))
    }
}
