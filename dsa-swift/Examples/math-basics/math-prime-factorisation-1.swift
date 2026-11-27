// Generated from src/dsa/content/lessons/math-basics/math-prime-factorisation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func primeFactors(of number: Int) -> [(prime: Int, exponent: Int)] {
    var n = number
    var factors: [(prime: Int, exponent: Int)] = []
    var d = 2
    while d * d <= n {
        if n % d == 0 {
            var exponent = 0
            while n % d == 0 {
                n /= d
                exponent += 1
            }
            factors.append((prime: d, exponent: exponent))
        }
        d += 1
    }
    if n > 1 {
        factors.append((prime: n, exponent: 1))
    }
    return factors
}

for x in [360, 97, 1, 600_851_475_143] {
    let parts = primeFactors(of: x).map { "\($0.prime)^\($0.exponent)" }
    print(x, "=", parts.joined(separator: " × "))
}
