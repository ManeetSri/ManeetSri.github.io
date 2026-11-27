// Generated from src/dsa/content/lessons/greedy/greedy-counterexamples.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func greedyCoins(_ amount: Int, _ coins: [Int]) -> Int {
    var left = amount
    var count = 0
    for coin in coins.sorted(by: >) {
        count += left / coin            // as many of this coin as fit
        left %= coin
    }
    return count                        // every system here has a 1, so left ends at 0
}

// best[t] = the fewest coins that make t exactly
func fewestCoins(_ amount: Int, _ coins: [Int]) -> Int {
    var best = [0] + Array(repeating: Int.max, count: amount)
    for total in stride(from: 1, through: amount, by: 1) {
        for coin in coins where coin <= total && best[total - coin] != Int.max {
            best[total] = min(best[total], best[total - coin] + 1)
        }
    }
    return best[amount]
}

for amount in 1...12 where greedyCoins(amount, [1, 3, 4]) != fewestCoins(amount, [1, 3, 4]) {
    print("\(amount): greedy uses \(greedyCoins(amount, [1, 3, 4])), the best is \(fewestCoins(amount, [1, 3, 4]))")
}

// British coins before 1971, in pence: 3d, 6d, the shilling (12d), the florin (24d) and the half crown (30d)
let oldPence = [1, 3, 6, 12, 24, 30]
print("48d: greedy uses \(greedyCoins(48, oldPence)), the best is \(fewestCoins(48, oldPence))")
