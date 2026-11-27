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

func modInverse(_ a: Int, _ m: Int) -> Int? {
    let (g, x, _) = extendedGCD(((a % m) + m) % m, m)
    return g == 1 ? ((x % m) + m) % m : nil
}

let p = 1_000_000_007
// (12 / 4) mod 5, the example that broke in Modular arithmetic
print(12 % 5 * modInverse(4, 5)! % 5)

// 1 + 2 + … + n = n(n + 1) / 2, modulo p, for n = 10¹⁸
let n = 1_000_000_000_000_000_000
let half = modInverse(2, p)!
print(half)
print(n % p * ((n + 1) % p) % p * half % p)

// Check on a small n where the exact answer fits
let small = 1_000_000
print(small * (small + 1) / 2 % p, small % p * ((small + 1) % p) % p * half % p)
