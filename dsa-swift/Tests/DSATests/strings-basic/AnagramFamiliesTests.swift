import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct AnagramFamiliesTests {
    @Test("Groups anagrams in order of first appearance")
    func example() {
        let words = ["stone", "night", "notes", "thing", "onset", "tab", "bat", "tones"]
        #expect(AnagramFamilies.groups(words) == [
            ["stone", "notes", "onset", "tones"],
            ["night", "thing"],
            ["tab", "bat"],
        ])
    }

    @Test("Keeps letter counts apart: aab and abb are not anagrams")
    func multiplicity() {
        #expect(AnagramFamilies.groups(["aab", "abb", "bab", "aba"]) == [["aab", "aba"], ["abb", "bab"]])
    }

    @Test("Handles duplicates, single letters and empty words")
    func edgeCases() {
        #expect(AnagramFamilies.groups(["a", "a", "b"]) == [["a", "a"], ["b"]])
        #expect(AnagramFamilies.groups(["", "x", ""]) == [["", ""], ["x"]])
        #expect(AnagramFamilies.groups(["solo"]) == [["solo"]])
        #expect(AnagramFamilies.groups([]) == [])
    }

    @Test("Keeps words that are not anagrams in separate groups")
    func allDifferent() {
        #expect(AnagramFamilies.groups(["cat", "dog", "cow"]) == [["cat"], ["dog"], ["cow"]])
    }

    @Test("Stays fast on 30,000 words")
    func large() {
        // Each of 1,000 base words appears in 30 rotations, all anagrams of each other
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        var words: [String] = []
        for rotation in 0..<30 {
            for base in 0..<1_000 {
                let word = (0..<12).map { letters[(base / (1 + $0 % 3) + $0 * 7 + base * $0) % 26] }
                let shift = rotation % word.count
                words.append(String(word[shift...] + word[..<shift]))
            }
        }
        let groups = AnagramFamilies.groups(words)
        #expect(groups.reduce(0) { $0 + $1.count } == 30_000)
        #expect(groups.allSatisfy { group in group.allSatisfy { $0.sorted() == group.first?.sorted() } })
        let keys = Set(groups.compactMap { $0.first.map { String($0.sorted()) } })
        #expect(keys.count == groups.count, "two groups hold anagrams of each other")
    }
}
