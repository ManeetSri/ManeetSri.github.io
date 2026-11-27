// Generated from src/dsa/content/lessons/dp-strings/dps-distinct-subsequences.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let modulus = 1_000_000_007

/// The number of ways, modulo 1,000,000,007
func countWays(_ text: String, _ word: String) -> Int {
    let w = Array(word)
    var ways = Array(repeating: 0, count: w.count + 1)
    ways[0] = 1
    for letter in text {
        for j in stride(from: w.count, through: 1, by: -1) where w[j - 1] == letter {
            ways[j] = (ways[j] + ways[j - 1]) % modulus     // both are below the modulus, so the sum fits
        }
    }
    return ways[w.count]
}

print(countWays("banana", "ban"))
print(countWays(String(repeating: "a", count: 70), String(repeating: "a", count: 30)))
