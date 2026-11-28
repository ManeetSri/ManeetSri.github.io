// Generated from src/dsa/content/lessons/dp-strings/dps-distinct-subsequences.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// How many ways can `word` be picked out of `text` as a subsequence?
func countWays(_ text: String, _ word: String) -> Int {
    let t = Array(text), w = Array(word)
    var ways = Array(repeating: Array(repeating: 0, count: w.count + 1), count: t.count + 1)
    for i in 0...t.count {
        for j in 0...w.count {
            if j == 0 {
                ways[i][j] = 1                                  // the empty word: pick nothing
            } else if i == 0 {
                ways[i][j] = 0                                  // no text left for a non-empty word
            } else {
                ways[i][j] = ways[i - 1][j]                     // skip t[i - 1]
                if t[i - 1] == w[j - 1] {
                    ways[i][j] += ways[i - 1][j - 1]            // or use it for w[j - 1]
                }
            }
        }
    }
    return ways[t.count][w.count]
}

print(countWays("banana", "ban"))
print(countWays("banana", "ana"))
print(countWays("banana", "nab"))
print(countWays("aaaa", "aa"))
print(countWays("swift", ""))
