// Reference solution: Ways to make change. The counting unbounded knapsack with the coins as the OUTER
// loop: each coin is fully added before the next, so every combination is built in one fixed order and
// counted once. (Totals outer would count 1 + 2 and 2 + 1 separately.) ways[0] = 1, counts modulo
// 1,000,000,007. O(amount · coins) time, O(amount) space.

public enum ChangeMakingWays {
    public static func count(coins: [Int], amount: Int) -> Int {
        let mod = 1_000_000_007
        var ways = Array(repeating: 0, count: amount + 1)
        ways[0] = 1
        for coin in coins where coin <= amount {
            for total in stride(from: coin, through: amount, by: 1) {
                ways[total] = (ways[total] + ways[total - coin]) % mod
            }
        }
        return ways[amount]
    }
}
