// Generated from src/dsa/content/lessons/dp-foundations/dp-space.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fib(_ n: Int) -> Int {
    if n < 2 {
        return n
    }
    var (previous, current) = (0, 1)          // fib(i - 2) and fib(i - 1), starting at i = 2
    for _ in 2...n {
        (previous, current) = (current, previous + current)
    }
    return current
}

print(fib(10), fib(92))

// The same shift written as two separate assignments, in the wrong order
var previous = 0
var current = 1
for _ in 2...10 {
    previous = current
    current = previous + current              // previous was just overwritten
}
print(current)
