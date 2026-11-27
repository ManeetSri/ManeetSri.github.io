// Generated from src/dsa/content/lessons/number-theory/nt-extended-euclid.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func extendedGCD(_ a: Int, _ b: Int) -> (g: Int, x: Int, y: Int) {
    var (oldR, r) = (a, b)
    var (oldS, s) = (1, 0)
    var (oldT, t) = (0, 1)
    while r != 0 {
        let q = oldR / r
        (oldR, r) = (r, oldR - q * r)
        (oldS, s) = (s, oldS - q * s)
        (oldT, t) = (t, oldT - q * t)
    }
    return (oldR, oldS, oldT)
}

// The inverse of a modulo m, or nil when gcd(a, m) isn't 1
func modInverse(_ a: Int, _ m: Int) -> Int? {
    let reduced = ((a % m) + m) % m
    let (g, x, _) = extendedGCD(reduced, m)
    guard g == 1 else { return nil }
    return ((x % m) + m) % m
}

print(modInverse(3, 11) as Any, modInverse(6, 9) as Any, modInverse(-3, 11) as Any)
print((1..<7).map { modInverse($0, 7)! })
let big = 1_000_000_007
let inverse = modInverse(123_456_789, big)!
print(inverse, 123_456_789 * inverse % big)
print(modInverse(5, 1) as Any)
