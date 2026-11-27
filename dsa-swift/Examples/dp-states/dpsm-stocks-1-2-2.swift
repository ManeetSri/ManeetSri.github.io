// Generated from src/dsa/content/lessons/dp-states/dpsm-stocks-1-2.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func bestManyTrades(_ prices: [Int]) -> Int {
    var profit = 0
    for day in prices.indices.dropFirst() where prices[day] > prices[day - 1] {
        profit += prices[day] - prices[day - 1]      // bank every rise
    }
    return profit
}

print(bestManyTrades([9, 4, 7, 2, 8, 5]))
print(bestManyTrades([1, 2, 3, 4, 5]))
print(bestManyTrades([6, 5, 4]))
print(bestManyTrades([]))
