// Generated from src/dsa/content/lessons/stacks/stack-histogram.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func largestAreaTwoPasses(_ heights: [Int]) -> Int {
    let n = heights.count
    var left = Array(repeating: -1, count: n)     // index of the previous shorter bar, or -1
    var right = Array(repeating: n, count: n)     // index of the next shorter bar, or n
    var stack: [Int] = []
    for i in 0..<n {
        while let top = stack.last, heights[top] >= heights[i] {
            stack.removeLast()
        }
        left[i] = stack.last ?? -1
        stack.append(i)
    }
    stack.removeAll()
    for i in stride(from: n - 1, through: 0, by: -1) {
        while let top = stack.last, heights[top] >= heights[i] {
            stack.removeLast()
        }
        right[i] = stack.last ?? n
        stack.append(i)
    }
    var best = 0
    for i in 0..<n {
        best = max(best, heights[i] * (right[i] - left[i] - 1))
    }
    print("left: ", left)
    print("right:", right)
    return best
}

print(largestAreaTwoPasses([2, 1, 5, 6, 2, 3]))
