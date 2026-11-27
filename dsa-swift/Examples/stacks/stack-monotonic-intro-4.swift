// Generated from src/dsa/content/lessons/stacks/stack-monotonic-intro.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func nextGreaterCircular(_ items: [Int]) -> [Int] {
    let n = items.count
    var result = Array(repeating: -1, count: n)
    var waiting: [Int] = []
    for step in 0..<(2 * n) {
        let i = step % n
        while let top = waiting.last, items[top] < items[i] {
            result[top] = items[i]
            waiting.removeLast()
        }
        if step < n {
            waiting.append(i)             // the second lap only answers; it never waits
        }
    }
    return result
}

print(nextGreaterCircular([1, 5, 3, 2]))
print(nextGreaterCircular([4, 4, 4]))
