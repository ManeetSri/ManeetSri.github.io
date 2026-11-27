// Reference solution: Counting numbers by digit sum. Digit DP: count(low...high) = upTo(high) minus
// upTo(low - 1), where upTo(limit) counts 0...limit. Walk along limit's digits, staying tight (equal to
// limit so far). At each position, choosing a smaller digit than limit's makes every later digit free,
// and free[r][s], the number of ways r free digits can add up to s, finishes the count in one lookup.
// The tight path itself is one number: limit, counted at the end if its own digit sum matches.
// O(D · S · 10) for the table and O(D · 10) for the walk, with D ≤ 19 digits and S the target sum.

public enum RangeDigitSumCount {
    public static func count(from low: Int, to high: Int, digitSum: Int) -> Int {
        let below = low == 0 ? 0 : upTo(low - 1, digitSum)
        return upTo(high, digitSum) - below
    }

    /// How many numbers in 0...limit have digit sum `target`
    private static func upTo(_ limit: Int, _ target: Int) -> Int {
        let digits = String(limit).compactMap(\.wholeNumberValue)
        let length = digits.count
        // free[r][s]: ways to choose r digits, each 0–9, adding up to s
        var free = [[Int]](repeating: [Int](repeating: 0, count: target + 1), count: length + 1)
        free[0][0] = 1
        for r in 1...length {
            for s in 0...target {
                for digit in 0...min(9, s) {
                    free[r][s] += free[r - 1][s - digit]
                }
            }
        }

        var total = 0
        var used = 0                                   // digit sum of the tight prefix so far
        for (position, limitDigit) in digits.enumerated() {
            for smaller in 0..<limitDigit where used + smaller <= target {
                total += free[length - position - 1][target - used - smaller]
            }
            used += limitDigit
            if used > target { return total }          // the tight path can't come back down
        }
        return used == target ? total + 1 : total      // limit itself
    }
}
