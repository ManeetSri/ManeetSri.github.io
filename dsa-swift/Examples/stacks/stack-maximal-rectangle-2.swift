// Generated from src/dsa/content/lessons/stacks/stack-maximal-rectangle.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sumOfMinimums(_ items: [Int]) -> Int {
    let n = items.count
    var left = Array(repeating: 0, count: n)     // choices for the start
    var right = Array(repeating: 0, count: n)    // choices for the end
    var stack: [Int] = []
    for i in 0..<n {
        while let top = stack.last, items[top] > items[i] {    // previous strictly smaller stays
            stack.removeLast()
        }
        left[i] = i - (stack.last ?? -1)
        stack.append(i)
    }
    stack.removeAll()
    for i in stride(from: n - 1, through: 0, by: -1) {
        while let top = stack.last, items[top] >= items[i] {   // next smaller-or-equal stays
            stack.removeLast()
        }
        right[i] = (stack.last ?? n) - i
        stack.append(i)
    }
    var total = 0
    for i in 0..<n {
        total += items[i] * left[i] * right[i]
    }
    return total
}

func bruteForce(_ items: [Int]) -> Int {
    var total = 0
    for start in items.indices {
        var lowest = Int.max
        for end in start..<items.count {
            lowest = min(lowest, items[end])
            total += lowest
        }
    }
    return total
}

for items in [[3, 1, 2, 4], [2, 2], [5, 3, 4, 3]] {
    print(items, sumOfMinimums(items), bruteForce(items))
}
