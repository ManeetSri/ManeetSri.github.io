// Reference solution: The first amount greedy change gets wrong. Fill two tables for every amount up
// to the Kozen–Zaks bound: the coins biggest-coin-first uses, and the true fewest (a DP: one coin plus
// the fewest for what's left). If greedy ever fails, it already fails below the sum of the two largest
// coins, so the first mismatch below that is the answer, and no mismatch means greedy is always right.
// With m coins and largest two c and d: O((c + d) · m) time, O(c + d) space.

public enum GreedyChangeBreaker {
    public static func smallestFailure(_ coins: [Int]) -> Int? {
        let sorted = coins.sorted()
        guard sorted.count >= 2 else { return nil }                 // only the 1: always optimal
        let bound = sorted[sorted.count - 1] + sorted[sorted.count - 2]
        var greedy = [0]                                            // greedy[x]: coins biggest-first uses
        var fewest = [0]                                            // fewest[x]: the true minimum
        var largest = 0                                             // index of the biggest coin ≤ amount
        for amount in 1..<bound {
            while largest + 1 < sorted.count && sorted[largest + 1] <= amount { largest += 1 }
            greedy.append(1 + greedy[amount - sorted[largest]])     // take the biggest coin, then greedy again
            var best = Int.max
            for coin in sorted where coin <= amount {
                best = min(best, fewest[amount - coin] + 1)
            }
            fewest.append(best)
            if greedy[amount] > fewest[amount] { return amount }
        }
        return nil
    }
}
