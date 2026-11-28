// Generated from src/dsa/content/lessons/number-theory/nt-primality.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func mulMod(_ a: UInt64, _ b: UInt64, _ m: UInt64) -> UInt64 {
    m.dividingFullWidth(a.multipliedFullWidth(by: b)).remainder
}

func powMod(_ base: UInt64, _ exponent: UInt64, _ m: UInt64) -> UInt64 {
    var result: UInt64 = 1
    var square = base % m
    var e = exponent
    while e > 0 {
        if e & 1 == 1 { result = mulMod(result, square, m) }
        square = mulMod(square, square, m)
        e >>= 1
    }
    return result
}

// Does base a fail to prove odd n composite? (n is a strong probable prime to base a)
func passes(_ n: UInt64, base a: UInt64) -> Bool {
    var d = n - 1
    var s = 0
    while d & 1 == 0 { d >>= 1; s += 1 }
    var x = powMod(a, d, n)
    if x == 1 || x == n - 1 { return true }
    for _ in 1..<s {
        x = mulMod(x, x, n)
        if x == n - 1 { return true }
    }
    return false
}

let tricky: UInt64 = 3_825_123_056_546_413_051
let bases: [UInt64] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
print(bases.map { passes(tricky, base: $0) })
print(tricky % 149_491, tricky / 149_491)
