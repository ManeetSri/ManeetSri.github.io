// Generated from src/dsa/content/lessons/stacks/stack-monotonic-intro.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func nextGreater(_ items: [Int]) -> [Int] {
    var result = Array(repeating: -1, count: items.count)
    var waiting: [Int] = []                 // indexes still looking for something bigger
    for i in items.indices {
        while let top = waiting.last, items[top] < items[i] {
            result[top] = items[i]          // items[i] answers everything smaller that waits
            waiting.removeLast()
        }
        waiting.append(i)
    }
    return result
}

print(nextGreater([2, 7, 3, 5, 4, 6, 8]))
print(nextGreater([5, 4, 3]))
print(nextGreater([]))
