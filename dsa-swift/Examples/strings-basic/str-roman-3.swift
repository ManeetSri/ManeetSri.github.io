// Generated from src/dsa/content/lessons/strings-basic/str-roman.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func greedyCoins(_ amount: Int, coins: [Int]) -> [Int] {
    var remaining = amount
    var used: [Int] = []
    for coin in coins.sorted(by: >) {
        while remaining >= coin {
            used.append(coin)
            remaining -= coin
        }
    }
    return used
}

print(greedyCoins(6, coins: [1, 3, 4]))
print(greedyCoins(6, coins: [1, 2, 5]))
