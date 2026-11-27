// Generated from src/dsa/content/lessons/number-theory/nt-ncr-mod-p.mdx. Edit the lesson, then run
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

// Factorials and inverse factorials up to limit: O(limit + log mod) once, then O(1) per query
let limit = 1_000_000
var fact = Array(repeating: 1, count: limit + 1)
for i in stride(from: 1, through: limit, by: 1) {
    fact[i] = fact[i - 1] * i % mod
}
var invFact = Array(repeating: 1, count: limit + 1)
invFact[limit] = modPow(fact[limit], mod - 2)        // one Fermat inverse…
for i in stride(from: limit, to: 0, by: -1) {
    invFact[i - 1] = invFact[i] * i % mod             // …then walk down: 1/(i-1)! = i/i!
}

func choose(_ n: Int, _ k: Int) -> Int {
    guard k >= 0, k <= n else { return 0 }
    return fact[n] * invFact[k] % mod * invFact[n - k] % mod
}

print(choose(5, 2), choose(10, 3), choose(1000, 500))
print(choose(1_000_000, 500_000), choose(1_000_000, 1), choose(7, 9), choose(7, -1))
print(fact[5] * invFact[5] % mod, invFact[3] * 6 % mod)
