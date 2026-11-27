// Problem: Rent or buy with changing prices (M67 · Online vs offline algorithms)

public enum RentOrBuyLedger {
    /// Replays the break-even rule on a finished shoot: each morning, buy if the rent paid so far plus
    /// today's quote would reach `buyPrice`, otherwise rent. Returns what the rule paid, what hindsight
    /// would have paid, and the day (from 1) it bought, or nil if it never did.
    public static func replay(dailyRents: [Int], buyPrice: Int) -> (online: Int, hindsight: Int, buyDay: Int?) {
        // Write your solution here, then run:
        // swift test --filter RentOrBuyLedgerTests
        return (-1, -1, nil)
    }

    /// With rent 1 a day, a plan that buys on the morning of `buyDay`: the largest ratio of its cost to
    /// hindsight's over every shoot length of at least one day, as a fraction in lowest terms.
    public static func worstRatio(buyPrice: Int, buyDay: Int) -> (numerator: Int, denominator: Int) {
        return (0, 1)
    }
}
