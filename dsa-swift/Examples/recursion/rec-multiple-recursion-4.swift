// Generated from src/dsa/content/lessons/recursion/rec-multiple-recursion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var callsFor: [Int: Int] = [:]

func fib(_ n: Int) -> Int {
    callsFor[n, default: 0] += 1
    if n < 2 {
        return n
    }
    return fib(n - 1) + fib(n - 2)
}

print(fib(10))
for n in callsFor.keys.sorted(by: >) {
    print("fib(\(n)) computed \(callsFor[n]!) times")
}
