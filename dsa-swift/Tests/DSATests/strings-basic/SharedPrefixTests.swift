import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SharedPrefixTests {
    @Test("Finds the longest shared prefix", arguments: [
        (["interview", "internet", "interval", "internal"], "inter"),
        (["swift", "swiftui", "swiftly"], "swift"),
        (["apple", "banana"], ""),
        (["solo"], "solo"),
        ([String](), ""),
        (["", "a"], ""),
        (["a", ""], ""),
        (["same", "same", "same"], "same"),
        (["abc", "ab", "abcd"], "ab"),
        (["flow", "flower", "flo"], "flo"),
        (["Cat", "cat"], ""),
    ])
    func examples(words: [String], expected: String) {
        #expect(SharedPrefix.longestCommonPrefix(words) == expected)
    }

    @Test("Compares whole characters")
    func unicode() {
        #expect(SharedPrefix.longestCommonPrefix(["café", "cafés", "caféine"]) == "café")
        #expect(SharedPrefix.longestCommonPrefix(["café", "cafe"]) == "caf")
    }

    @Test("Stays fast on 2,000 long words")
    func large() {
        let stem = String(repeating: "x", count: 500)
        let words = (0..<2_000).map { stem + String($0) }
        #expect(SharedPrefix.longestCommonPrefix(words) == stem)
        #expect(SharedPrefix.longestCommonPrefix(words + ["y"]) == "")
    }
}
