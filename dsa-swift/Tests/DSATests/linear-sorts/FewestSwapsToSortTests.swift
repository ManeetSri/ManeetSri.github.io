import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct FewestSwapsToSortTests {
    /// A tiny deterministic generator, so the randomised tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Selection sort's swaps (skipping swaps of a value with itself): a different algorithm
    /// that also happens to make the fewest swaps on a permutation. O(n²), so small arrays only.
    private static func selectionSwaps(_ numbers: [Int]) -> Int {
        var items = numbers
        var swaps = 0
        for i in items.indices {
            var smallest = i
            for j in (i + 1)..<items.count where items[j] < items[smallest] {
                smallest = j
            }
            if smallest != i {
                items.swapAt(i, smallest)
                swaps += 1
            }
        }
        return swaps
    }

    /// n minus the number of cycles, counted by following each cycle once.
    private static func byCycles(_ numbers: [Int]) -> Int {
        var visited = [Bool](repeating: false, count: numbers.count)
        var cycles = 0
        for start in numbers.indices where !visited[start] {
            cycles += 1
            var index = start
            while !visited[index] {
                visited[index] = true
                index = numbers[index] - 1
            }
        }
        return numbers.count - cycles
    }

    @Test("Counts the fewest swaps", arguments: [
        ([3, 5, 2, 1, 4], 4),
        ([2, 1, 4, 3], 2),
        ([4, 3, 2, 1], 2),
        ([1, 2, 3], 0),
        ([2, 3, 1], 2),
        ([1, 3, 2, 4], 1),
        ([1], 0),
        ([], 0),
    ])
    func examples(numbers: [Int], expected: Int) {
        #expect(FewestSwapsToSort.fewestSwaps(numbers) == expected)
    }

    @Test("Matches selection sort's swaps on hundreds of random permutations")
    func randomised() {
        var steps = Steps(seed: 88)
        var firstFailure: [Int]? = nil
        for _ in 0..<400 {
            var numbers = Array(0..<steps.next(below: 40)).map { $0 + 1 }
            for i in stride(from: numbers.count - 1, to: 0, by: -1) {
                numbers.swapAt(i, steps.next(below: i + 1))
            }
            if FewestSwapsToSort.fewestSwaps(numbers) != Self.selectionSwaps(numbers) {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first permutation with the wrong count")
    }

    @Test("Doesn't change the caller's array")
    func leavesInputAlone() {
        let numbers = [3, 1, 2]
        _ = FewestSwapsToSort.fewestSwaps(numbers)
        #expect(numbers == [3, 1, 2])
    }

    @Test("Stays fast on permutations of 200,000")
    func large() {
        let n = 200_000
        let mixed = (0..<n).map { ($0 * 7_919) % n + 1 }
        #expect(FewestSwapsToSort.fewestSwaps(mixed) == Self.byCycles(mixed))
        #expect(FewestSwapsToSort.fewestSwaps(Array((1...n).reversed())) == n / 2)
        #expect(FewestSwapsToSort.fewestSwaps(Array(2...n) + [1]) == n - 1)
        #expect(FewestSwapsToSort.fewestSwaps(Array(1...n)) == 0)
    }
}
