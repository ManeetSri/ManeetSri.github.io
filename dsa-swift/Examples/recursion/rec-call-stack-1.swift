// Generated from src/dsa/content/lessons/recursion/rec-call-stack.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var callStack: [String] = []

func factorial(_ n: Int) -> Int {
    callStack.append("factorial(\(n))")
    print("stack:", callStack.joined(separator: " | "))

    let result: Int
    if n <= 1 {
        result = 1
    } else {
        result = n * factorial(n - 1)
    }

    callStack.removeLast()
    print("factorial(\(n)) returns \(result)")
    return result
}

print(factorial(3))
