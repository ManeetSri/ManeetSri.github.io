// Generated from src/dsa/content/lessons/two-pointers/tp-opposite-ends.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isPalindrome(_ text: String) -> Bool {
    let characters = Array(text)
    var left = 0
    var right = characters.count - 1
    while left < right {
        let a = characters[left]
        let b = characters[right]
        if !(a.isLetter || a.isNumber) {
            left += 1                      // skip it, and look again
        } else if !(b.isLetter || b.isNumber) {
            right -= 1
        } else if a.lowercased() != b.lowercased() {
            return false
        } else {
            left += 1
            right -= 1
        }
    }
    return true
}

for text in ["Step on no pets!", "Was it a rat I saw?", "No lemon, no melon", "Swift", "", "1a2"] {
    print("\"\(text)\":", isPalindrome(text))
}
