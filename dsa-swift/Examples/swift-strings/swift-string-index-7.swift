// Generated from src/dsa/content/lessons/swift-strings/swift-string-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isPalindrome(_ text: String) -> Bool {
    guard !text.isEmpty else { return true }
    var left = text.startIndex
    var right = text.index(before: text.endIndex)
    while left < right {
        if text[left] != text[right] {
            return false
        }
        left = text.index(after: left)
        right = text.index(before: right)
    }
    return true
}

print(isPalindrome("racecar"))
print(isPalindrome("swift"))
print(isPalindrome("abba"))
print(isPalindrome(""))
