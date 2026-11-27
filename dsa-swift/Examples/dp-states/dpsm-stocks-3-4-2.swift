// Generated from src/dsa/content/lessons/dp-states/dpsm-stocks-3-4.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func atMostTrades(_ prices: [Int], _ k: Int) -> Int {
    if k == 0 || prices.count < 2 {
        return 0
    }
    if k >= prices.count / 2 {                 // the limit can't bind: bank every rise
        var profit = 0
        for day in 1..<prices.count {
            profit += max(0, prices[day] - prices[day - 1])
        }
        return profit
    }
    var buy = Array(repeating: Int.min / 2, count: k + 1)   // buy[t]: holding, during trade t
    var sell = Array(repeating: 0, count: k + 1)            // sell[t]: free, after t trades
    for price in prices {
        for t in 1...k {
            buy[t] = max(buy[t], sell[t - 1] - price)       // start trade t, funded by t - 1 trades
            sell[t] = max(sell[t], buy[t] + price)          // finish trade t
        }
    }
    return sell[k]
}

let prices = [2, 6, 3, 1, 5, 4, 8, 2]
for k in 0...4 {
    print("at most \(k):", atMostTrades(prices, k))
}
