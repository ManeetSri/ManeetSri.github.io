import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct VowelTallyTests {
    @Test("Counts vowels", arguments: [
        ("swift", 1),
        ("banana", 3),
        ("queue", 4),
        ("rhythm", 0),
        ("aeiou", 5),
    ])
    func counts(text: String, expected: Int) {
        #expect(VowelTally.count(in: text) == expected)
    }

    @Test("Counts uppercase vowels too")
    func uppercase() {
        #expect(VowelTally.count(in: "AEIOU") == 5)
        #expect(VowelTally.count(in: "Ice Cream") == 4)
    }

    @Test("Ignores spaces, digits and punctuation")
    func ignoresOthers() {
        #expect(VowelTally.count(in: "Hello, World! 123") == 3)
        #expect(VowelTally.count(in: "   ") == 0)
    }

    @Test("Doesn't count y")
    func notY() {
        #expect(VowelTally.count(in: "sky") == 0)
    }

    @Test("Returns 0 for an empty string")
    func empty() {
        #expect(VowelTally.count(in: "") == 0)
    }

    @Test("Stays fast on a long string")
    func large() {
        let text = String(repeating: "abcde", count: 20_000)
        #expect(VowelTally.count(in: text) == 40_000)
    }
}
