// Generated from src/dsa/content/lessons/dp-strings/dps-interleaving-scramble.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Greedy: take from `a` whenever its next letter fits. Fast, and wrong.
func greedyInterleaving(_ first: String, _ second: String, _ merged: String) -> Bool {
    let a = Array(first), b = Array(second), c = Array(merged)
    guard a.count + b.count == c.count else { return false }
    var i = 0, j = 0
    for letter in c {
        if i < a.count && a[i] == letter {
            i += 1
        } else if j < b.count && b[j] == letter {
            j += 1
        } else {
            return false
        }
    }
    return true
}
print(greedyInterleaving("ab", "ac", "acab"))
