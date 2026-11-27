// Generated from src/dsa/content/lessons/math-basics/math-divisors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func divisorSum(_ n: Int) -> Int {
    var total = 0
    var i = 1
    while i * i <= n {
        if n % i == 0 {
            total += i
            if i != n / i {
                total += n / i
            }
        }
        i += 1
    }
    return total
}

print(divisorSum(12))
print((2...10_000).filter { divisorSum($0) - $0 == $0 })
