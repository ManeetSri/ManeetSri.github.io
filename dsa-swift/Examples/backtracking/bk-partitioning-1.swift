// Generated from src/dsa/content/lessons/backtracking/bk-partitioning.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isPalindrome(_ letters: [Character], _ from: Int, _ to: Int) -> Bool {
    var left = from
    var right = to
    while left < right {
        if letters[left] != letters[right] { return false }
        left += 1
        right -= 1
    }
    return true
}

func palindromeCuts(_ text: String) -> [[String]] {
    let letters = Array(text)
    var pieces: [String] = []
    var result: [[String]] = []

    func explore(from start: Int) {
        if start == letters.count {                      // every piece was a palindrome
            result.append(pieces)
            return
        }
        for end in start..<letters.count where isPalindrome(letters, start, end) {
            pieces.append(String(letters[start...end]))  // cut after `end`
            explore(from: end + 1)
            pieces.removeLast()                          // undo the cut
        }
    }

    explore(from: 0)
    return result
}

for plan in palindromeCuts("level") {
    print(plan.joined(separator: " | "))
}
print(palindromeCuts("aaaa").count, "plans for aaaa")
