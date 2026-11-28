// Generated from src/dsa/content/lessons/recursion/rec-vs-iteration.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sumRecursive(_ n: Int) -> Int {
    if n <= 0 {
        return 0
    }
    return n + sumRecursive(n - 1)
}

func sumLoop(_ n: Int) -> Int {
    var total = 0
    var current = n
    while current > 0 {
        total += current
        current -= 1
    }
    return total
}

print(sumRecursive(100), sumLoop(100))
