// Generated from src/dsa/content/lessons/dp-foundations/dp-what-is-dp.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var asked = Array(repeating: 0, count: 11)

func fib(_ n: Int) -> Int {
    asked[n] += 1
    if n < 2 {
        return n
    }
    return fib(n - 1) + fib(n - 2)
}

print("fib(10) =", fib(10))
for k in stride(from: 10, through: 0, by: -1) {
    print("fib(\(k)) computed", asked[k], asked[k] == 1 ? "time" : "times")
}
print("total calls:", asked.reduce(0, +), "for", asked.count, "different questions")
