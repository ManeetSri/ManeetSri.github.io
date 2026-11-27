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

// Recursive NTT: the values of polynomial a at w⁰, w¹, …, w^(n-1), where w is a primitive nth root of unity
func transform(_ a: [Int], _ w: Int) -> [Int] {
    let n = a.count
    if n == 1 { return a }
    let even = transform(stride(from: 0, to: n, by: 2).map { a[$0] }, w * w % mod)
    let odd = transform(stride(from: 1, to: n, by: 2).map { a[$0] }, w * w % mod)
    var values = Array(repeating: 0, count: n)
    var x = 1                                         // x = wᵏ
    for k in 0..<(n / 2) {
        let t = x * odd[k] % mod
        values[k] = (even[k] + t) % mod               // A(wᵏ)         = E(w²ᵏ) + wᵏ·O(w²ᵏ)
        values[k + n / 2] = (even[k] - t + mod) % mod // A(wᵏ⁺ⁿᐟ²)   = E(w²ᵏ) − wᵏ·O(w²ᵏ)
        x = x * w % mod
    }
    return values
}

func multiply(_ a: [Int], _ b: [Int]) -> [Int] {
    let resultSize = a.count + b.count - 1
    var n = 1
    while n < resultSize { n <<= 1 }
    let w = power(3, (mod - 1) / n)
    let fa = transform(a + Array(repeating: 0, count: n - a.count), w)
    let fb = transform(b + Array(repeating: 0, count: n - b.count), w)
    let product = (0..<n).map { fa[$0] * fb[$0] % mod }          // multiply the values pointwise
    let back = transform(product, power(w, mod - 2))             // the same transform with w⁻¹…
    let nInverse = power(n, mod - 2)
    return (0..<resultSize).map { back[$0] * nInverse % mod }     // …then divide by n
}

print(multiply([1, 2, 3], [4, 5]))
print(multiply([3, 2, 1], [5, 4]))
print(transform([1, 2, 3, 4], power(3, (mod - 1) / 4)))
