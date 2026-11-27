// Generated from src/dsa/content/lessons/swift-functions/swift-first-recursion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func factorial(_ n: Int) -> Int {
    if n == 0 {
        return 1                      // base case
    }
    return n * factorial(n - 1)       // recursive case
}

print(factorial(0))
print(factorial(4))
print(factorial(10))
