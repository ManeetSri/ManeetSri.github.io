import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RunAwareSortTests {
    /// An element with a sort key and a tag recording where it started, for checking stability.
    private struct Tagged: Equatable {
        let key: Int
        let tag: Int
    }

    /// Deterministic pseudo-random values, the same every run.
    private static func scrambled(count: Int, below limit: Int, seed: UInt64) -> [Int] {
        var state = seed
        return (0..<count).map { _ in
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Sorts with `<` and returns the result and the number of comparisons made.
    private static func countingSort(_ numbers: [Int]) -> (result: [Int], comparisons: Int) {
        var comparisons = 0
        let result = RunAwareSort.sorted(numbers) { a, b in
            comparisons += 1
            return a < b
        }
        return (result, comparisons)
    }

    /// n × ⌈log₂ n⌉ + n: what a merge sort may spend.
    private static func budget(_ n: Int) -> Int {
        var levels = 0
        while (1 << levels) < n { levels += 1 }
        return n * levels + n
    }

    @Test("Sorts small arrays", arguments: [
        ([5, 2, 9, 1, 5, 6], [1, 2, 5, 5, 6, 9]),
        ([1, 2, 3, 7, 4, 5, 6], [1, 2, 3, 4, 5, 6, 7]),
        ([6, 5, 4, 1, 2, 3], [1, 2, 3, 4, 5, 6]),
        ([3, -1, 0, -7, 3], [-7, -1, 0, 3, 3]),
        ([2, 2, 2], [2, 2, 2]),
        ([2, 1], [1, 2]),
        ([7], [7]),
        ([], []),
    ])
    func small(numbers: [Int], expected: [Int]) {
        #expect(RunAwareSort.sorted(numbers, by: <) == expected)
    }

    @Test("Follows any order it's given")
    func customOrder() {
        #expect(RunAwareSort.sorted([15, 3, 42, 8, 27], by: >) == [42, 27, 15, 8, 3])
        #expect(RunAwareSort.sorted(["pear", "fig", "apple"], by: <) == ["apple", "fig", "pear"])
    }

    @Test("Is stable")
    func stable() {
        let words = ["pear", "fig", "plum", "kiwi", "yam", "date", "lime", "nut"]
        #expect(RunAwareSort.sorted(words) { $0.count < $1.count } == ["fig", "yam", "nut", "pear", "plum", "kiwi", "date", "lime"])

        let keys = Self.scrambled(count: 5_000, below: 8, seed: 31)
        let items = keys.enumerated().map { Tagged(key: $0.element, tag: $0.offset) }
        let sorted = RunAwareSort.sorted(items) { $0.key < $1.key }
        var expected: [Tagged] = []
        for key in 0..<8 {
            expected += items.filter { $0.key == key }       // each key's items, in their original order
        }
        #expect(sorted == expected)
    }

    @Test("Matches sorted() on hundreds of arrays", arguments: [3, 1_000_000])
    func matchesStandardLibrary(limit: Int) {
        var firstFailure: [Int]? = nil
        for count in 0...200 {
            let numbers = Self.scrambled(count: count, below: limit, seed: UInt64(count * 5 + limit))
            if RunAwareSort.sorted(numbers, by: <) != numbers.sorted() {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array that came out wrong")
    }

    @Test("100,000 numbers already in order cost at most n comparisons")
    func sortedInputIsCheap() {
        let ascending = Array(0..<100_000)
        let run = Self.countingSort(ascending)
        #expect(run.result == ascending)
        #expect(run.comparisons <= ascending.count)

        let flat = Array(repeating: 4, count: 100_000)
        let flatRun = Self.countingSort(flat)
        #expect(flatRun.result == flat)
        #expect(flatRun.comparisons <= flat.count)
    }

    @Test("8 sorted blocks of 12,500 cost at most 4n comparisons")
    func fewRunsAreCheap() {
        var numbers: [Int] = []
        for block in 0..<8 {
            numbers += (0..<12_500).map { $0 * 8 + (7 - block) }  // each block ascending, starting low
        }
        let run = Self.countingSort(numbers)
        #expect(run.result == numbers.sorted())
        #expect(run.comparisons <= 4 * numbers.count)
    }

    @Test("Scrambled and reversed input stay within n log₂ n + n comparisons")
    func worstCaseBudget() {
        let numbers = Self.scrambled(count: 20_000, below: 1_000_000_000, seed: 8)
        let run = Self.countingSort(numbers)
        #expect(run.result == numbers.sorted())
        #expect(run.comparisons <= Self.budget(numbers.count))

        let descending = Array((0..<100_000).reversed())
        let reversedRun = Self.countingSort(descending)
        #expect(reversedRun.result == Array(0..<100_000))
        #expect(reversedRun.comparisons <= Self.budget(descending.count))

        let sawtooth = (0..<100_000).map { $0 % 2 == 0 ? $0 : 100_000 - $0 }
        let sawRun = Self.countingSort(sawtooth)
        #expect(sawRun.result == sawtooth.sorted())
        #expect(sawRun.comparisons <= Self.budget(sawtooth.count))
    }
}
