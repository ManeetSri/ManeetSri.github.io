// Generated from src/dsa/content/lessons/dp-strings/dps-lcs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func lcsTable(_ a: [Character], _ b: [Character]) -> [[Int]] {
    let n = a.count, m = b.count
    var table = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
    for i in 0...n {
        for j in 0...m {
            if i == 0 || j == 0 {
                table[i][j] = 0
            } else if a[i - 1] == b[j - 1] {
                table[i][j] = table[i - 1][j - 1] + 1
            } else {
                table[i][j] = max(table[i - 1][j], table[i][j - 1])
            }
        }
    }
    return table
}

/// Walks back from the bottom-right corner, collecting matched letters. On a tie between up and
/// left, `preferUp` decides which way to go.
func longestCommonSubsequence(_ first: String, _ second: String, preferUp: Bool = true) -> String {
    let a = Array(first), b = Array(second)
    let table = lcsTable(a, b)
    var letters: [Character] = []
    var i = a.count, j = b.count
    while i > 0 && j > 0 {
        if a[i - 1] == b[j - 1] {
            letters.append(a[i - 1])            // this pair is part of the LCS
            i -= 1
            j -= 1
        } else if table[i - 1][j] > table[i][j - 1] || (table[i - 1][j] == table[i][j - 1] && preferUp) {
            i -= 1                              // the value came from above: a[i - 1] isn't used
        } else {
            j -= 1                              // it came from the left: b[j - 1] isn't used
        }
    }
    return String(letters.reversed())           // collected back to front
}

print(longestCommonSubsequence("ABCBDAB", "BDCABA"))
print(longestCommonSubsequence("ABCBDAB", "BDCABA", preferUp: false))
print(longestCommonSubsequence("SWIFTLY", "SHIFTILY"))
print(longestCommonSubsequence("kitten", "sitting"))
print(longestCommonSubsequence("abc", "xyz").isEmpty)
