// Generated from src/dsa/content/lessons/queues/queue-monotonic-deque.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func windowMaxima(_ values: [Int], k: Int) -> [Int] {
    var result: [Int] = []
    for start in 0...(values.count - k) {
        result.append(values[start..<(start + k)].max()!)
    }
    return result
}

print(windowMaxima([4, 2, 12, 3, 1, 8, 5], k: 3))
