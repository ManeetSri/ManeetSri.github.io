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

func lcm(_ a: Int, _ b: Int) -> Int {
    a / gcd(a, b) * b
}

print(lcm(4, 6), lcm(21, 6))
print(lcm(3_000_000_000_000, 3_000_000_000_000))
