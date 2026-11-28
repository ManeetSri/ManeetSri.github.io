// Generated from src/dsa/content/lessons/dp-intervals/dpi-strange-printer.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fewestTurns(_ text: String) -> Int {
    var s: [Character] = []
    for letter in text where s.last != letter {
        s.append(letter)                                         // collapse runs: "aaabbb" → "ab"
    }
    let n = s.count
    if n == 0 { return 0 }
    var turns = Array(repeating: Array(repeating: 0, count: n), count: n)
    for i in stride(from: n - 1, through: 0, by: -1) {
        turns[i][i] = 1
        for j in stride(from: i + 1, to: n, by: 1) {
            turns[i][j] = 1 + turns[i + 1][j]                    // s[i] gets a turn of its own
            for k in stride(from: i + 1, through: j, by: 1) where s[k] == s[i] {
                let between = k - 1 >= i + 1 ? turns[i + 1][k - 1] : 0
                turns[i][j] = min(turns[i][j], between + turns[k][j])   // s[i] rides along with s[k]
            }
        }
    }
    return turns[0][n - 1]
}

for target in ["abcba", "aaabbb", "abab", "abcabc", "banana", "xyzzyx", ""] {
    print("\"\(target)\":", fewestTurns(target))
}
