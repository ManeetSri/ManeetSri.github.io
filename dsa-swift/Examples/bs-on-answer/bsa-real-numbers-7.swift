// Generated from src/dsa/content/lessons/bs-on-answer/bsa-real-numbers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// True if baseⁿ > limit, for base ≥ 1, without overflowing.
func power(_ base: Int, _ n: Int, exceeds limit: Int) -> Bool {
    var result = 1
    for _ in 0..<n {
        if result > limit / base { return true }     // result × base would pass limit
        result *= base
    }
    return false
}

/// The largest r with rⁿ ≤ x, for x ≥ 0 and n ≥ 1.
func floorRoot(_ x: Int, _ n: Int) -> Int {
    if n == 1 || x < 2 { return x }
    var low = 1
    var high = x                         // xⁿ > x here, so the first r with rⁿ > x is at most x
    while low < high {
        let mid = low + (high - low) / 2
        if power(mid, n, exceeds: x) {
            high = mid
        } else {
            low = mid + 1
        }
    }
    return low - 1                       // the last r with rⁿ ≤ x
}

for x in [64, 125, 216, 343, 1_000, 999] {
    print(x, floorRoot(x, 3))
}
print(floorRoot(Int.max, 2), floorRoot(Int.max, 3))
