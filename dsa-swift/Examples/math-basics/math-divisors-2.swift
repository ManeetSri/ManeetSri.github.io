// Generated from src/dsa/content/lessons/math-basics/math-divisors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func divisors(of n: Int) -> [Int] {
    var small: [Int] = []
    var large: [Int] = []
    var i = 1
    while i * i <= n {
        if n % i == 0 {
            small.append(i)
            if i != n / i {
                large.append(n / i)
            }
        }
        i += 1
    }
    return small + large.reversed()
}

print(divisors(of: 36))
print(divisors(of: 28))
print(divisors(of: 13))
print(divisors(of: 1))
