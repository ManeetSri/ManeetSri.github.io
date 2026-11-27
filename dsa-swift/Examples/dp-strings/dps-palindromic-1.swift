// Generated from src/dsa/content/lessons/dp-strings/dps-palindromic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func lcsLength(_ a: [Character], _ b: [Character]) -> Int {
    var table = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
    for i in 0...a.count {
        for j in 0...b.count {
            if i == 0 || j == 0 {
                table[i][j] = 0
            } else if a[i - 1] == b[j - 1] {
                table[i][j] = table[i - 1][j - 1] + 1
            } else {
                table[i][j] = max(table[i - 1][j], table[i][j - 1])
            }
        }
    }
    return table[a.count][b.count]
}

for word in ["character", "banana", "racecar", "abcd"] {
    let s = Array(word)
    print(word, lcsLength(s, s.reversed()))
}
