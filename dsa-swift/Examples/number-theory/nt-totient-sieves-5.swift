// Generated from src/dsa/content/lessons/number-theory/nt-totient-sieves.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The linear sieve, also filling in φ, then O(log k) factorisation by smallest prime factor
let limit = 1_000_000
var smallest = Array(repeating: 0, count: limit + 1)
var phi = Array(repeating: 0, count: limit + 1)
var primes: [Int] = []
phi[1] = 1
for i in 2...limit {
    if smallest[i] == 0 {
        smallest[i] = i
        phi[i] = i - 1
        primes.append(i)
    }
    for p in primes {
        if p > smallest[i] || i * p > limit { break }
        smallest[i * p] = p
        // p already divides i: one more factor of p multiplies φ by p; a new prime multiplies it by p - 1
        phi[i * p] = p == smallest[i] ? phi[i] * p : phi[i] * (p - 1)
    }
}

func factorise(_ number: Int) -> [Int] {
    var k = number
    var factors: [Int] = []
    while k > 1 {
        factors.append(smallest[k])
        k /= smallest[k]
    }
    return factors
}

print(primes.count, primes.last!)
print(phi[36], phi[999_983], phi[720_720])
print(factorise(720_720), factorise(999_983), factorise(1_000_000))
