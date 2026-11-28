// Generated from src/dsa/content/lessons/recursion/rec-recursion-trees.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var calls = 0

func fib(_ n: Int) -> Int {
    calls += 1
    if n < 2 {
        return n
    }
    return fib(n - 1) + fib(n - 2)
}

for n in [5, 10, 15, 20, 25] {
    calls = 0
    let value = fib(n)
    print("fib(\(n)) = \(value) after \(calls) calls")
}
