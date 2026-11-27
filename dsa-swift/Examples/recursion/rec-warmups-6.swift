// Generated from src/dsa/content/lessons/recursion/rec-warmups.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isPalindrome(_ text: String) -> Bool {
    let chars = Array(text)

    func check(_ low: Int, _ high: Int) -> Bool {
        if low >= high {
            return true
        }
        if chars[low] != chars[high] {
            return false
        }
        return check(low + 1, high - 1)
    }

    return check(0, chars.count - 1)
}

for word in ["racecar", "level", "swift", "abca", "", "Noon"] {
    print("\"\(word)\"", isPalindrome(word))
}
