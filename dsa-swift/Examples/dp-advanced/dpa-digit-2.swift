// Generated from src/dsa/content/lessons/dp-advanced/dpa-digit.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// How many numbers from 1 to limit have no repeated digit?
func countDistinctDigits(upTo limit: Int) -> Int {
    let digits = String(limit).compactMap(\.wholeNumberValue)
    // memo[position][used]: loose and started states only. used is a bitmask of the digits so far.
    var memo = [[Int]](repeating: [Int](repeating: -1, count: 1 << 10), count: digits.count)
    func count(_ position: Int, _ used: Int, _ tight: Bool, _ started: Bool) -> Int {
        if position == digits.count { return started ? 1 : 0 }   // the all-zeros "number" isn't counted
        if !tight && started && memo[position][used] >= 0 { return memo[position][used] }
        let highest = tight ? digits[position] : 9
        var total = 0
        for digit in 0...highest {
            let nextTight = tight && digit == highest
            if !started && digit == 0 {
                total += count(position + 1, used, nextTight, false)   // still a leading zero: uses nothing
            } else if used & (1 << digit) == 0 {
                total += count(position + 1, used | (1 << digit), nextTight, true)
            }
        }
        if !tight && started { memo[position][used] = total }
        return total
    }
    return count(0, 0, true, false)
}

func hasDistinctDigits(_ x: Int) -> Bool {
    var x = x, seen = 0
    while x > 0 {
        if seen & (1 << (x % 10)) != 0 { return false }
        seen |= 1 << (x % 10)
        x /= 10
    }
    return true
}

print(countDistinctDigits(upTo: 100), (1...100).filter(hasDistinctDigits).count)
print(countDistinctDigits(upTo: 54_321), (1...54_321).filter(hasDistinctDigits).count)
print(countDistinctDigits(upTo: 9_999_999_999))
