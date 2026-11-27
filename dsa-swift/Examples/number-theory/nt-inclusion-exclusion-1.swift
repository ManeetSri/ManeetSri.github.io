// Generated from src/dsa/content/lessons/number-theory/nt-inclusion-exclusion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// How many of 1…n are divisible by at least one of the primes? One term per non-empty subset.
func divisibleByAny(_ n: Int, _ primes: [Int]) -> Int {
    var total = 0
    for mask in 1..<(1 << primes.count) {
        var product = 1
        for (i, p) in primes.enumerated() where mask & (1 << i) != 0 {
            product *= p
        }
        let sign = mask.nonzeroBitCount % 2 == 1 ? 1 : -1     // odd-sized subsets add, even ones subtract
        total += sign * (n / product)
    }
    return total
}

print(divisibleByAny(100, [2, 3, 5]))
print((1...100).filter { $0 % 2 == 0 || $0 % 3 == 0 || $0 % 5 == 0 }.count)
print(100 - divisibleByAny(100, [2, 3, 5]))
print(divisibleByAny(1_000_000_000_000_000_000, [2, 3, 5]))
