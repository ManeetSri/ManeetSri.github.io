// Generated from src/dsa/content/lessons/recursion/rec-what-is-recursion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func gcd(_ a: Int, _ b: Int) -> Int {
    if b == 0 {
        return a
    }
    return gcd(b, a % b)
}

print(gcd(48, 18))
print(gcd(17, 5))
print(gcd(10, 0))
