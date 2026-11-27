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

// In-place iterative NTT. a.count must be a power of two, at most 2²³.
func ntt(_ a: inout [Int], invert: Bool) {
    let n = a.count
    // 1. Bit-reversal permutation: put each coefficient where the recursion would leave it
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
    // 2. Butterflies: merge blocks of length 2, 4, 8, … up to n
    var length = 2
    while length <= n {
        var root = power(3, (mod - 1) / length)          // a primitive root of unity of order `length`
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
    // 3. The inverse transform divides by n
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

func naiveMultiply(_ a: [Int], _ b: [Int]) -> [Int] {
    var c = Array(repeating: 0, count: a.count + b.count - 1)
    for i in a.indices {
        for j in b.indices { c[i + j] += a[i] * b[j] }
    }
    return c
}

// A tiny deterministic generator, so the test inputs are the same every run
var state: UInt64 = 2024
func nextRandom(_ upper: Int) -> Int {
    state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
    return Int(state >> 33) % upper
}

print(multiply([1, 2, 3], [4, 5]))
var agree = 0
for _ in 0..<200 {
    let a = (0..<(1 + nextRandom(40))).map { _ in nextRandom(1000) }
    let b = (0..<(1 + nextRandom(40))).map { _ in nextRandom(1000) }
    if multiply(a, b) == naiveMultiply(a, b) { agree += 1 }
}
print("agree on \(agree) of 200 random pairs")
