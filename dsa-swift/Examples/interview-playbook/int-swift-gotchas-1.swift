// Generated from src/dsa/content/lessons/interview-playbook/int-swift-gotchas.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let word = "level"
let letters = Array(word)          // convert once: O(n), then each access is O(1)
var left = 0
var right = letters.count - 1
var isPalindrome = true
while left < right {
    if letters[left] != letters[right] {
        isPalindrome = false
        break
    }
    left += 1
    right -= 1
}
print(letters[0], letters[2], isPalindrome)
print(word[word.index(word.startIndex, offsetBy: 2)])   // fine once, O(n²) inside a loop
