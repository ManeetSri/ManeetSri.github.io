import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MissingAndDoubledTests {
    /// A tiny deterministic generator, so the randomised tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The expected answer, by counting every value in a separate array.
    private static func expected(_ numbers: [Int]) -> (missing: [Int], doubled: [Int]) {
        var counts = [Int](repeating: 0, count: numbers.count + 1)
        for value in numbers { counts[value] += 1 }
        let values = Array(1..<(numbers.count + 1))
        return (values.filter { counts[$0] == 0 }, values.filter { counts[$0] == 2 })
    }

    /// 1 to n, with `doubles` values each replaced by a copy of another, then shuffled.
    private static func makeInput(count: Int, doubles: Int, steps: inout Steps) -> [Int] {
        var numbers = (0..<count).map { $0 + 1 }
        var used = Set<Int>()
        var replaced = 0
        while replaced < doubles {
            let from = steps.next(below: count)          // this value gets a second copy…
            let to = steps.next(below: count)            // …which overwrites this one
            if from == to || used.contains(from) || used.contains(to) { continue }
            used.insert(from)
            used.insert(to)
            numbers[to] = numbers[from]
            replaced += 1
        }
        for i in stride(from: numbers.count - 1, to: 0, by: -1) {
            numbers.swapAt(i, steps.next(below: i + 1))
        }
        return numbers
    }

    @Test("Finds the missing and doubled values", arguments: [
        ([5, 3, 1, 3, 6, 1], [2, 4], [1, 3]),
        ([2, 2], [1], [2]),
        ([4, 1, 4, 1], [2, 3], [1, 4]),
        ([3, 1, 3], [2], [3]),
        ([1, 2, 3], [], []),
        ([2, 3, 1], [], []),
        ([1], [], []),
        ([], [], []),
    ])
    func examples(numbers: [Int], missing: [Int], doubled: [Int]) {
        var copy = numbers
        let result = MissingAndDoubled.find(in: &copy)
        #expect(result.missing == missing)
        #expect(result.doubled.sorted() == doubled)
    }

    @Test("Matches counting on hundreds of random arrays")
    func randomised() {
        var steps = Steps(seed: 1_234)
        var firstFailure: [Int]? = nil
        for _ in 0..<400 {
            let count = steps.next(below: 30)
            let numbers = Self.makeInput(count: count, doubles: steps.next(below: count / 2 + 1), steps: &steps)
            var copy = numbers
            let result = MissingAndDoubled.find(in: &copy)
            let expected = Self.expected(numbers)
            if result.missing != expected.missing || result.doubled.sorted() != expected.doubled {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array with the wrong answer")
    }

    @Test("Stays fast on 200,000 values")
    func large() {
        var steps = Steps(seed: 77)
        let numbers = Self.makeInput(count: 200_000, doubles: 30_000, steps: &steps)
        var copy = numbers
        let result = MissingAndDoubled.find(in: &copy)
        let expected = Self.expected(numbers)
        #expect(result.missing == expected.missing)
        #expect(result.doubled.sorted() == expected.doubled)
        #expect(result.missing.count == 30_000)
    }

    @Test("A large array with nothing missing")
    func largePermutation() {
        var numbers = (0..<200_000).map { ($0 * 7_919) % 200_000 + 1 }
        let result = MissingAndDoubled.find(in: &numbers)
        #expect(result.missing.isEmpty)
        #expect(result.doubled.isEmpty)
    }
}
