import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CharactersAtOffsetsTests {
    @Test("Examples", arguments: [
        ("swift", [0, 4, 2], "sti"),
        ("banana", [1, 3, 5], "aaa"),
        ("abc", [2, 2, 0], "cca"),
        ("x", [0, 0, 0], "xxx"),
    ])
    func examples(text: String, offsets: [Int], expected: String) {
        #expect(CharactersAtOffsets.characters(in: text, at: offsets) == expected)
    }

    @Test("No offsets gives an empty string")
    func noOffsets() {
        #expect(CharactersAtOffsets.characters(in: "hello", at: []) == "")
        #expect(CharactersAtOffsets.characters(in: "", at: []) == "")
    }

    @Test("Offsets count Characters, not bytes")
    func unicode() {
        // c a f é (space) 🇬🇧 !  → é is one Character, and so is the flag
        #expect(CharactersAtOffsets.characters(in: "café 🇬🇧!", at: [3, 5, 6]) == "é🇬🇧!")
        #expect(CharactersAtOffsets.characters(in: "👋🏽 hi", at: [0, 2]) == "👋🏽h")
    }

    @Test("Stays fast with 50,000 characters and 50,000 offsets")
    func large() {
        let letters = Array("abcdefghij")
        let text = String(repeating: "abcdefghij", count: 5_000)
        let offsets = (0..<50_000).map { ($0 * 7_919) % 50_000 }
        let expected = String(offsets.map { letters[$0 % 10] })
        #expect(CharactersAtOffsets.characters(in: text, at: offsets) == expected)
    }
}
