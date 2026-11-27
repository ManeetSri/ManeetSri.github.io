import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TypeaheadSuggestionsTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    static let fruit = ["mango", "maple", "map", "marble", "mat", "melon", "mouse"]

    @Test("The example from the statement")
    func example() {
        let result = TypeaheadSuggestions.suggestions(for: "map", in: Self.fruit, limit: 3)
        #expect(result == [
            ["mango", "map", "maple"],
            ["mango", "map", "maple"],
            ["map", "maple"],
        ])
    }

    @Test("Once the typed text matches nothing, every later list is empty")
    func fallsOff() {
        let result = TypeaheadSuggestions.suggestions(for: "mapsx", in: Self.fruit, limit: 3)
        #expect(result == [["mango", "map", "maple"], ["mango", "map", "maple"], ["map", "maple"], [], []])
        #expect(TypeaheadSuggestions.suggestions(for: "zz", in: Self.fruit, limit: 3) == [[], []])
    }

    @Test("Repeated entries are listed once")
    func repeats() {
        let catalogue = ["bee", "bee", "bear", "bee", "beetle"]
        let result = TypeaheadSuggestions.suggestions(for: "bee", in: catalogue, limit: 2)
        #expect(result == [["bear", "bee"], ["bear", "bee"], ["bee", "beetle"]])
    }

    @Test("A limit of 1 gives the alphabetically first match")
    func limitOne() {
        let result = TypeaheadSuggestions.suggestions(for: "mo", in: Self.fruit, limit: 1)
        #expect(result == [["mango"], ["mouse"]])
    }

    @Test("A big limit lists every match in order")
    func bigLimit() {
        let result = TypeaheadSuggestions.suggestions(for: "m", in: Self.fruit, limit: 20)
        #expect(result == [Self.fruit.sorted()])
    }

    @Test("An empty catalogue suggests nothing")
    func emptyCatalogue() {
        #expect(TypeaheadSuggestions.suggestions(for: "ab", in: [], limit: 3) == [[], []])
    }

    @Test("50,000 entries and 300 keystrokes agree with binary search on a sorted list")
    func large() {
        var steps = Steps(seed: 73)
        let letters = Array("abc")
        func randomText(_ length: Int) -> String {
            String((0..<length).map { _ in letters[steps.next(below: letters.count)] })
        }
        let typed = randomText(300)
        var catalogue: [String] = []
        for _ in 0..<45_000 {
            catalogue.append(randomText(1 + steps.next(below: 14)))
        }
        for length in stride(from: 1, through: 300, by: 2) {
            let prefix = String(typed.prefix(length))
            catalogue.append(prefix)
            catalogue.append(prefix + randomText(1 + steps.next(below: 4)))
        }
        while catalogue.count < 50_000 {
            catalogue.append(catalogue[steps.next(below: catalogue.count)])      // some repeats
        }
        let limit = 5
        let sorted = Array(Set(catalogue)).sorted()
        func expected(_ prefix: String) -> [String] {
            var low = 0
            var high = sorted.count
            while low < high {                                                  // the first entry ≥ prefix
                let mid = low + (high - low) / 2
                if sorted[mid] < prefix { low = mid + 1 } else { high = mid }
            }
            var result: [String] = []
            while low < sorted.count && result.count < limit && sorted[low].hasPrefix(prefix) {
                result.append(sorted[low])
                low += 1
            }
            return result
        }
        let result = TypeaheadSuggestions.suggestions(for: typed, in: catalogue, limit: limit)
        #expect(result.count == 300)
        var wrong = 0
        for length in 1...300 where length <= result.count {
            if result[length - 1] != expected(String(typed.prefix(length))) { wrong += 1 }
        }
        #expect(wrong == 0)
    }
}
