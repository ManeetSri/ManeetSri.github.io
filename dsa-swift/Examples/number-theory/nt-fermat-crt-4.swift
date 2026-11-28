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

func modInverse(_ a: Int, _ m: Int) -> Int? {
    let (g, x, _) = extendedGCD(((a % m) + m) % m, m)
    return g == 1 ? ((x % m) + m) % m : nil
}

// The constructive formula, for pairwise coprime moduli whose product is small
func crt(_ remainders: [Int], _ moduli: [Int]) -> Int {
    let total = moduli.reduce(1, *)
    var x = 0
    for (r, m) in zip(remainders, moduli) {
        let rest = total / m                      // the product of the other moduli
        let inverse = modInverse(rest, m)!        // exists because they're coprime
        x = (x + r * rest % total * inverse) % total
        print("m = \(m): rest = \(rest), inverse = \(inverse), term = \(r * rest * inverse)")
    }
    return x
}

print(crt([2, 3, 2], [3, 5, 7]))
