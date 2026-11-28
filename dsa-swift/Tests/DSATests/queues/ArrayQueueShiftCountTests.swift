import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ArrayQueueShiftCountTests {
    @Test("Counts the moves", arguments: [
        ("EEED", 2),
        ("EEEDDD", 3),
        ("EDEDED", 0),
        ("EEEEEDEDED", 12),
        ("DDE", 0),
        ("", 0),
        ("E", 0),
        ("EED", 1),
        ("EEDDDEEED", 3),
    ])
    func examples(operations: String, expected: Int) {
        #expect(ArrayQueueShiftCount.moves(for: operations) == expected)
    }

    @Test("Draining n items costs n(n - 1)/2", arguments: [10, 100, 1_000])
    func triangle(n: Int) {
        let log = String(repeating: "E", count: n) + String(repeating: "D", count: n)
        #expect(ArrayQueueShiftCount.moves(for: log) == n * (n - 1) / 2)
    }

    @Test("Handles billions of moves without making them")
    func large() {
        let drain = String(repeating: "E", count: 100_000) + String(repeating: "D", count: 100_000)
        #expect(ArrayQueueShiftCount.moves(for: drain) == 4_999_950_000)
        // A busy counter: 1,001 waiting at every dequeue, 400,000 served one at a time
        let busy = String(repeating: "E", count: 1_000) + String(repeating: "ED", count: 400_000)
        #expect(ArrayQueueShiftCount.moves(for: busy) == 400_000 * 1_000)
    }
}
