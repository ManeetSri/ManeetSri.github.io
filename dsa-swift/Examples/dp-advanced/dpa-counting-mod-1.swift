// Generated from src/dsa/content/lessons/dp-advanced/dpa-counting-mod.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Ways to roll a running total of exactly n with a six-sided die (order matters): exact, until it overflows
var exact = [1]                                       // one way to total 0: roll nothing
var n = 0
var overflowed = false
while !overflowed {
    n += 1
    var ways = 0
    for face in 1...6 where n - face >= 0 {
        let (sum, overflow) = ways.addingReportingOverflow(exact[n - face])
        if overflow { overflowed = true }
        ways = sum
    }
    exact.append(ways)
}
print("exact counts work up to n =", n - 1, "with", exact[n - 1])

// The same DP modulo 1,000,000,007: reduce after every addition
let mod = 1_000_000_007
var ways = [Int](repeating: 0, count: 1_001)
ways[0] = 1
for total in 1...1_000 {
    for face in 1...6 where total - face >= 0 {
        ways[total] = (ways[total] + ways[total - face]) % mod
    }
}
print("n = 10:", ways[10], exact[10])
print("n = 1000:", ways[1_000])
