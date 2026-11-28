// Generated from src/dsa/content/lessons/queues/queue-monotonic-deque.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Comparisons made by the brute force and by the monotonic deque
func bruteForceComparisons(_ values: [Int], k: Int) -> Int {
    var comparisons = 0
    for start in 0...(values.count - k) {
        var best = values[start]
        for i in (start + 1)..<(start + k) {
            comparisons += 1
            if values[i] > best { best = values[i] }
        }
    }
    return comparisons
}

func dequeComparisons(_ values: [Int], k: Int) -> (comparisons: Int, removals: Int) {
    var window: [Int] = []
    var head = 0
    var comparisons = 0
    var removals = 0
    for i in values.indices {
        if head < window.count && window[head] <= i - k {
            head += 1
            removals += 1
        }
        while head < window.count {
            comparisons += 1
            if values[window[window.count - 1]] <= values[i] {
                window.removeLast()
                removals += 1
            } else {
                break
            }
        }
        window.append(i)
    }
    return (comparisons, removals)
}

let values = (0..<5_000).map { ($0 * 7_919) % 1_000 }   // varied, but the same every run
for k in [10, 100, 1_000] {
    let deque = dequeComparisons(values, k: k)
    print("k = \(k): brute force \(bruteForceComparisons(values, k: k)), deque \(deque.comparisons) comparisons and \(deque.removals) removals")
}
