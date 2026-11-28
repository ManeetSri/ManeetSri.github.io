// Generated from src/dsa/content/lessons/number-theory/nt-totient-sieves.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? a : gcd(b, a % b) }

// φ(n) by factorising: for each prime p dividing n, multiply by (1 - 1/p)
func phi(_ number: Int) -> Int {
    var n = number
    var result = number
    var p = 2
    while p * p <= n {
        if n % p == 0 {
            while n % p == 0 { n /= p }
            result -= result / p
        }
        p += 1
    }
    if n > 1 { result -= result / n }       // one prime factor above √n is left over
    return result
}

print((1...12).map(phi))
print(phi(36), (1...36).filter { gcd($0, 36) == 1 }.count)
print(phi(1_000_000_007), phi(1_000_000_000_000))
