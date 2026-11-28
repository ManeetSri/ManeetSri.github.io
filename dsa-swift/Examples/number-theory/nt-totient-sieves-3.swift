// Generated from src/dsa/content/lessons/number-theory/nt-totient-sieves.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// ⌊√n⌋: start from the floating-point estimate, then correct it in whole numbers
func integerSquareRoot(_ n: Int) -> Int {
    var r = Int(Double(n).squareRoot())
    while r * r > n { r -= 1 }
    while (r + 1) * (r + 1) <= n { r += 1 }
    return r
}

// The ordinary sieve, for the base primes
func primes(upTo n: Int) -> [Int] {
    guard n >= 2 else { return [] }
    var isPrime = Array(repeating: true, count: n + 1)
    isPrime[0] = false
    isPrime[1] = false
    var p = 2
    while p * p <= n {
        if isPrime[p] {
            for m in stride(from: p * p, through: n, by: p) { isPrime[m] = false }
        }
        p += 1
    }
    return isPrime.indices.filter { isPrime[$0] }
}

// Primes in [low, high]: cross out multiples of each base prime inside the window only
func primesInWindow(_ low: Int, _ high: Int) -> [Int] {
    var isPrime = Array(repeating: true, count: high - low + 1)
    for p in primes(upTo: integerSquareRoot(high)) {
        let first = max(p * p, (low + p - 1) / p * p)   // never cross out p itself
        for m in stride(from: first, through: high, by: p) {
            isPrime[m - low] = false
        }
    }
    if low == 1 { isPrime[0] = false }                  // 1 isn't prime
    return isPrime.indices.filter { isPrime[$0] }.map { $0 + low }
}

print(primesInWindow(1, 30))
print(primesInWindow(100, 130))
let trillion = 1_000_000_000_000
print(primesInWindow(trillion, trillion + 100))
print(primesInWindow(trillion, trillion + 1_000_000).count)
