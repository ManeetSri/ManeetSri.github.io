// Generated from src/dsa/content/lessons/swift-functions/swift-first-recursion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func factorial(_ n: Int, depth: Int = 0) -> Int {
    let indent = String(repeating: "    ", count: depth)
    print("\(indent)factorial(\(n)) starts")
    if n == 0 {
        print("\(indent)factorial(0) returns 1")
        return 1
    }
    let result = n * factorial(n - 1, depth: depth + 1)
    print("\(indent)factorial(\(n)) returns \(result)")
    return result
}

print(factorial(3))
