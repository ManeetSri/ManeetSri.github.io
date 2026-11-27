// Generated from src/dsa/content/lessons/divide-conquer/dc-paradigm.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var fibonacciCalls = 0
var sortCalls = 0

// fib(n) splits into fib(n - 1) and fib(n - 2): the two parts overlap
func fibonacci(_ n: Int) -> Int {
    fibonacciCalls += 1
    return n < 2 ? n : fibonacci(n - 1) + fibonacci(n - 2)
}

// Merge sort's shape: the two halves never share an element
func mergeSortShape(_ low: Int, _ high: Int) {
    sortCalls += 1
    guard high - low > 1 else { return }
    let mid = low + (high - low) / 2
    mergeSortShape(low, mid)
    mergeSortShape(mid, high)
}

for n in [10, 20, 30] {
    fibonacciCalls = 0
    sortCalls = 0
    _ = fibonacci(n)
    mergeSortShape(0, n)
    print("n = \(n): fibonacci \(fibonacciCalls) calls for \(n + 1) different questions, merge sort \(sortCalls) calls")
}
