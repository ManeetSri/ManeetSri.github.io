// Reference solution: Stock trades with a limit. A chain of states, one pair per trade: buy[t] is the
// best profit while holding the share of trade t, and sell[t] the best after finishing t trades.
// buy[t] = max(buy[t], sell[t - 1] - price) and sell[t] = max(sell[t], buy[t] + price). Updating in
// place is safe, because reading a value already updated today only adds same-day buy-and-sell moves,
// which earn nothing. An optimal plan never needs more than n / 2 trades, so for a larger limit, bank
// every rise instead. O(n · min(k, n / 2)) time, O(min(k, n / 2)) space.

public enum StockTradesWithLimit {
    public static func maxProfit(_ prices: [Int], maxTrades: Int) -> Int {
        guard maxTrades > 0, prices.count >= 2 else { return 0 }
        if maxTrades >= prices.count / 2 {
            var profit = 0
            for day in 1..<prices.count {
                profit += max(0, prices[day] - prices[day - 1])
            }
            return profit
        }
        var buy = Array(repeating: Int.min / 2, count: maxTrades + 1)
        var sell = Array(repeating: 0, count: maxTrades + 1)        // sell[0] = 0: no trades yet
        for price in prices {
            for t in 1...maxTrades {
                buy[t] = max(buy[t], sell[t - 1] - price)
                sell[t] = max(sell[t], buy[t] + price)
            }
        }
        return sell[maxTrades]
    }
}
