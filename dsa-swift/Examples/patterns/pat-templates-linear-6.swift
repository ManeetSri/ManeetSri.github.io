// Generated from src/dsa/content/lessons/patterns/pat-templates-linear.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Monotonic deque: the maximum of every window of size k
func windowMaximums(_ items: [Int], _ k: Int) -> [Int] {
    var deque: [Int] = []                         // indexes; their values decrease from front to back
    var head = 0                                  // deque[head...] is live, so popping the front is O(1)
    var result: [Int] = []
    for right in items.indices {
        // Smaller values behind the newcomer can never be a maximum again
        while deque.count > head, items[deque[deque.count - 1]] <= items[right] {
            deque.removeLast()
        }
        deque.append(right)
        if deque[head] <= right - k { head += 1 } // the front has left the window
        if right >= k - 1 { result.append(items[deque[head]]) }
    }
    return result
}

print(windowMaximums([1, 3, -1, -3, 5, 3, 6, 7], 3))
print(windowMaximums([9, 8, 7, 6], 2))
