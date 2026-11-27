// Generated from src/dsa/content/lessons/recursion/rec-memo-preview.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fibonacci(_ n: Int) -> Int {
    var cache: [Int: Int] = [:]

    func fib(_ k: Int) -> Int {
        if k < 2 {
            return k
        }
        if let known = cache[k] {
            return known
        }
        let result = fib(k - 1) + fib(k - 2)
        cache[k] = result
        return result
    }

    return fib(n)
}

print(fibonacci(50))
print(fibonacci(90))
