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

print([12, 18, 30].reduce(0, gcd))
print([7, 14, 22].reduce(0, gcd))
