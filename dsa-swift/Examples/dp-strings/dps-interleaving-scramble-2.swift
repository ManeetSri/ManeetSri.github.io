// Generated from src/dsa/content/lessons/dp-strings/dps-interleaving-scramble.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Can `merged` be formed by interleaving `a` and `b`, keeping each one's own order?
func isInterleaving(_ first: String, _ second: String, _ merged: String) -> Bool {
    let a = Array(first), b = Array(second), c = Array(merged)
    guard a.count + b.count == c.count else { return false }
    // can[i][j]: a's first i letters and b's first j letters can form c's first i + j letters
    var can = Array(repeating: Array(repeating: false, count: b.count + 1), count: a.count + 1)
    for i in 0...a.count {
        for j in 0...b.count {
            if i == 0 && j == 0 {
                can[i][j] = true                                       // nothing from nothing
            } else {
                let fromA = i > 0 && can[i - 1][j] && a[i - 1] == c[i + j - 1]   // last letter came from a
                let fromB = j > 0 && can[i][j - 1] && b[j - 1] == c[i + j - 1]   // or from b
                can[i][j] = fromA || fromB
            }
        }
    }
    return can[a.count][b.count]
}

print(isInterleaving("ab", "ac", "acab"))
print(isInterleaving("ab", "ac", "aabc"))
print(isInterleaving("ab", "ac", "abca"))
print(isInterleaving("ab", "ac", "acba"))
print(isInterleaving("", "", ""))
print(isInterleaving("abc", "", "abc"))
