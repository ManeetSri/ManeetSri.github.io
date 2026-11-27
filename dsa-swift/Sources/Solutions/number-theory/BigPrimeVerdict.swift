// Reference solution: Is this 64-bit number prime? Deterministic Miller–Rabin. Write n − 1 = d · 2^s with
// d odd. For each base a, compute x = a^d mod n; n passes for that base if x is 1, or if x becomes n − 1
// within s − 1 squarings. A prime passes every base, and testing the twelve primes 2…37 as bases is
// known to catch every composite below 2⁶⁴. Every product of two values below n is formed with
// multipliedFullWidth and reduced with dividingFullWidth, so nothing overflows even for n near 2⁶⁴.
// O(k log n) multiplications for k = 12 bases, O(1) space.

public enum BigPrimeVerdict {
    private static let bases: [UInt64] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]

    public static func isPrime(_ n: UInt64) -> Bool {
        if n < 2 { return false }
        for p in bases where n % p == 0 {
            return n == p                               // n is a base itself, or has one as a factor
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
            for _ in 1..<s {                            // n is odd here, so s ≥ 1
                x = mulMod(x, x, n)
                if x == n - 1 { continue witnessLoop }
            }
            return false                                // a is a witness: n is composite
        }
        return true
    }

    /// a·b mod m for a, b < m: the exact 128-bit product, then a 128-by-64-bit division.
    private static func mulMod(_ a: UInt64, _ b: UInt64, _ m: UInt64) -> UInt64 {
        m.dividingFullWidth(a.multipliedFullWidth(by: b)).remainder
    }

    private static func powMod(_ base: UInt64, _ exponent: UInt64, _ m: UInt64) -> UInt64 {
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
}
