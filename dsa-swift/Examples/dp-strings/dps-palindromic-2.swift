// Generated from src/dsa/content/lessons/dp-strings/dps-palindromic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// best[i][j]: the longest palindromic subsequence inside s[i...j]
func palindromeTable(_ s: [Character]) -> [[Int]] {
    let n = s.count
    var best = Array(repeating: Array(repeating: 0, count: n), count: n)
    for i in stride(from: n - 1, through: 0, by: -1) {     // i downwards: rows below are ready
        best[i][i] = 1                                       // one letter is a palindrome
        for j in stride(from: i + 1, to: n, by: 1) {
            if s[i] == s[j] {
                best[i][j] = best[i + 1][j - 1] + 2          // wrap the inside in the matching pair
            } else {
                best[i][j] = max(best[i + 1][j], best[i][j - 1])   // drop one end or the other
            }
        }
    }
    return best
}

for word in ["character", "banana", "racecar", "abcd", "a"] {
    let s = Array(word)
    print(word, palindromeTable(s)[0][s.count - 1])
}
let s = Array("banana")
let t = palindromeTable(s)
print("  " + s.map(String.init).joined(separator: " "))
for i in 0..<s.count {
    let cells = (0..<s.count).map { $0 < i ? "." : String(t[i][$0]) }
    print(String(s[i]) + " " + cells.joined(separator: " "))
}
