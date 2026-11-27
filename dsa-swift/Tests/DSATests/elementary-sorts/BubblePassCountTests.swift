import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BubblePassCountTests {
    /// A tiny deterministic generator, so the randomised tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Runs bubble sort for real and counts the passes that swap: fine for short arrays only.
    private static func simulate(_ input: [Int]) -> Int {
        var items = input
        var busy = 0
        while true {
            var swapped = false
            for j in items.indices.dropLast() where items[j] > items[j + 1] {
                items.swapAt(j, j + 1)
                swapped = true
            }
            if !swapped { return busy }
            busy += 1
        }
    }

    @Test("Counts the passes that swap", arguments: [
        ([5, 1, 4, 2, 8, 3], 3),
        ([1, 2, 3], 0),
        ([2, 3, 4, 5, 6, 1], 5),
        ([6, 1, 2, 3, 4, 5], 1),
        ([3, 3, 1], 2),
        ([2, 1], 1),
        ([4, 3, 2, 1], 3),
        ([1, 1, 1], 0),
        ([-1, -5, 0, -3], 2),
        ([7], 0),
        ([], 0),
    ])
    func examples(numbers: [Int], expected: Int) {
        #expect(BubblePassCount.busyPasses(numbers) == expected)
    }

    @Test("Matches a real bubble sort on hundreds of random arrays")
    func randomised() {
        var steps = Steps(seed: 2_026)
        var firstFailure: [Int]? = nil
        for round in 0..<400 {
            let spread = 2 + round % 12          // small spreads make plenty of equal values
            let numbers = (0..<steps.next(below: 25)).map { _ in steps.next(below: spread) }
            if BubblePassCount.busyPasses(numbers) != Self.simulate(numbers) {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array with the wrong count")
    }

    @Test("Reversed and turtle arrays of 100,000 values")
    func largeTurtles() {
        #expect(BubblePassCount.busyPasses(Array((0..<100_000).reversed())) == 99_999)
        #expect(BubblePassCount.busyPasses(Array(1..<100_000) + [0]) == 99_999)
    }

    @Test("Rabbits and neighbour swaps in 100,000 values")
    func largeRabbits() {
        #expect(BubblePassCount.busyPasses([100_000] + Array(0..<99_999)) == 1)
        #expect(BubblePassCount.busyPasses((0..<100_000).map { $0 ^ 1 }) == 1)
        #expect(BubblePassCount.busyPasses(Array(0..<100_000)) == 0)
    }

    @Test("Many equal values in 100,000")
    func largeDuplicates() {
        // Blocks of 20,000 5s, 4s, 3s, 2s and 1s: every 1 has to travel 80,000 places left
        let numbers = (0..<100_000).map { 5 - $0 / 20_000 }
        #expect(BubblePassCount.busyPasses(numbers) == 80_000)
    }
}
