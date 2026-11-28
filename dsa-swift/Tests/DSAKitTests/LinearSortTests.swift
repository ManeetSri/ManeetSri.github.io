import Testing
import DSAKit

@Suite struct LinearSortTests {
    /// A tiny deterministic generator, so the randomised tests do the same thing every run.
    private struct Steps {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }

        /// Any Int at all, from Int.min to Int.max.
        mutating func anyInt() -> Int {
            let high = UInt64(next(below: 1 << 31))
            let middle = UInt64(next(below: 1 << 31))
            let low = UInt64(next(below: 4))
            return Int(bitPattern: UInt(high << 33 | middle << 2 | low))
        }
    }

    enum Algorithm: String, CaseIterable, CustomStringConvertible {
        case counting, radix

        var description: String { rawValue }

        func sorted(_ numbers: [Int]) -> [Int] {
            switch self {
            case .counting: numbers.countingSorted()
            case .radix: numbers.radixSorted()
            }
        }
    }

    @Test("Empty and single-element arrays", arguments: Algorithm.allCases)
    func tiny(algorithm: Algorithm) {
        #expect(algorithm.sorted([]) == [])
        #expect(algorithm.sorted([7]) == [7])
        #expect(algorithm.sorted([-7]) == [-7])
    }

    @Test("Sorts small arrays", arguments: Algorithm.allCases)
    func small(algorithm: Algorithm) {
        let cases: [[Int]] = [
            [4, 2, 2, 8, 3, 3, 1],
            [170, 45, 75, 90, 802, 24, 2, 66],
            [3, 3, 3],
            [0, 0, 1, 0],
            [2, 1],
            [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
            Array(0..<50),
        ]
        for numbers in cases {
            #expect(algorithm.sorted(numbers) == numbers.sorted(), "sorting \(numbers)")
        }
    }

    @Test("Handles negative numbers", arguments: Algorithm.allCases)
    func negatives(algorithm: Algorithm) {
        #expect(algorithm.sorted([3, -1, 2, 3, 0]) == [-1, 0, 2, 3, 3])
        #expect(algorithm.sorted([-5, -1, -3, -1]) == [-5, -3, -1, -1])
        #expect(algorithm.sorted([-1, 1, -256, 256, -255, 255]) == [-256, -255, -1, 1, 255, 256])
    }

    @Test("Doesn't change the original array", arguments: Algorithm.allCases)
    func leavesOriginal(algorithm: Algorithm) {
        let numbers = [3, 1, 2]
        _ = algorithm.sorted(numbers)
        #expect(numbers == [3, 1, 2])
    }

    @Test("Radix sort covers the whole Int range")
    func radixExtremes() {
        let numbers = [Int.max, 0, Int.min, -1, 1, Int.min + 1, Int.max - 1, 1 << 40, -(1 << 40)]
        #expect(numbers.radixSorted() == numbers.sorted())
        #expect([Int.min, Int.min, Int.max].radixSorted() == [Int.min, Int.min, Int.max])
    }

    @Test("Counting sort handles a range ending at Int.max")
    func countingNearTheTop() {
        let numbers = [Int.max, Int.max - 3, Int.max - 1, Int.max - 3]
        #expect(numbers.countingSorted() == numbers.sorted())
        let low = [Int.min + 2, Int.min, Int.min + 1]
        #expect(low.countingSorted() == [Int.min, Int.min + 1, Int.min + 2])
    }

    @Test("Matches sorted() on hundreds of random small-range arrays", arguments: Algorithm.allCases)
    func randomisedSmallRange(algorithm: Algorithm) {
        var steps = Steps(seed: 32)
        var firstFailure: [Int]? = nil
        for round in 0..<300 {
            let count = steps.next(below: 60)
            let spread = 1 + round * 7
            let offset = steps.next(below: 2 * spread + 1) - spread
            let numbers = (0..<count).map { _ in steps.next(below: spread) + offset }
            if algorithm.sorted(numbers) != numbers.sorted() {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array that wasn't sorted correctly")
    }

    @Test("Radix sort matches sorted() on numbers from the whole Int range")
    func radixRandomWide() {
        var steps = Steps(seed: 256)
        var firstFailure: [Int]? = nil
        for _ in 0..<200 {
            let numbers = (0..<steps.next(below: 80)).map { _ in steps.anyInt() }
            if numbers.radixSorted() != numbers.sorted() {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array that wasn't sorted correctly")
    }

    @Test("Sorts 200,000 numbers", arguments: Algorithm.allCases)
    func large(algorithm: Algorithm) {
        var steps = Steps(seed: 9)
        let numbers = (0..<200_000).map { _ in steps.next(below: 100_000) - 50_000 }
        #expect(algorithm.sorted(numbers) == numbers.sorted())
    }
}
