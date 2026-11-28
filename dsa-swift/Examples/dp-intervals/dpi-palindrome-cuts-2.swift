// Generated from src/dsa/content/lessons/dp-intervals/dpi-palindrome-cuts.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fewestCuts(_ text: String) -> (cuts: Int, pieces: [String]) {
    let s = Array(text)
    let n = s.count
    guard n > 0 else { return (0, []) }
    var isPal = Array(repeating: Array(repeating: false, count: n), count: n)
    for i in stride(from: n - 1, through: 0, by: -1) {
        for j in i..<n {
            isPal[i][j] = s[i] == s[j] && (j - i < 2 || isPal[i + 1][j - 1])
        }
    }

    var cuts = Array(repeating: 0, count: n)       // cuts[j]: fewest cuts for s[0...j]
    var start = Array(repeating: 0, count: n)      // where the best last piece of s[0...j] begins
    for j in 0..<n where !isPal[0][j] {            // a palindromic prefix needs no cuts
        cuts[j] = Int.max
        for i in 1...j where isPal[i][j] && cuts[i - 1] + 1 < cuts[j] {
            cuts[j] = cuts[i - 1] + 1
            start[j] = i
        }
    }

    var pieces: [String] = []
    var end = n - 1
    while end >= 0 {                               // peel off last pieces, right to left
        pieces.append(String(s[start[end]...end]))
        end = start[end] - 1
    }
    return (cuts[n - 1], pieces.reversed())
}

for text in ["noonabbad", "racecarannakayak", "abcbm", "abcd", "level"] {
    print(text, fewestCuts(text))
}
