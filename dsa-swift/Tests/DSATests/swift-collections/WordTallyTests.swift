import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct WordTallyTests {
    @Test("Counts repeated words")
    func counts() {
        let result = WordTally.tally(["red", "blue", "red", "green", "red", "blue"])
        #expect(result == ["red": 3, "blue": 2, "green": 1])
    }

    @Test("Treats different capitalisation as different words")
    func caseSensitive() {
        #expect(WordTally.tally(["Cat", "cat", "cat"]) == ["Cat": 1, "cat": 2])
    }

    @Test("Handles empty and single-word input")
    func tiny() {
        #expect(WordTally.tally([]) == [:])
        #expect(WordTally.tally(["swift"]) == ["swift": 1])
    }

    @Test("Has no entry for words that never appear")
    func noMissingKeys() {
        let result = WordTally.tally(["a", "b", "a"])
        #expect(result.count == 2)
        #expect(result["c"] == nil)
    }

    @Test("Stays fast on 100,000 words")
    func large() {
        let words = (0..<100_000).map { "w\($0 % 100)" }
        let result = WordTally.tally(words)
        #expect(result.count == 100)
        #expect(result.values.allSatisfy { $0 == 1_000 })
    }
}
