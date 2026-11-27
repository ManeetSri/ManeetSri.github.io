// Reference solution: One trade or many. Both answers from the same two-state machine, run side by
// side: at the end of each day you either hold a share or are free. Selling moves hold to free at
// today's price. Buying moves free to hold, and the only difference between the two rules is what a
// buy starts from: zero profit when only one trade is allowed, the profit banked so far when trades
// are unlimited. Every update reads yesterday's values. O(n) time, O(1) space.

public enum StockTradePlans {
    public static func bestProfits(_ prices: [Int]) -> (oneTrade: Int, anyTrades: Int) {
        var holdOnce = Int.min / 2, freeOnce = 0              // holding is impossible before day 0
        var holdMany = Int.min / 2, freeMany = 0
        for price in prices {
            (holdOnce, freeOnce) = (max(holdOnce, 0 - price), max(freeOnce, holdOnce + price))
            (holdMany, freeMany) = (max(holdMany, freeMany - price), max(freeMany, holdMany + price))
        }
        return (freeOnce, freeMany)
    }
}
