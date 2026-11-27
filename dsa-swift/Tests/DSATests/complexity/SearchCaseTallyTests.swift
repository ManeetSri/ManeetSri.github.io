import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SearchCaseTallyTests {
    typealias Tally = SearchCaseTally.Tally

    // Runs linear search for every query, for small inputs
    static func simulated(items: [Int], queries: [Int]) -> Tally {
        var costs: [Int] = []
        for query in queries {
            var comparisons = 0
            for item in items {
                comparisons += 1
                if item == query { break }
            }
            costs.append(comparisons)
        }
        return Tally(best: costs.min()!, worst: costs.max()!, total: costs.reduce(0, +))
    }

    @Test("The examples")
    func examples() {
        #expect(SearchCaseTally.tally(items: [4, 8, 15, 16, 23, 42], queries: [4, 42, 7, 16]) == Tally(best: 1, worst: 6, total: 17))
        #expect(SearchCaseTally.tally(items: [5, 3, 5, 3], queries: [3, 5, 9]) == Tally(best: 1, worst: 4, total: 7))
        #expect(SearchCaseTally.tally(items: [], queries: [1, 2]) == Tally(best: 0, worst: 0, total: 0))
    }

    @Test("A single query is its own best and worst case")
    func singleQuery() {
        #expect(SearchCaseTally.tally(items: [9, 8, 7], queries: [7]) == Tally(best: 3, worst: 3, total: 3))
        #expect(SearchCaseTally.tally(items: [9, 8, 7], queries: [9]) == Tally(best: 1, worst: 1, total: 1))
        #expect(SearchCaseTally.tally(items: [9, 8, 7], queries: [0]) == Tally(best: 3, worst: 3, total: 3))
    }

    @Test("Only the first copy of a value counts")
    func duplicates() {
        #expect(SearchCaseTally.tally(items: [2, 2, 2, 1], queries: [2, 1]) == Tally(best: 1, worst: 4, total: 5))
        #expect(SearchCaseTally.tally(items: [-1, Int.max, Int.min, Int.max], queries: [Int.min, Int.max, Int.max]) == Tally(best: 2, worst: 3, total: 7))
    }

    @Test("Matches running every search on mixed inputs")
    func matchesSimulation() {
        var seed = 12_345
        func next(_ bound: Int) -> Int {
            seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
            return seed % bound
        }
        for round in 0..<200 {
            let items = (0..<(round % 25)).map { _ in next(15) - 5 }
            let queries = (0..<(1 + round % 9)).map { _ in next(20) - 7 }
            let expected = Self.simulated(items: items, queries: queries)
            #expect(SearchCaseTally.tally(items: items, queries: queries) == expected, "items \(items), queries \(queries)")
        }
    }

    @Test("Every position queried once: the average is (n + 1) / 2")
    func everyPosition() {
        let n = 100_000
        let items = Array(0..<n)
        let result = SearchCaseTally.tally(items: items, queries: items.reversed())
        #expect(result == Tally(best: 1, worst: n, total: 5_000_050_000))
        #expect(result.total * 2 == n * (n + 1))
    }

    @Test("A hundred thousand missing targets, without 10¹⁰ comparisons")
    func allMissing() {
        let n = 100_000
        let items = (0..<n).map { $0 * 2 }
        let queries = (0..<n).map { $0 * 2 + 1 }
        #expect(SearchCaseTally.tally(items: items, queries: queries) == Tally(best: n, worst: n, total: 10_000_000_000))
    }
}
