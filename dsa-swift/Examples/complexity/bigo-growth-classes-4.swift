// Generated from src/dsa/content/lessons/complexity/bigo-growth-classes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func log2Floor(_ n: Int) -> Int {
    var steps = 0
    var size = n
    while size > 1 {
        size /= 2
        steps += 1
    }
    return steps
}

func twoToThe(_ n: Int) -> Int {
    var result = 1
    for _ in 0..<n {
        result *= 2
    }
    return result
}

func factorial(_ n: Int) -> Int {
    var result = 1
    for k in stride(from: 2, through: n, by: 1) {
        result *= k
    }
    return result
}

for n in [5, 10, 15, 20] {
    print("n = \(n): log n ≈ \(log2Floor(n)), n log n ≈ \(n * log2Floor(n)), n² = \(n * n), 2ⁿ = \(twoToThe(n)), n! = \(factorial(n))")
}
