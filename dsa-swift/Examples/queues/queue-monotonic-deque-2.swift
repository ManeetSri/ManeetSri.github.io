// Generated from src/dsa/content/lessons/queues/queue-monotonic-deque.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func windowMaxima(_ values: [Int], k: Int) -> [Int] {
    var result: [Int] = []
    var window: [Int] = []       // indexes; their values decrease from window[head] to the end
    var head = 0                 // the front of the deque: we only ever add at the back

    for i in values.indices {
        // 1. The front index leaves the window once it's k or more places behind i
        if head < window.count && window[head] <= i - k {
            head += 1
        }
        // 2. Older values that are no bigger than the new one can never be a maximum again
        while head < window.count && values[window[window.count - 1]] <= values[i] {
            window.removeLast()
        }
        // 3. The new index joins at the back
        window.append(i)
        // 4. Once the first window is complete, its maximum is at the front
        if i >= k - 1 {
            result.append(values[window[head]])
        }
        let kept = window[head...].map { values[$0] }
        print("i \(i), value \(values[i]): deque values \(kept)")
    }
    return result
}

print(windowMaxima([4, 2, 12, 3, 1, 8, 5], k: 3))
