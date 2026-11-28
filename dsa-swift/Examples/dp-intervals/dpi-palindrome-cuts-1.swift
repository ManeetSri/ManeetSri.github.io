// Generated from src/dsa/content/lessons/dp-intervals/dpi-palindrome-cuts.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func palindromeTable(_ text: String) -> [[Bool]] {
    let s = Array(text)                                  // O(1) access by position
    let n = s.count
    var isPal = Array(repeating: Array(repeating: false, count: n), count: n)
    for i in stride(from: n - 1, through: 0, by: -1) {   // row i + 1 must be ready before row i
        for j in i..<n {
            isPal[i][j] = s[i] == s[j] && (j - i < 2 || isPal[i + 1][j - 1])
        }
    }
    return isPal
}

for row in palindromeTable("abba") {
    print(row.map { $0 ? "T" : "." }.joined(separator: " "))
}
