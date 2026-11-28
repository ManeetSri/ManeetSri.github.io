import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ExchangeRateQueriesTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// True when every answer matches, allowing for floating-point rounding.
    private func close(_ actual: [Double], _ expected: [Double]) -> Bool {
        actual.count == expected.count && zip(actual, expected).allSatisfy { a, e in
            abs(a - e) <= 1e-9 * max(1, abs(e))
        }
    }

    @Test("The example from the statement")
    func example() {
        let rates: [(String, String, Double)] = [("EUR", "USD", 1.25), ("USD", "JPY", 150)]
        let queries = [("EUR", "JPY"), ("JPY", "EUR"), ("USD", "EUR"), ("EUR", "EUR"), ("GBP", "EUR"), ("GBP", "GBP")]
        let answers = ExchangeRateQueries.answer(rates: rates, queries: queries)
        #expect(close(answers, [187.5, 1 / 187.5, 0.8, 1, -1, -1]))
    }

    @Test("Separate groups of currencies can't be compared")
    func separateGroups() {
        let rates: [(String, String, Double)] = [("A", "B", 2), ("C", "D", 4), ("E", "D", 0.5)]
        let answers = ExchangeRateQueries.answer(rates: rates, queries: [("A", "C"), ("D", "C"), ("E", "C"), ("B", "A"), ("C", "E")])
        #expect(close(answers, [-1, 0.25, 0.125, 0.5, 8]))
    }

    @Test("Rates given in either direction, and repeated rates")
    func directions() {
        let rates: [(String, String, Double)] = [("X", "Y", 3), ("Z", "Y", 6), ("Y", "X", 1.0 / 3)]
        let answers = ExchangeRateQueries.answer(rates: rates, queries: [("X", "Z"), ("Z", "X"), ("Y", "Y")])
        #expect(close(answers, [0.5, 2, 1]))
    }

    @Test("No rates at all")
    func noRates() {
        #expect(ExchangeRateQueries.answer(rates: [], queries: [("A", "A"), ("A", "B")]) == [-1, -1])
        #expect(ExchangeRateQueries.answer(rates: [("A", "B", 2)], queries: []) == [])
    }

    @Test("Random consistent rates match hidden values", arguments: Array(1...10))
    func random(seed: UInt64) {
        var steps = Steps(seed: seed)
        // Every currency has a hidden value, a power of two so the products are exact
        let count = 4 + steps.next(below: 20)
        let values = (0..<count).map { _ in Double(1 << steps.next(below: 10)) / 32 }
        var group = Array(0..<count)          // a labels model of which currencies are linked
        var rates: [(String, String, Double)] = []
        for _ in 0..<steps.next(below: count + 3) {
            let a = steps.next(below: count)
            let b = steps.next(below: count)
            rates.append(("c\(a)", "c\(b)", values[a] / values[b]))
            let from = group[b]
            for index in group.indices where group[index] == from {
                group[index] = group[a]
            }
        }
        var seen = Set<String>()
        for rate in rates {
            seen.insert(rate.0)
            seen.insert(rate.1)
        }
        let queries = (0..<30).map { _ in ("c\(steps.next(below: count))", "c\(steps.next(below: count))") }
        let expected = queries.map { query -> Double in
            let a = Int(query.0.dropFirst())!
            let b = Int(query.1.dropFirst())!
            guard seen.contains(query.0), seen.contains(query.1), group[a] == group[b] else { return -1 }
            return values[a] / values[b]
        }
        #expect(close(ExchangeRateQueries.answer(rates: rates, queries: queries), expected))
    }

    @Test("A chain of 50,000 currencies")
    func longChain() {
        // c0 → c1 is ×2, c1 → c2 is ×0.5, and so on, so one c0 buys 2 of every odd-numbered currency
        let n = 50_000
        let rates = (0..<(n - 1)).map { ("c\($0)", "c\($0 + 1)", $0 % 2 == 0 ? 2.0 : 0.5) }
        var steps = Steps(seed: 11)
        let pairs = (0..<2_000).map { _ in (steps.next(below: n), steps.next(below: n)) }
        let queries = [("c0", "c\(n - 1)"), ("c\(n - 1)", "c0")] + pairs.map { ("c\($0.0)", "c\($0.1)") }
        let value = { (index: Int) -> Double in index % 2 == 0 ? 1 : 0.5 }    // in units of c0
        let expected = [2.0, 0.5] + pairs.map { value($0.0) / value($0.1) }
        #expect(close(ExchangeRateQueries.answer(rates: rates, queries: queries), expected))
    }
}
