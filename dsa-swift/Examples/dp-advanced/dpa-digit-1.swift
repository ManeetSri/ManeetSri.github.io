// Generated from src/dsa/content/lessons/dp-advanced/dpa-digit.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// How many numbers from 0 to limit have digits adding up to target?
func countDigitSum(upTo limit: Int, target: Int) -> Int {
    let digits = String(limit).compactMap(\.wholeNumberValue)    // 253 → [2, 5, 3]
    // memo[position][sum] for loose states only: the count of ways to finish from there
    var memo = [[Int?]](repeating: [Int?](repeating: nil, count: target + 1), count: digits.count)
    func count(_ position: Int, _ sum: Int, _ tight: Bool) -> Int {
        if sum > target { return 0 }                          // already too big: prune
        if position == digits.count { return sum == target ? 1 : 0 }
        if !tight, let known = memo[position][sum] { return known }
        let highest = tight ? digits[position] : 9            // tight: can't go above limit's digit
        var total = 0
        for digit in 0...highest {
            total += count(position + 1, sum + digit, tight && digit == highest)
        }
        if !tight { memo[position][sum] = total }
        return total
    }
    return count(0, 0, true)
}

func digitSum(_ x: Int) -> Int {
    var x = x, sum = 0
    while x > 0 { sum += x % 10; x /= 10 }
    return sum
}

print(countDigitSum(upTo: 253, target: 7), (0...253).filter { digitSum($0) == 7 }.count)
print(countDigitSum(upTo: 99_999, target: 20), (0...99_999).filter { digitSum($0) == 20 }.count)

// Any range: count up to high, minus count up to low - 1
func countDigitSum(from low: Int, to high: Int, target: Int) -> Int {
    let below = low == 0 ? 0 : countDigitSum(upTo: low - 1, target: target)
    return countDigitSum(upTo: high, target: target) - below
}
print(countDigitSum(from: 100, to: 200, target: 5))
print(countDigitSum(from: 1, to: 1_000_000_000_000_000_000, target: 100))
