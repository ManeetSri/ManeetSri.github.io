// Generated from src/dsa/content/lessons/number-theory/nt-extended-euclid.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Iterative extended Euclid. Invariants: oldR = a·oldS + b·oldT and r = a·s + b·t
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

print(extendedGCD(240, 46))
print(extendedGCD(1_000_000_000_000_000_000, 999_999_999_999_999_989))
