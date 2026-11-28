// Generated from src/dsa/content/lessons/dp-knapsack/dpk-coin-change.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let coins = [1, 5, 6, 9]
let amount = 11

let impossible = amount + 1
var fewest = Array(repeating: impossible, count: amount + 1)
var lastCoin = Array(repeating: 0, count: amount + 1)    // the coin that achieved fewest[total]
fewest[0] = 0
for total in stride(from: 1, through: amount, by: 1) {
    for coin in coins where coin <= total && fewest[total - coin] + 1 < fewest[total] {
        fewest[total] = fewest[total - coin] + 1
        lastCoin[total] = coin
    }
}

var used: [Int] = []
var left = amount
while left > 0 {
    used.append(lastCoin[left])
    left -= lastCoin[left]
}
print("fewest:", fewest)
print("\(amount) = " + used.map(String.init).joined(separator: " + "))
