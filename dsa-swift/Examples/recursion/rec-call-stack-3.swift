// Generated from src/dsa/content/lessons/recursion/rec-call-stack.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var callStack: [String] = []

func fib(_ n: Int) -> Int {
    callStack.append("fib(\(n))")
    print(callStack.joined(separator: " | "))
    defer {
        callStack.removeLast()
    }
    if n < 2 {
        return n
    }
    return fib(n - 1) + fib(n - 2)
}

print(fib(3))
