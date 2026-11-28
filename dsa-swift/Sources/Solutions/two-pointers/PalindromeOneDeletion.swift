// Reference solution: Palindrome after one deletion. Walk inwards from both ends. At the first
// mismatch, the only possible deletions are the left or the right character, so check whether either
// remaining middle part is a palindrome. O(n) time, O(n) space for the array of characters.

public enum PalindromeOneDeletion {
    public static func isAlmostPalindrome(_ text: String) -> Bool {
        let characters = Array(text)

        func isPalindrome(_ low: Int, _ high: Int) -> Bool {
            var left = low
            var right = high
            while left < right {
                if characters[left] != characters[right] {
                    return false
                }
                left += 1
                right -= 1
            }
            return true
        }

        var left = 0
        var right = characters.count - 1
        while left < right {
            if characters[left] != characters[right] {
                return isPalindrome(left + 1, right) || isPalindrome(left, right - 1)
            }
            left += 1
            right -= 1
        }
        return true
    }
}
