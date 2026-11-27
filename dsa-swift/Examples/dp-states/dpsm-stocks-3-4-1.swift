// Generated from src/dsa/content/lessons/dp-states/dpsm-stocks-3-4.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func atMostTwoTrades(_ prices: [Int]) -> Int {
    var buy1 = Int.min / 2, sell1 = 0      // during and after the first trade
    var buy2 = Int.min / 2, sell2 = 0      // during and after the second
    for price in prices {
        buy1 = max(buy1, -price)            // first buy, from no profit
        sell1 = max(sell1, buy1 + price)    // first sell
        buy2 = max(buy2, sell1 - price)     // second buy, carrying the first trade's profit
        sell2 = max(sell2, buy2 + price)    // second sell
    }
    return sell2
}

print(atMostTwoTrades([2, 6, 3, 1, 5, 4, 8, 2]))
print(atMostTwoTrades([1, 2, 3, 4, 5]))
print(atMostTwoTrades([5, 4, 3]))
