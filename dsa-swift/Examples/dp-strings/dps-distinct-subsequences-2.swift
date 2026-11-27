// Generated from src/dsa/content/lessons/dp-strings/dps-distinct-subsequences.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countWays(_ text: String, _ word: String) -> Int {
    let w = Array(word)
    var ways = Array(repeating: 0, count: w.count + 1)
    ways[0] = 1                                         // the empty word, in every row
    for letter in text {
        for j in stride(from: w.count, through: 1, by: -1) where w[j - 1] == letter {
            ways[j] += ways[j - 1]                      // using this letter as w[j - 1]
        }
    }
    return ways[w.count]
}

print(countWays("banana", "ban"), countWays("aaaa", "aa"))
