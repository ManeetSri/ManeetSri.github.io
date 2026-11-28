// Generated from src/dsa/content/lessons/bs-on-answer/bsa-kth-multiplication.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func entries(atMost x: Int, rows m: Int, columns n: Int) -> Int {
    var count = 0
    for i in 1...m {
        count += min(x / i, n)
    }
    return count
}

func kthSmallest(rows m: Int, columns n: Int, k: Int) -> Int {
    var low = 1
    var high = m * n                     // the largest entry
    while low < high {
        let mid = low + (high - low) / 2
        if entries(atMost: mid, rows: m, columns: n) >= k {
            high = mid
        } else {
            low = mid + 1
        }
    }
    return low
}

print((1...12).map { kthSmallest(rows: 3, columns: 4, k: $0) })
print(kthSmallest(rows: 30_000, columns: 30_000, k: 450_000_000))
