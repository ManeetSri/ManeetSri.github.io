import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RecursiveCallCountTests {
    // The functions from the statement, counting their calls for real
    static func split(_ n: Int, calls: inout Int) {
        calls += 1
        if n <= 1 { return }
        split(n / 2, calls: &calls)
        split(n - n / 2, calls: &calls)
    }

    static func fibonacci(_ n: Int, calls: inout Int) -> Int {
        calls += 1
        if n < 2 { return n }
        return fibonacci(n - 1, calls: &calls) + fibonacci(n - 2, calls: &calls)
    }

    static func countedSplitCalls(_ n: Int) -> Int {
        var calls = 0
        split(n, calls: &calls)
        return calls
    }

    static func countedFibonacciCalls(_ n: Int) -> Int {
        var calls = 0
        _ = fibonacci(n, calls: &calls)
        return calls
    }

    @Test("split examples", arguments: [(0, 1), (1, 1), (2, 3), (3, 5), (8, 15), (100, 199)])
    func splitExamples(n: Int, expected: Int) {
        #expect(RecursiveCallCount.splitCalls(n) == expected)
    }

    @Test("split matches the real recursion for every n up to 2,000")
    func splitMatchesRecursion() {
        let wrong = (0...2_000).filter { RecursiveCallCount.splitCalls($0) != Self.countedSplitCalls($0) }
        #expect(wrong.isEmpty, "wrong for n = \(Array(wrong.prefix(5)))")
    }

    @Test("split for huge n, without recursing")
    func splitHuge() {
        #expect(RecursiveCallCount.splitCalls(1_000_000_000_000_000_000) == 1_999_999_999_999_999_999)
    }

    @Test("fibonacci examples", arguments: [(0, 1), (1, 1), (2, 3), (3, 5), (5, 15), (10, 177)])
    func fibonacciExamples(n: Int, expected: Int) {
        #expect(RecursiveCallCount.fibonacciCalls(n) == expected)
    }

    @Test("fibonacci matches the real recursion for every n up to 25")
    func fibonacciMatchesRecursion() {
        let wrong = (0...25).filter { RecursiveCallCount.fibonacciCalls($0) != Self.countedFibonacciCalls($0) }
        #expect(wrong.isEmpty, "wrong for n = \(Array(wrong.prefix(5)))")
    }

    @Test("fibonacci for large n, without recursing")
    func fibonacciLarge() {
        #expect(RecursiveCallCount.fibonacciCalls(50) == 40_730_022_147)
        #expect(RecursiveCallCount.fibonacciCalls(85) == 840_392_281_454_979_345)
    }
}
