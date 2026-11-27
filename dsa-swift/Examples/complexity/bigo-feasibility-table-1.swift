// Generated from src/dsa/content/lessons/complexity/bigo-feasibility-table.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let budget = 100_000_000

func log2Floor(_ n: Int) -> Int {
    var steps = 0
    var size = n
    while size > 1 {
        size /= 2
        steps += 1
    }
    return steps
}

// The largest n whose step count still fits the budget, found by doubling then halving
func largestN(_ steps: (Int) -> Int) -> Int {
    var low = 1
    var high = 2
    while steps(high) <= budget {
        low = high
        high *= 2
    }
    while high - low > 1 {
        let mid = (low + high) / 2
        if steps(mid) <= budget {
            low = mid
        } else {
            high = mid
        }
    }
    return low
}

func factorial(_ n: Int) -> Int {
    (1...max(1, n)).reduce(1, *)
}

func twoToThe(_ n: Int) -> Int {
    (0..<n).reduce(1) { total, _ in total * 2 }
}

print("n!:", largestN(factorial))
print("2ⁿ:", largestN(twoToThe))
print("n³:", largestN { $0 * $0 * $0 })
print("n²:", largestN { $0 * $0 })
print("n log n:", largestN { $0 * log2Floor($0) })
print("n:", largestN { $0 })
