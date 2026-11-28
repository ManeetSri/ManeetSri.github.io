// Reference solution: Multiply two huge numbers. Read each number's digits, lowest first, as the
// coefficients of a polynomial: the product's digits, before carrying, are the convolution of the two.
// Compute the convolution with the number-theoretic transform modulo 998,244,353 = 119 · 2²³ + 1, whose
// primitive root 3 gives roots of unity of every power-of-two order up to 2²³. Each true coefficient is
// at most 9 · 9 · 100,000, far below the prime, so the results are exact. Then carry from the lowest
// digit up and strip leading zeros. O((a + b) log(a + b)) time, O(a + b) space.

public enum DigitStringProduct {
    private static let mod = 998_244_353

    public static func multiply(_ a: String, _ b: String) -> String {
        let x = a.utf8.reversed().map { Int($0) - 48 }      // "0" is UTF-8 byte 48
        let y = b.utf8.reversed().map { Int($0) - 48 }
        let size = x.count + y.count - 1
        var n = 1
        while n < size { n <<= 1 }
        var fx = x + Array(repeating: 0, count: n - x.count)
        var fy = y + Array(repeating: 0, count: n - y.count)
        transform(&fx, invert: false)
        transform(&fy, invert: false)
        for i in 0..<n { fx[i] = fx[i] * fy[i] % mod }
        transform(&fx, invert: true)

        var digits: [UInt8] = []                             // lowest first
        digits.reserveCapacity(size + 1)
        var carry = 0
        for i in 0..<size {
            let value = fx[i] + carry
            digits.append(UInt8(value % 10) + 48)
            carry = value / 10
        }
        while carry > 0 {
            digits.append(UInt8(carry % 10) + 48)
            carry /= 10
        }
        while digits.count > 1 && digits.last == 48 { digits.removeLast() }   // a zero factor
        return String(decoding: digits.reversed(), as: UTF8.self)
    }

    /// In-place iterative NTT. a.count must be a power of two, at most 2²³. The loops are `while` loops and
    /// each level's powers of the root are computed once into a table: in a debug build, which is what
    /// `swift test` makes, that's several times faster than `for … in stride` and a running product.
    private static func transform(_ a: inout [Int], invert: Bool) {
        let n = a.count
        var j = 0
        var i = 1
        while i < n {                                        // bit-reversal permutation
            var bit = n >> 1
            while j & bit != 0 {
                j ^= bit
                bit >>= 1
            }
            j ^= bit
            if i < j { a.swapAt(i, j) }
            i += 1
        }
        var twiddles = Array(repeating: 1, count: max(n / 2, 1))
        var length = 2
        while length <= n {
            var root = power(3, (mod - 1) / length)          // a root of unity of order `length`
            if invert { root = power(root, mod - 2) }
            let half = length / 2
            for k in stride(from: 1, to: half, by: 1) {
                twiddles[k] = twiddles[k - 1] * root % mod
            }
            var start = 0
            while start < n {
                var k = 0
                while k < half {
                    let u = a[start + k]
                    let v = a[start + k + half] * twiddles[k] % mod
                    let sum = u + v
                    a[start + k] = sum < mod ? sum : sum - mod
                    let difference = u - v
                    a[start + k + half] = difference >= 0 ? difference : difference + mod
                    k += 1
                }
                start += length
            }
            length <<= 1
        }
        if invert {
            let nInverse = power(n, mod - 2)
            for i in 0..<n { a[i] = a[i] * nInverse % mod }
        }
    }

    private static func power(_ base: Int, _ exponent: Int) -> Int {
        var result = 1
        var square = base % mod
        var e = exponent
        while e > 0 {
            if e & 1 == 1 { result = result * square % mod }
            square = square * square % mod
            e >>= 1
        }
        return result
    }
}
