// Generated from src/dsa/content/lessons/problem-solving/algo-pseudocode.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isPalindrome(_ word: String) -> Bool {
    word == String(word.reversed())
}

func longestPalindrome(in words: [String]) -> String? {
    var best: String? = nil
    for word in words where isPalindrome(word) {
        if best == nil || word.count > best!.count {
            best = word
        }
    }
    return best
}

print(longestPalindrome(in: ["kayak", "swift", "racecar", "noon"]) ?? "none")
print(longestPalindrome(in: ["apple", "pear"]) ?? "none")
