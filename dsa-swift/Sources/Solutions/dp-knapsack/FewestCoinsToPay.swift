// Reference solution: Fewest coins to pay. fewest[t] is the fewest coins making exactly t:
// fewest[0] = 0, and fewest[t] = 1 + the smallest fewest[t - c] over the coins c ≤ t. "Impossible" is
// amount + 1, which no answer can reach and which leaves room to add 1 without overflow.
// O(amount · coins) time, O(amount) space.

public enum FewestCoinsToPay {
    public static func fewest(coins: [Int], amount: Int) -> Int {
        let impossible = amount + 1
        var fewest = Array(repeating: impossible, count: amount + 1)
        fewest[0] = 0
        for total in stride(from: 1, through: amount, by: 1) {
            for coin in coins where coin <= total {
                fewest[total] = min(fewest[total], fewest[total - coin] + 1)
            }
        }
        return fewest[amount] == impossible ? -1 : fewest[amount]
    }
}
