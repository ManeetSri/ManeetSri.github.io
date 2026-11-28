// Generated from src/dsa/content/lessons/string-algorithms/sa-rabin-karp.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Windows of 4 digits as numbers: drop the leading digit, shift, add the new one
let digits = "31415926".map { $0.wholeNumberValue! }
let m = 4
var window = 0
for k in 0..<m {
    window = window * 10 + digits[k]
}
print(window)
let high = 1_000                                    // 10^(m - 1): the place value of the leading digit
for i in m..<digits.count {
    window = (window - digits[i - m] * high) * 10 + digits[i]
    print(window)
}
