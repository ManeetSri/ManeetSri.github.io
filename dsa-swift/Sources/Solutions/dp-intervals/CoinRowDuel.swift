// Reference solution: Coin row duel. Minimax on score differences: margin[i][j] is the best (mover's
// total − opponent's total) the player about to move can guarantee on coins i...j. Taking a coin hands
// the rest to the opponent, whose margin counts against you, so
// margin[i][j] = max(coins[i] - margin[i + 1][j], coins[j] - margin[i][j - 1]). Row i only needs
// row i + 1, so one array is enough.
// O(n²) time, O(n) space.

public enum CoinRowDuel {
    public static func bestMargin(_ coins: [Int]) -> Int {
        let n = coins.count
        guard n > 0 else { return 0 }
        var margin = Array(repeating: 0, count: n)          // margin[j] holds row i + 1, then row i
        for i in stride(from: n - 1, through: 0, by: -1) {
            margin[i] = coins[i]
            for j in stride(from: i + 1, to: n, by: 1) {
                // margin[j] is still row i + 1 (range i+1...j); margin[j - 1] is already row i (i...j-1)
                margin[j] = max(coins[i] - margin[j], coins[j] - margin[j - 1])
            }
        }
        return margin[n - 1]
    }
}
