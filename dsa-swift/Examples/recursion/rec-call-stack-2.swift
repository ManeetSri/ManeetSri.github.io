// Generated from src/dsa/content/lessons/recursion/rec-call-stack.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func brokenSum(_ n: Int) -> Int {
    var total = 0
    if n > 0 {
        total += n
        _ = brokenSum(n - 1)       // this call's total is a different variable
    }
    return total
}

func sum(_ n: Int) -> Int {
    if n <= 0 {
        return 0
    }
    return n + sum(n - 1)          // use what the smaller call returns
}

print(brokenSum(3))
print(sum(3))
