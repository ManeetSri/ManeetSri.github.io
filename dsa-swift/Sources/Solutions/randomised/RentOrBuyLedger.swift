// Reference solution: Rent or buy with changing prices. The replay walks the days with the rent paid so
// far and buys on the first morning that rent plus today's quote reaches the price; hindsight pays the
// smaller of the total rent and the price. For a fixed plan with rent 1 a day, the worst shoot either ends
// the day before buying (only rent) or on the buying day itself (rent plus the price), so compare those
// two ratios and reduce. O(days) for the replay, O(log) for the ratio.

public enum RentOrBuyLedger {
    public static func replay(dailyRents: [Int], buyPrice: Int) -> (online: Int, hindsight: Int, buyDay: Int?) {
        var paid = 0
        var buyDay: Int? = nil
        for (index, rent) in dailyRents.enumerated() {
            if paid + rent >= buyPrice {
                paid += buyPrice
                buyDay = index + 1
                break
            }
            paid += rent
        }
        return (paid, min(dailyRents.reduce(0, +), buyPrice), buyDay)
    }

    public static func worstRatio(buyPrice b: Int, buyDay t: Int) -> (numerator: Int, denominator: Int) {
        var worst = (numerator: 1, denominator: 1)
        if t > 1 {                                 // a shoot of t − 1 days: rent only
            worst = (t - 1, min(t - 1, b))
        }
        let bought = (numerator: t - 1 + b, denominator: min(t, b))   // a shoot of exactly t days
        if bought.numerator * worst.denominator > worst.numerator * bought.denominator {
            worst = bought
        }
        var x = worst.numerator
        var y = worst.denominator
        while y != 0 {
            (x, y) = (y, x % y)
        }
        return (worst.numerator / x, worst.denominator / x)
    }
}
