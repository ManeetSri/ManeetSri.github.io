// Generated from src/dsa/content/lessons/complexity/bigo-space.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var calls = 0
var depth = 0
var deepest = 0

func fibonacci(_ n: Int) -> Int {
    calls += 1
    depth += 1
    deepest = max(deepest, depth)
    defer { depth -= 1 }
    if n < 2 {
        return n
    }
    return fibonacci(n - 1) + fibonacci(n - 2)
}

for n in [5, 10, 20] {
    calls = 0
    deepest = 0
    let value = fibonacci(n)
    print("fibonacci(\(n)) = \(value): \(calls) calls, deepest stack \(deepest)")
}
