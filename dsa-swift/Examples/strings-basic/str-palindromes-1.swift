// Generated from src/dsa/content/lessons/strings-basic/str-palindromes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isPalindrome(_ text: String) -> Bool {
    let chars = Array(text)
    var left = 0
    var right = chars.count - 1
    while left < right {
        if chars[left] != chars[right] {
            return false
        }
        left += 1
        right -= 1
    }
    return true
}

print(isPalindrome("racecar"), isPalindrome("abba"), isPalindrome("abca"), isPalindrome(""))
