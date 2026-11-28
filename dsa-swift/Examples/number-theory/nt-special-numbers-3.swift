// Generated from src/dsa/content/lessons/number-theory/nt-special-numbers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mod = 1_000_000_007

func modPow(_ base: Int, _ exponent: Int) -> Int {
    var result = 1
    var square = base % mod
    var e = exponent
    while e > 0 {
        if e % 2 == 1 { result = result * square % mod }
        square = square * square % mod
        e /= 2
    }
    return result
}

// Catalan numbers modulo p: C(2n, n) / (n + 1), dividing with an inverse
let n = 1_000_000
var fact = Array(repeating: 1, count: 2 * n + 1)
for i in stride(from: 1, through: 2 * n, by: 1) { fact[i] = fact[i - 1] * i % mod }
func catalan(_ k: Int) -> Int {
    let twoKChooseK = fact[2 * k] * modPow(fact[k], mod - 2) % mod * modPow(fact[k], mod - 2) % mod
    return twoKChooseK * modPow(k + 1, mod - 2) % mod
}
print((0...10).map(catalan))
print(catalan(1_000_000))
