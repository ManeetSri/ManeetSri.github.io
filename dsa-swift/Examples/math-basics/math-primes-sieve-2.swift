// Generated from src/dsa/content/lessons/math-basics/math-primes-sieve.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sieve(upTo n: Int) -> [Bool] {
    var isPrime = Array(repeating: true, count: max(n + 1, 2))
    isPrime[0] = false
    isPrime[1] = false
    var p = 2
    while p * p <= n {
        if isPrime[p] {
            for multiple in stride(from: p * p, through: n, by: p) {
                isPrime[multiple] = false
            }
        }
        p += 1
    }
    return isPrime
}

let flags = sieve(upTo: 30)
print(flags.indices.filter { flags[$0] })
for limit in [100, 1_000, 1_000_000] {
    print(limit, sieve(upTo: limit).filter { $0 }.count)
}
