// Generated from src/dsa/content/lessons/number-theory/nt-fermat-crt.mdx. Edit the lesson, then run
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

// a·b mod m for 0 ≤ a, b < m, through the full 128-bit product
func mulMod(_ a: Int, _ b: Int, _ m: Int) -> Int {
    m.dividingFullWidth(a.multipliedFullWidth(by: b)).remainder
}

// Combine x ≡ a (mod m) and x ≡ b (mod n), with 0 ≤ a < m and 0 ≤ b < n, into x ≡ value (mod lcm)
func merge(_ a: Int, _ m: Int, _ b: Int, _ n: Int) -> (value: Int, modulus: Int)? {
    let (g, p, _) = extendedGCD(m, n)          // m·p + n·q = g
    let difference = b - a
    guard difference % g == 0 else { return nil }
    let step = n / g                            // x = a + m·t, and t only matters modulo n / g
    let target = ((difference / g) % step + step) % step
    let inverse = ((p % step) + step) % step    // (m / g)·p ≡ 1 (mod n / g)
    let t = mulMod(target, inverse, step)
    return (a + m * t, m / g * n)               // a + m·t < lcm, so this can't overflow
}

print(merge(2, 3, 3, 5)!)
print(merge(8, 15, 2, 7)!)
print(merge(2, 4, 4, 6)!)
print(merge(1, 4, 2, 6) as Any)

let big = merge(5, 1_000_003, 777, 999_999_999_989)!
print(big)
print(big.value % 1_000_003, big.value % 999_999_999_989)
