import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ReverseWordOrderTests {
    @Test("Reverses the order of the words", arguments: [
        ("the sky is blue", "blue is sky the"),
        ("hello world", "world hello"),
        ("one", "one"),
        ("a b c d", "d c b a"),
    ])
    func reverses(sentence: String, expected: String) {
        #expect(ReverseWordOrder.reverse(sentence) == expected)
    }

    @Test("Collapses runs of spaces and trims the ends")
    func spaces() {
        #expect(ReverseWordOrder.reverse("  learn   swift  today ") == "today swift learn")
        #expect(ReverseWordOrder.reverse("   solo   ") == "solo")
    }

    @Test("Keeps each word's letters and punctuation as they are")
    func wordsUnchanged() {
        #expect(ReverseWordOrder.reverse("Hello, World!") == "World! Hello,")
    }

    @Test("Returns an empty string when there are no words")
    func noWords() {
        #expect(ReverseWordOrder.reverse("") == "")
        #expect(ReverseWordOrder.reverse("     ") == "")
    }

    @Test("Stays fast on a long sentence")
    func large() {
        let words = (0..<20_000).map { "w\($0)" }
        let sentence = words.joined(separator: "  ")
        #expect(ReverseWordOrder.reverse(sentence) == words.reversed().joined(separator: " "))
    }
}
