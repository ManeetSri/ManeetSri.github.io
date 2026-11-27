// Generated from src/dsa/content/lessons/dp-strings/dps-palindromic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func palindromeTable(_ s: [Character]) -> [[Int]] {
    let n = s.count
    var best = Array(repeating: Array(repeating: 0, count: n), count: n)
    for i in stride(from: n - 1, through: 0, by: -1) {
        best[i][i] = 1
        for j in stride(from: i + 1, to: n, by: 1) {
            if s[i] == s[j] {
                best[i][j] = best[i + 1][j - 1] + 2
            } else {
                best[i][j] = max(best[i + 1][j], best[i][j - 1])
            }
        }
    }
    return best
}

/// Builds a shortest palindrome that contains `word` as a subsequence, from the outside in
func shortestPalindrome(containing word: String) -> String {
    let s = Array(word)
    if s.isEmpty { return "" }
    let best = palindromeTable(s)
    var left: [Character] = []                 // the outer letters, left half
    var middle: [Character] = []
    var i = 0, j = s.count - 1
    while i <= j {
        if i == j {
            middle = [s[i]]                    // a single centre letter
            break
        }
        if s[i] == s[j] {
            left.append(s[i])                  // a matched pair: both ends already agree
            i += 1
            j -= 1
        } else if best[i + 1][j] >= best[i][j - 1] {
            left.append(s[i])                  // s[i] gets a partner inserted on the right
            i += 1
        } else {
            left.append(s[j])                  // s[j] gets a partner inserted on the left
            j -= 1
        }
    }
    return String(left + middle + left.reversed())
}

for word in ["race", "abca", "banana", "swift", "noon"] {
    let s = Array(word)
    let insertions = s.count - palindromeTable(s)[0][s.count - 1]
    print(word, insertions, shortestPalindrome(containing: word))
}
