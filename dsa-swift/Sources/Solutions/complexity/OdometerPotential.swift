// Reference solution: The odometer's potential. Aggregate: digit k changes ⌊n / bᵏ⌋ times, O(log n).
// Potential: simulate with digits stored least significant first, keeping Φ (the number of b − 1
// digits) up to date; every amortised cost comes out as 1 or 2. O(n) amortised.

public enum OdometerPotential {
    public static func totalChanges(increments n: Int, base b: Int) -> Int {
        var total = 0
        var changes = n                   // ⌊n / bᵏ⌋, starting with k = 0
        while changes > 0 {
            total += changes
            changes /= b
        }
        return total
    }

    public static func amortisedCosts(increments n: Int, base b: Int) -> [Int] {
        var digits = [0]
        var potential = 0
        var costs: [Int] = []
        costs.reserveCapacity(n)
        for _ in 0..<n {
            let before = potential
            var actual = 0
            var position = 0
            while position < digits.count && digits[position] == b - 1 {
                digits[position] = 0      // a b − 1 rolls over: one change, one less in Φ
                potential -= 1
                actual += 1
                position += 1
            }
            if position == digits.count {
                digits.append(1)          // a new leading digit
            } else {
                digits[position] += 1
            }
            if digits[position] == b - 1 {
                potential += 1
            }
            actual += 1
            costs.append(actual + potential - before)
        }
        return costs
    }
}
