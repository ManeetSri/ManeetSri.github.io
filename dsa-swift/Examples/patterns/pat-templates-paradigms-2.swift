// Generated from src/dsa/content/lessons/patterns/pat-templates-paradigms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Greedy that works: the fewest boats, each holding at most two people and at most `limit` kilograms
func fewestBoats(_ weights: [Int], limit: Int) -> Int {
    let sorted = weights.sorted()
    var light = 0
    var heavy = sorted.count - 1
    var boats = 0
    while light <= heavy {
        if sorted[light] + sorted[heavy] <= limit {
            light += 1                            // the lightest can share with the heaviest
        }
        heavy -= 1                                // the heaviest always leaves now
        boats += 1
    }
    return boats
}

// Greedy that fails: always take the biggest coin that fits
func greedyCoins(_ coins: [Int], _ amount: Int) -> Int? {
    var left = amount
    var count = 0
    for coin in coins.sorted(by: >) {
        count += left / coin
        left %= coin
    }
    return left == 0 ? count : nil
}

// The DP that's always right: fewest[a] is the fewest coins making a
func dpCoins(_ coins: [Int], _ amount: Int) -> Int? {
    var fewest = Array(repeating: Int.max, count: amount + 1)
    fewest[0] = 0
    if amount > 0 {
        for a in 1...amount {
            for coin in coins where coin <= a && fewest[a - coin] != Int.max {
                fewest[a] = min(fewest[a], fewest[a - coin] + 1)
            }
        }
    }
    return fewest[amount] == Int.max ? nil : fewest[amount]
}

print(fewestBoats([3, 5, 3, 4, 2, 1], limit: 5))

// Test the greedy rule against the DP on every small amount before trusting it
let coins = [1, 3, 4]
let broken = (1...12).filter { greedyCoins(coins, $0) != dpCoins(coins, $0) }
print("greedy is wrong for:", broken)
print("6:", greedyCoins(coins, 6)!, "coins by greedy,", dpCoins(coins, 6)!, "by DP")
