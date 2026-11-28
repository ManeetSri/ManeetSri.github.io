// Generated from src/dsa/content/lessons/number-theory/nt-ncr-mod-p.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The inverses of 1…n modulo a prime p in O(n): inv[i] = -(p / i) · inv[p % i]
let p = 13
var inv = Array(repeating: 0, count: p)
inv[1] = 1
for i in 2..<p {
    inv[i] = (p - p / i) * inv[p % i] % p
}
print(Array(inv[1...]))
print((1..<p).map { $0 * inv[$0] % p })
