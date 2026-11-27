import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct PartitionRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

private struct PartitionTicket: Equatable {
    let id: Int
    let urgent: Bool
}

@Suite struct StablePartitionHelperTests {
    @Test("Examples", arguments: [
        ([10, 20, 30, 40, 50, 60, 70, 80], 20, [10, 30, 50, 70, 20, 40, 60, 80], 4),
        ([3, 6, 9, 1, 4], 3, [1, 4, 3, 6, 9], 2),
        ([5, 10, 15], 5, [5, 10, 15], 0),
        ([1, 2, 4], 7, [1, 2, 4], 3),
        ([], 2, [], 0),
        ([8], 2, [8], 0),
        ([9], 2, [9], 1),
    ] as [([Int], Int, [Int], Int)])
    func examples(items: [Int], divisor: Int, expected: [Int], pivot: Int) {
        var numbers = items
        let result = StablePartitionHelper.stablePartition(&numbers) { $0.isMultiple(of: divisor) }
        #expect(numbers == expected)
        #expect(result == pivot)
    }

    @Test("Strings by length keep their order on both sides")
    func strings() {
        var words = ["kiwi", "banana", "fig", "cherry", "plum", "apple"]
        let pivot = StablePartitionHelper.stablePartition(&words) { $0.count > 4 }
        #expect(words == ["kiwi", "fig", "plum", "banana", "cherry", "apple"])
        #expect(pivot == 3)
    }

    @Test("Records with equal keys stay in their original order")
    func records() {
        var tickets = (0..<12).map { PartitionTicket(id: $0, urgent: $0 % 3 == 1) }
        let pivot = StablePartitionHelper.stablePartition(&tickets) { !$0.urgent }
        #expect(pivot == 4)
        #expect(tickets.map(\.id) == [1, 4, 7, 10, 0, 2, 3, 5, 6, 8, 9, 11])
    }

    @Test("Calls the predicate exactly once per element")
    func predicateCalls() {
        var numbers = Array(0..<1_000)
        var calls = 0
        let pivot = StablePartitionHelper.stablePartition(&numbers) { value in
            calls += 1
            return value % 7 == 0
        }
        #expect(calls == 1_000)
        #expect(pivot == 857)
    }

    @Test("Matches filtering on 300 random arrays")
    func random() {
        var random = PartitionRandom(seed: 69)
        for _ in 0..<300 {
            let items = (0..<Int.random(in: 0...40, using: &random)).map { _ in Int.random(in: -20...20, using: &random) }
            let threshold = Int.random(in: -25...25, using: &random)
            var numbers = items
            let pivot = StablePartitionHelper.stablePartition(&numbers) { $0 > threshold }
            let small = items.filter { $0 <= threshold }
            #expect(numbers == small + items.filter { $0 > threshold })
            #expect(pivot == small.count)
        }
    }

    @Test("200,000 elements")
    func large() {
        var numbers = Array((0..<200_000).reversed())
        let pivot = StablePartitionHelper.stablePartition(&numbers) { $0.isMultiple(of: 2) }
        #expect(pivot == 100_000)
        #expect(Array(numbers.prefix(3)) == [199_999, 199_997, 199_995])
        #expect(Array(numbers[pivot...].prefix(3)) == [199_998, 199_996, 199_994])
        #expect(numbers.last == 0)
    }
}
