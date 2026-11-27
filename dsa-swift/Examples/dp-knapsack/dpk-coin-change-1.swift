// Generated from src/dsa/content/lessons/dp-knapsack/dpk-coin-change.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The fewest coins that add up to amount (unlimited coins of each value), or nil if it can't be done
func fewestCoins(_ coins: [Int], _ amount: Int) -> Int? {
    let impossible = amount + 1                          // more coins than any real answer could need
    var fewest = Array(repeating: impossible, count: amount + 1)
    fewest[0] = 0                                        // no coins make 0
    for total in stride(from: 1, through: amount, by: 1) {
        for coin in coins where coin <= total {
            fewest[total] = min(fewest[total], fewest[total - coin] + 1)   // last coin is `coin`
        }
    }
    return fewest[amount] == impossible ? nil : fewest[amount]
}

/// Greedy: the biggest coin that fits, again and again
func greedyCoins(_ coins: [Int], _ amount: Int) -> Int? {
    var left = amount
    var count = 0
    for coin in coins.sorted(by: >) {
        count += left / coin
        left %= coin
    }
    return left == 0 ? count : nil
}

for (coins, amount) in [([1, 3, 4], 6), ([1, 5, 10, 25], 63), ([5, 7], 24), ([4, 6], 9)] {
    print("\(coins) for \(amount): DP \(fewestCoins(coins, amount).map(String.init) ?? "impossible"), greedy \(greedyCoins(coins, amount).map(String.init) ?? "impossible")")
}
