import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LetterPalindromeTests {
    @Test("Recognises palindromes", arguments: [
        "racecar",
        "Racecar",
        "Never odd or even",
        "Was it a car or a cat I saw?",
        "A man, a plan, a canal: Panama",
        "noon",
    ])
    func palindromes(text: String) {
        #expect(LetterPalindrome.isPalindrome(text))
    }

    @Test("Rejects non-palindromes", arguments: [
        "swift",
        "ab",
        "Palindrome",
        "abca",
    ])
    func notPalindromes(text: String) {
        #expect(!LetterPalindrome.isPalindrome(text))
    }

    @Test("Ignores digits as well as punctuation")
    func ignoresDigits() {
        #expect(LetterPalindrome.isPalindrome("a1b2b3a"))
        #expect(LetterPalindrome.isPalindrome("12 ab 34 ba"))
    }

    @Test("Text with no letters counts as a palindrome")
    func noLetters() {
        #expect(LetterPalindrome.isPalindrome(""))
        #expect(LetterPalindrome.isPalindrome("!!! 42 ..."))
    }

    @Test("A single letter is a palindrome")
    func single() {
        #expect(LetterPalindrome.isPalindrome("x"))
        #expect(LetterPalindrome.isPalindrome(" Q! "))
    }

    @Test("Stays fast on a long string")
    func large() {
        let half = String(repeating: "abc, ", count: 20_000)
        let text = half + "Z" + String(half.reversed())
        #expect(LetterPalindrome.isPalindrome(text))
        #expect(!LetterPalindrome.isPalindrome(text + "q"))
    }
}
