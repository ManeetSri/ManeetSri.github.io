import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RankedSearchSuggestionsTests {
    typealias Engine = RankedSearchSuggestions.Engine

    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The obvious slow version: filter every phrase, sort, keep the first few.
    private func ranked(_ counts: [String: Int], prefix: String, limit: Int) -> [String] {
        counts.filter { $0.key.hasPrefix(prefix) }
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            .prefix(limit)
            .map(\.key)
    }

    private func randomPhrase(_ steps: inout Steps, alphabet: [Character], length: ClosedRange<Int>) -> String {
        let count = length.lowerBound + steps.next(below: length.count)
        return String((0..<count).map { _ in alphabet[steps.next(below: alphabet.count)] })
    }

    @Test("Suggestions narrow as you type, by count and then alphabetically")
    func example() {
        let engine = Engine(history: ["swift": 5, "swiftui": 9, "switch": 2, "sweater": 5, "struct": 7])
        #expect(engine.type("s") == ["swiftui", "struct", "sweater"])
        #expect(engine.type("w") == ["swiftui", "sweater", "swift"])
        #expect(engine.type("i") == ["swiftui", "swift", "switch"])
        #expect(engine.type("f") == ["swiftui", "swift"])
        #expect(engine.type("t") == ["swiftui", "swift"])
        #expect(engine.type("x") == [])
        #expect(engine.query == "swiftx")
        engine.submit()
        #expect(engine.query == "")
        #expect(engine.suggestions(for: "swiftx") == ["swiftx"])
        #expect(engine.suggestions(for: "swift") == ["swiftui", "swift", "swiftx"])
    }

    @Test("A submitted search can overtake a phrase it was tied with")
    func submitReranks() {
        let engine = Engine(history: ["map": 3, "max": 3])
        #expect(engine.type("m") == ["map", "max"])
        engine.clear()
        for character in "max" {
            _ = engine.type(character)
        }
        engine.submit()
        #expect(engine.type("m") == ["max", "map"])
    }

    @Test("clear forgets the query without recording it")
    func clearDoesNotRecord() {
        let engine = Engine(history: ["zip": 1, "zap": 1])
        _ = engine.type("z")
        _ = engine.type("o")
        #expect(engine.query == "zo")
        engine.clear()
        #expect(engine.query == "")
        #expect(engine.suggestions(for: "zo") == [])
        #expect(engine.type("z") == ["zap", "zip"])
    }

    @Test("Submitting an empty query changes nothing")
    func emptySubmit() {
        let engine = Engine(history: ["a": 1])
        engine.submit()
        #expect(engine.suggestions(for: "") == ["a"])
        #expect(engine.type("a") == ["a"])
    }

    @Test("Phrases can contain spaces, and the limit can change")
    func spacesAndLimit() {
        let engine = Engine(history: ["swift actor": 4, "swift array": 6, "swift async": 6, "swiftly": 1], limit: 2)
        #expect(engine.suggestions(for: "swift") == ["swift array", "swift async"])
        #expect(engine.suggestions(for: "swift ac") == ["swift actor"])
        #expect(engine.suggestions(for: "swiftl") == ["swiftly"])
        #expect(engine.suggestions(for: "") == ["swift array", "swift async"])
        #expect(engine.suggestions(for: "kotlin") == [])
    }

    @Test("Once nothing matches, more typing still matches nothing, until submit or clear")
    func noMatchStaysNoMatch() {
        let engine = Engine(history: ["cat": 2])
        #expect(engine.type("d") == [])
        #expect(engine.type("c") == [], "the query is now \"dc\", not \"c\"")
        engine.clear()
        #expect(engine.type("c") == ["cat"])
    }

    @Test("Thousands of keystrokes match a model that sorts everything", arguments: [1, 2, 3, 4])
    func matchesModel(limit: Int) {
        var steps = Steps(seed: UInt64(limit) &* 613)
        let alphabet: [Character] = ["a", "b", "c", " "]
        var counts: [String: Int] = [:]
        for _ in 0..<40 {
            counts[randomPhrase(&steps, alphabet: alphabet, length: 1...5)] = 1 + steps.next(below: 4)
        }
        let engine = Engine(history: counts, limit: limit)
        var query = ""
        for step in 0..<3_000 {
            switch steps.next(below: 10) {
            case 0:
                engine.submit()
                if !query.isEmpty { counts[query, default: 0] += 1 }
                query = ""
            case 1:
                engine.clear()
                query = ""
            case 2:
                let prefix = randomPhrase(&steps, alphabet: alphabet, length: 0...3)
                if engine.suggestions(for: prefix) != ranked(counts, prefix: prefix, limit: limit) {
                    Issue.record("suggestions(for: \"\(prefix)\") is wrong at step \(step)")
                    return
                }
            default:
                let character = alphabet[steps.next(below: alphabet.count)]
                query.append(character)
                if engine.type(character) != ranked(counts, prefix: query, limit: limit) {
                    Issue.record("typing to \"\(query)\" gives the wrong suggestions at step \(step)")
                    return
                }
                if engine.query != query {
                    Issue.record("query is wrong at step \(step)")
                    return
                }
            }
        }
    }

    @Test("20,000 phrases and 40,000 keystrokes stay fast", .timeLimit(.minutes(1)))
    func large() {
        var steps = Steps(seed: 77)
        let alphabet: [Character] = ["a", "b", "c", "d"]
        var counts: [String: Int] = [:]
        for _ in 0..<20_000 {
            counts[randomPhrase(&steps, alphabet: alphabet, length: 3...10)] = 1 + steps.next(below: 1_000)
        }
        let engine = Engine(history: counts, limit: 5)
        var query = ""
        var correct = true
        for keystroke in 0..<40_000 {
            let character = alphabet[steps.next(below: alphabet.count)]
            query.append(character)
            let suggestions = engine.type(character)
            if keystroke % 200 == 0 && suggestions != ranked(counts, prefix: query, limit: 5) {
                correct = false
                break
            }
            if steps.next(below: 6) == 0 {
                engine.submit()
                counts[query, default: 0] += 1
                query = ""
            }
        }
        #expect(correct)
        #expect(engine.suggestions(for: "a") == ranked(counts, prefix: "a", limit: 5))
    }
}
