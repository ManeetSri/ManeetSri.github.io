// Generated from src/dsa/content/lessons/stacks/stack-monotonic-intro.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func nextGreaterOrEqual(_ items: [Int]) -> [Int] {
    var result = Array(repeating: -1, count: items.count)
    var waiting: [Int] = []
    for i in items.indices {
        while let top = waiting.last, items[top] <= items[i] {   // <= instead of <
            result[top] = items[i]
            waiting.removeLast()
        }
        waiting.append(i)
    }
    return result
}

print(nextGreaterOrEqual([2, 2, 3]))
