import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct AnagramSlotsTests {
    @Test("Recognises anagrams", arguments: [
        ("listen", "silent"),
        ("evil", "vile"),
        ("aabbcc", "abcabc"),
        ("a", "a"),
    ])
    func anagrams(first: String, second: String) {
        #expect(AnagramSlots.areAnagrams(first, second))
    }

    @Test("Rejects words that aren't anagrams", arguments: [
        ("rat", "car"),
        ("aab", "abb"),
        ("abc", "abcd"),
        ("a", "b"),
    ])
    func notAnagrams(first: String, second: String) {
        #expect(!AnagramSlots.areAnagrams(first, second))
    }

    @Test("Same letters but different counts aren't anagrams")
    func counts() {
        #expect(!AnagramSlots.areAnagrams("aaab", "abbb"))
    }

    @Test("Two empty strings are anagrams")
    func empty() {
        #expect(AnagramSlots.areAnagrams("", ""))
        #expect(!AnagramSlots.areAnagrams("", "a"))
    }

    @Test("Handles the first and last letters of the alphabet")
    func edges() {
        #expect(AnagramSlots.areAnagrams("zazaz", "azzza"))
    }

    @Test("Stays fast on 50,000 letters")
    func large() {
        let first = String(repeating: "abcdefghijklmnopqrstuvwxy", count: 2_000)
        let second = String(first.reversed())
        #expect(AnagramSlots.areAnagrams(first, second))
        #expect(!AnagramSlots.areAnagrams(first, String(second.dropLast()) + "z"))
    }
}
