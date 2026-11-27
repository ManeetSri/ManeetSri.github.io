// Generated from src/dsa/content/lessons/math-basics/math-digits.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func reverse(_ number: Int) -> Int {
    var n = number
    var reversed = 0
    while n > 0 {
        reversed = reversed * 10 + n % 10
        n /= 10
    }
    return reversed
}

print(reverse(1234))
print(reverse(1200))
