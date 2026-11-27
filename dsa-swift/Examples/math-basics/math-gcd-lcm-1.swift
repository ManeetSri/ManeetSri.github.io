// Generated from src/dsa/content/lessons/math-basics/math-gcd-lcm.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func gcd(_ first: Int, _ second: Int) -> Int {
    var a = abs(first)
    var b = abs(second)
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return a
}

print(gcd(48, 18), gcd(1071, 462), gcd(17, 5))
print(gcd(18, 48), gcd(0, 9), gcd(0, 0), gcd(-12, 18))
