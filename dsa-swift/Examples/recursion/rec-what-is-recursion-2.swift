// Generated from src/dsa/content/lessons/recursion/rec-what-is-recursion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isPowerOfTwo(_ n: Int) -> Bool {
    if n == 1 {
        return true                       // 2⁰
    }
    if n < 1 || n % 2 == 1 {
        return false                      // zero, negatives and odd numbers
    }
    return isPowerOfTwo(n / 2)
}

for n in [1, 2, 6, 64, 96, 0, -8] {
    print(n, isPowerOfTwo(n))
}
