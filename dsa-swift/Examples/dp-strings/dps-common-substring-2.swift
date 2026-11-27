// Generated from src/dsa/content/lessons/dp-strings/dps-common-substring.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The longest common substring. Among equally long ones, the one that ends first in `first`.
func longestCommonSubstring(_ first: String, _ second: String) -> String {
    let a = Array(first), b = Array(second)
    var table = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
    var bestLength = 0
    var bestEnd = 0                                   // the best run ends just before a[bestEnd]
    for i in 0...a.count {
        for j in 0...b.count {
            if i > 0 && j > 0 && a[i - 1] == b[j - 1] {
                table[i][j] = table[i - 1][j - 1] + 1
                if table[i][j] > bestLength {         // strictly longer: keep the earlier one on ties
                    bestLength = table[i][j]
                    bestEnd = i
                }
            }                                         // otherwise it stays 0
        }
    }
    return String(a[(bestEnd - bestLength)..<bestEnd])
}

print(longestCommonSubstring("photograph", "tomography"))
print(longestCommonSubstring("ABAB", "BABA"))
print(longestCommonSubstring("swift", "shift"))
print(longestCommonSubstring("abc", "xyz").isEmpty)
