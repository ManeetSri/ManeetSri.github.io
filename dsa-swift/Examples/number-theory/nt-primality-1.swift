// Generated from src/dsa/content/lessons/number-theory/nt-primality.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func modPow(_ base: Int, _ exponent: Int, _ m: Int) -> Int {
    var result = 1 % m
    var square = base % m
    var e = exponent
    while e > 0 {
        if e % 2 == 1 { result = result * square % m }
        square = square * square % m
        e /= 2
    }
    return result
}
func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? a : gcd(b, a % b) }

// Fermat's test: a prime n gives a^(n-1) mod n = 1 for every base a from 1 to n - 1
print(modPow(2, 340, 341), modPow(3, 340, 341))   // 341 = 11 × 31
let liars = (2..<561).filter { gcd($0, 561) == 1 && modPow($0, 560, 561) == 1 }.count
let coprime = (2..<561).filter { gcd($0, 561) == 1 }.count
print(liars, coprime)                               // 561 = 3 × 11 × 17
