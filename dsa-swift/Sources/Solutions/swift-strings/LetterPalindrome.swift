// Reference solution: Letters-only palindrome.
// Keep only the letters, lowercased, in an array, then walk two indices towards the middle.
// O(n) time, O(n) extra space for the array of letters.

public enum LetterPalindrome {
    public static func isPalindrome(_ text: String) -> Bool {
        let letters = Array(text.filter { $0.isLetter }.lowercased())
        var left = 0
        var right = letters.count - 1
        while left < right {
            if letters[left] != letters[right] {
                return false
            }
            left += 1
            right -= 1
        }
        return true
    }
}
