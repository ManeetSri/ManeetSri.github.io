// Generated from src/dsa/content/lessons/math-basics/math-digits.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func safeReverse(_ number: Int) -> Int? {
    var n = number
    var reversed = 0
    while n > 0 {
        let shifted = reversed.multipliedReportingOverflow(by: 10)
        if shifted.overflow { return nil }
        let added = shifted.partialValue.addingReportingOverflow(n % 10)
        if added.overflow { return nil }
        reversed = added.partialValue
        n /= 10
    }
    return reversed
}

print(safeReverse(1230) ?? -1)
print(safeReverse(1_999_999_999_999_999_999) ?? -1)
