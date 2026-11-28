// Generated from src/dsa/content/lessons/math-basics/math-prime-factorisation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func trailingZerosOfFactorial(_ n: Int) -> Int {
    var count = 0
    var power = 5
    while power <= n {
        count += n / power
        power *= 5
    }
    return count
}

print(trailingZerosOfFactorial(10))
print(trailingZerosOfFactorial(25))
print(trailingZerosOfFactorial(100))
print(trailingZerosOfFactorial(1_000_000_000))
