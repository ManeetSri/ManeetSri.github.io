// Generated from src/dsa/content/lessons/dp-foundations/dp-what-is-dp.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// How often does each recursion meet a subproblem it has already met?
var fibCount: [Int: Int] = [:]

func fib(_ n: Int) -> Int {
    fibCount[n, default: 0] += 1
    if n < 2 {
        return n
    }
    return fib(n - 1) + fib(n - 2)
}

struct Piece: Hashable {
    let low: Int
    let high: Int
}
var sumCount: [Piece: Int] = [:]

// Divide and conquer: split the range in half, as merge sort does
func rangeSum(_ items: [Int], _ low: Int, _ high: Int) -> Int {
    sumCount[Piece(low: low, high: high), default: 0] += 1
    if high - low == 1 {
        return items[low]
    }
    let mid = (low + high) / 2
    return rangeSum(items, low, mid) + rangeSum(items, mid, high)
}

_ = fib(20)
print("fib(20):", fibCount.values.reduce(0, +), "calls,", fibCount.count, "different subproblems, most repeated:", fibCount.values.max()!)
_ = rangeSum(Array(1...1000), 0, 1000)
print("rangeSum:", sumCount.values.reduce(0, +), "calls,", sumCount.count, "different subproblems, most repeated:", sumCount.values.max()!)
