import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PartialSelectionSortTests {
    /// A tiny deterministic generator, so the randomised tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// True if `result` holds the same values as `original`, with the k smallest first, in order.
    private static func isCorrect(_ result: [Int], from original: [Int], k: Int) -> Bool {
        let sorted = original.sorted()
        return result.sorted() == sorted && Array(result.prefix(k)) == Array(sorted.prefix(k))
    }

    @Test("Puts the k smallest first, in order", arguments: [
        ([58, 41, 73, 39, 66, 45], 3),
        ([5, 1, 5, 1, 2], 2),
        ([4, -2, 9, -7, 0], 4),
        ([3, 3, 3, 3], 2),
        ([10, 20, 30], 3),
        ([30, 20, 10], 1),
        ([8], 1),
    ])
    func smallestFirst(numbers: [Int], k: Int) {
        var copy = numbers
        PartialSelectionSort.sortFirst(&copy, count: k)
        #expect(Self.isCorrect(copy, from: numbers, k: k))
    }

    @Test("Exact results for the examples")
    func examples() {
        var laps = [58, 41, 73, 39, 66, 45]
        PartialSelectionSort.sortFirst(&laps, count: 3)
        #expect(Array(laps.prefix(3)) == [39, 41, 45])

        var repeats = [5, 1, 5, 1, 2]
        PartialSelectionSort.sortFirst(&repeats, count: 2)
        #expect(Array(repeats.prefix(2)) == [1, 1])
    }

    @Test("k = 0 changes nothing that matters")
    func zero() {
        var numbers = [9, 8, 7]
        PartialSelectionSort.sortFirst(&numbers, count: 0)
        #expect(numbers.sorted() == [7, 8, 9])
    }

    @Test("A k larger than the array sorts everything")
    func largeK() {
        var numbers = [4, 2, 9, 1]
        PartialSelectionSort.sortFirst(&numbers, count: 10)
        #expect(numbers == [1, 2, 4, 9])
        var pair = [4, 2]
        PartialSelectionSort.sortFirst(&pair, count: 5)
        #expect(pair == [2, 4])
    }

    @Test("Empty arrays are fine")
    func empty() {
        var numbers: [Int] = []
        PartialSelectionSort.sortFirst(&numbers, count: 3)
        #expect(numbers == [])
    }

    @Test("Correct on hundreds of random arrays")
    func randomised() {
        var steps = Steps(seed: 30)
        var firstFailure: [Int]? = nil
        for _ in 0..<400 {
            let numbers = (0..<steps.next(below: 30)).map { _ in steps.next(below: 20) - 10 }
            let k = steps.next(below: 35)
            var copy = numbers
            PartialSelectionSort.sortFirst(&copy, count: k)
            if !Self.isCorrect(copy, from: numbers, k: k) {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array that went wrong")
    }

    @Test("Stays fast on 200,000 values with a small k")
    func large() {
        let numbers = (0..<200_000).map { ($0 * 7_919) % 200_003 }
        var copy = numbers
        PartialSelectionSort.sortFirst(&copy, count: 4)
        #expect(Array(copy.prefix(4)) == Array(numbers.sorted().prefix(4)))
        #expect(copy.count == 200_000)
    }
}
