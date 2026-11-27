// Reference solution: Stock trades with a cooldown. Three states at the end of each day: hold (own a
// share), sold (sold today, so tomorrow can't be a buy) and rest (own nothing, free to buy). Each
// state's new value is the best over the arrows into it, all read from yesterday:
// hold = max(hold, rest - price), sold = hold + price, rest = max(rest, sold). There's no arrow from
// sold to hold: that's the cooldown. O(n) time, O(1) space.

public enum StockTradesWithCooldown {
    public static func maxProfit(_ prices: [Int]) -> Int {
        var hold = Int.min / 2      // impossible before day 0
        var sold = 0
        var rest = 0
        for price in prices {
            (hold, sold, rest) = (max(hold, rest - price), hold + price, max(rest, sold))
        }
        return max(sold, rest)
    }
}
