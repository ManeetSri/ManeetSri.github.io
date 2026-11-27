// Generated from src/dsa/content/lessons/recursion/rec-warmups.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func factorial(_ n: Int) -> Int {
    precondition(n >= 0, "factorial needs n ≥ 0")
    if n <= 1 {
        return 1
    }
    return n * factorial(n - 1)
}

print(factorial(0), factorial(5), factorial(20))
