// Generated from src/dsa/content/lessons/number-theory/nt-fft.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mod = 998_244_353

func power(_ base: Int, _ exponent: Int) -> Int {
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

func ntt(_ a: inout [Int], invert: Bool) {
    let n = a.count
    var j = 0
    for i in 1..<n {
        var bit = n >> 1
        while j & bit != 0 {
            j ^= bit
            bit >>= 1
        }
        j ^= bit
        if i < j { a.swapAt(i, j) }
    }
    var length = 2
    while length <= n {
        var root = power(3, (mod - 1) / length)
        if invert { root = power(root, mod - 2) }
        let half = length / 2
        for start in stride(from: 0, to: n, by: length) {
            var x = 1
            for k in 0..<half {
                let u = a[start + k]
                let v = a[start + k + half] * x % mod
                a[start + k] = u + v < mod ? u + v : u + v - mod
                a[start + k + half] = u - v >= 0 ? u - v : u - v + mod
                x = x * root % mod
            }
        }
        length <<= 1
    }
    if invert {
        let nInverse = power(n, mod - 2)
        for i in 0..<n { a[i] = a[i] * nInverse % mod }
    }
}

func multiply(_ a: [Int], _ b: [Int]) -> [Int] {
    let resultSize = a.count + b.count - 1
    var n = 1
    while n < resultSize { n <<= 1 }
    var fa = a + Array(repeating: 0, count: n - a.count)
    var fb = b + Array(repeating: 0, count: n - b.count)
    ntt(&fa, invert: false)
    ntt(&fb, invert: false)
    for i in 0..<n { fa[i] = fa[i] * fb[i] % mod }
    ntt(&fa, invert: true)
    return Array(fa[0..<resultSize])
}

// Big numbers: digits are coefficients, lowest first. Convolve, then carry.
func multiplyNumbers(_ x: String, _ y: String) -> String {
    let a = x.reversed().map { Int(String($0))! }
    let b = y.reversed().map { Int(String($0))! }
    var digits = multiply(a, b)          // each entry can be far above 9 before carrying
    var carry = 0
    for i in digits.indices {
        let value = digits[i] + carry
        digits[i] = value % 10
        carry = value / 10
    }
    while carry > 0 {
        digits.append(carry % 10)
        carry /= 10
    }
    while digits.count > 1 && digits.last == 0 { digits.removeLast() }
    return digits.reversed().map(String.init).joined()
}

print(multiplyNumbers("123", "45"))
print(multiplyNumbers("123456789", "987654321"), 123_456_789 * 987_654_321)
print(multiplyNumbers("18446744073709551616", "18446744073709551616"))
let nines = String(repeating: "9", count: 30)
print(multiplyNumbers(nines, nines))
print(multiplyNumbers("0", "12345"))
