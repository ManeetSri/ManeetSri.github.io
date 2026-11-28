// Generated from src/dsa/content/lessons/complexity/bigo-space.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var depth = 0
var deepest = 0

func enter() {
    depth += 1
    deepest = max(deepest, depth)
}

// Adds 1 + 2 + … + n by peeling off one number per call
func sumTo(_ n: Int) -> Int {
    enter()
    defer { depth -= 1 }
    if n == 0 {
        return 0
    }
    return n + sumTo(n - 1)
}

// Adds low + … + high by splitting the range in half
func sumRange(_ low: Int, _ high: Int) -> Int {
    enter()
    defer { depth -= 1 }
    if low == high {
        return low
    }
    let mid = (low + high) / 2
    return sumRange(low, mid) + sumRange(mid + 1, high)
}

for n in [8, 100, 1_000] {
    deepest = 0
    let first = sumTo(n)
    let peelingDepth = deepest
    deepest = 0
    let second = sumRange(1, n)
    print("n = \(n): sums \(first) and \(second), deepest stack \(peelingDepth) vs \(deepest)")
}
