import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PalindromeOneDeletionTests {
    private static func isPalindrome(_ characters: [Character]) -> Bool {
        characters == Array(characters.reversed())
    }

    /// Tries every possible deletion (and none).
    private static func slowCheck(_ text: String) -> Bool {
        let characters = Array(text)
        if isPalindrome(characters) { return true }
        for skip in characters.indices {
            var shorter = characters
            shorter.remove(at: skip)
            if isPalindrome(shorter) { return true }
        }
        return false
    }

    @Test("Already a palindrome, or one deletion away", arguments: [
        "racecar", "level", "kayaks", "abccbxa", "radxar", "cbbcc", "ccbbc", "ab", "a", "", "zz", "noon!",
    ])
    func almost(text: String) {
        #expect(PalindromeOneDeletion.isAlmostPalindrome(text))
    }

    @Test("Needs more than one deletion", arguments: [
        "abc", "abcda", "tebbem", "Aba", "swift", "abcdeba",
    ])
    func notAlmost(text: String) {
        #expect(!PalindromeOneDeletion.isAlmostPalindrome(text))
    }

    @Test("Matches trying every deletion on many short strings")
    func matchesBruteForce() {
        var firstMismatch: String? = nil
        for seed in 0..<600 {
            let length = seed % 8
            let text = String((0..<length).map { index -> Character in
                ((index * 7 + seed * 3) / (seed % 3 + 1)) % 3 == 0 ? "a" : (index + seed) % 2 == 0 ? "b" : "c"
            })
            if PalindromeOneDeletion.isAlmostPalindrome(text) != Self.slowCheck(text) {
                firstMismatch = firstMismatch ?? text
            }
        }
        #expect(firstMismatch == nil, "the first string where the answer differs from the brute force")
    }

    @Test("Stays fast on 100,000 characters")
    func large() {
        let oneOff = String(repeating: "a", count: 50_000) + "b" + String(repeating: "a", count: 49_999)
        #expect(PalindromeOneDeletion.isAlmostPalindrome(oneOff))

        let twoOff = "x" + String(repeating: "a", count: 99_998) + "y"
        #expect(!PalindromeOneDeletion.isAlmostPalindrome(twoOff))

        let mirrored = String(repeating: "ab", count: 25_000) + String(repeating: "ba", count: 25_000)
        #expect(PalindromeOneDeletion.isAlmostPalindrome(mirrored))
    }
}
