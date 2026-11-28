// Reference solution: Token exchange machine. best(n) = max(n, best(n / 2) + best(n / 3) + best(n / 4)),
// with best(0) = 0. The values reach 10^12, so an array memo is impossible, but repeated division only
// reaches numbers of the form n / (2^a · 3^b): a few hundred keys, kept in a dictionary. Each call at
// least halves n, so the recursion is only about 40 levels deep. O(log² n) states.

public enum TokenExchangeMachine {
    public static func mostCoins(token: Int) -> Int {
        var memo: [Int: Int] = [0: 0]

        func best(_ value: Int) -> Int {
            if let known = memo[value] {
                return known
            }
            let exchanged = best(value / 2) + best(value / 3) + best(value / 4)
            let result = max(value, exchanged)
            memo[value] = result
            return result
        }

        return best(token)
    }
}
