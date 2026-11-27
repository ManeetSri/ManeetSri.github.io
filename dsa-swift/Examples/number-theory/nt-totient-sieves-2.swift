// Generated from src/dsa/content/lessons/number-theory/nt-totient-sieves.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// φ for every number up to n, sieve style
func totients(upTo n: Int) -> [Int] {
    var phi = Array(0...n)
    for p in stride(from: 2, through: n, by: 1) where phi[p] == p {   // still untouched, so p is prime
        for multiple in stride(from: p, through: n, by: p) {
            phi[multiple] -= phi[multiple] / p
        }
    }
    return phi
}

let phi = totients(upTo: 1_000_000)
print(Array(phi[1...12]))
print(phi[36], phi[999_983])
var fractions = 0
for q in 2...8 { fractions += phi[q] }
print(fractions)
print(phi[2...1_000_000].reduce(0, +))
