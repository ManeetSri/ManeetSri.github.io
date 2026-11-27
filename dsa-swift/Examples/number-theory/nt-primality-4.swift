// Generated from src/dsa/content/lessons/number-theory/nt-primality.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// a·b mod m without overflow: the exact 128-bit product, then a 128-by-64-bit division
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

// Deterministic Miller–Rabin for every 64-bit n
func isPrime(_ n: UInt64) -> Bool {
    let bases: [UInt64] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    if n < 2 { return false }
    for p in bases where n % p == 0 {
        return n == p                 // n is one of the bases, or has it as a factor
    }
    var d = n - 1
    var s = 0
    while d & 1 == 0 {
        d >>= 1
        s += 1
    }
    witnessLoop: for a in bases {
        var x = powMod(a, d, n)
        if x == 1 || x == n - 1 { continue }
        for _ in 1..<s {              // n is odd here, so s is at least 1
            x = mulMod(x, x, n)
            if x == n - 1 { continue witnessLoop }
        }
        return false                  // a proves n composite
    }
    return true
}

let tests: [UInt64] = [561, 2047, 1_000_000_007, 3_215_031_751, 2_305_843_009_213_693_951,
                       3_825_123_056_546_413_051, 18_446_744_073_709_551_557, 18_446_744_030_759_878_681]
for n in tests {
    print(n, isPrime(n))
}
print((0..<100_000).filter { isPrime(UInt64($0)) }.count)
