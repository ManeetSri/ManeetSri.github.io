// Generated from src/dsa/content/lessons/number-theory/nt-totient-sieves.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Linear sieve: every composite is crossed out exactly once, by its smallest prime factor
let n = 30
var smallest = Array(repeating: 0, count: n + 1)   // smallest prime factor; 0 means not found yet
var primes: [Int] = []
var crossings = 0
for i in 2...n {
    if smallest[i] == 0 {                          // nobody crossed i out, so it's prime
        smallest[i] = i
        primes.append(i)
    }
    for p in primes {
        if p > smallest[i] || i * p > n { break }  // p must not exceed i's own smallest factor
        smallest[i * p] = p
        crossings += 1
    }
}
print(primes)
print(Array(smallest[2...n]))
print("crossings:", crossings, "composites:", n - 1 - primes.count)
