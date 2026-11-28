// Generated from src/dsa/content/lessons/math-basics/math-primes-sieve.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isPrime(_ n: Int) -> Bool {
    if n < 2 {
        return false
    }
    if n < 4 {
        return true
    }
    if n % 2 == 0 {
        return false
    }
    var d = 3
    while d * d <= n {
        if n % d == 0 {
            return false
        }
        d += 2
    }
    return true
}

print((1...30).filter(isPrime))
print(isPrime(1_000_000_007), isPrime(999_999_999_989))
