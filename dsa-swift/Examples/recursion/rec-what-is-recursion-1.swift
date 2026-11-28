// Generated from src/dsa/content/lessons/recursion/rec-what-is-recursion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func digitCount(_ n: Int) -> Int {
    if n < 10 {
        return 1                      // base case: a single digit
    }
    return 1 + digitCount(n / 10)     // drop the last digit, count the rest
}

print(digitCount(7))
print(digitCount(2026))
print(digitCount(1_000_000))
