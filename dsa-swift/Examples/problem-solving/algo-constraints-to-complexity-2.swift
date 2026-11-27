// Generated from src/dsa/content/lessons/problem-solving/algo-constraints-to-complexity.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func hasPairWithDifference(_ prices: [Int], _ k: Int) -> Bool {
    let seen = Set(prices)
    for price in prices where seen.contains(price + k) {
        return true
    }
    return false
}

print(hasPairWithDifference([8, 3, 15, 11], 4))
print(hasPairWithDifference([8, 3, 15, 11], 6))
