// Generated from src/dsa/content/lessons/dp-knapsack/dpk-coin-change.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let coins = [1, 2, 3]
let amount = 4

// Coins outer: each coin is finished before the next starts
var combinations = Array(repeating: 0, count: amount + 1)
combinations[0] = 1
for coin in coins {
    for total in stride(from: coin, through: amount, by: 1) {
        combinations[total] += combinations[total - coin]
    }
    print("after coin \(coin):", combinations)
}

// Amount outer: every coin may be the last one, for every total
var sequences = Array(repeating: 0, count: amount + 1)
sequences[0] = 1
for total in stride(from: 1, through: amount, by: 1) {
    for coin in coins where coin <= total {
        sequences[total] += sequences[total - coin]
    }
}
print("amount outer:", sequences)
