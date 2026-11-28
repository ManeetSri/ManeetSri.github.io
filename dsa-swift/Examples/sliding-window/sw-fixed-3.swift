// Generated from src/dsa/content/lessons/sliding-window/sw-fixed.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func maxWindowSum(_ items: [Int], _ k: Int) -> (best: Int, operations: Int) {
    var windowSum = 0
    var operations = 0
    for index in 0..<k {
        windowSum += items[index]
        operations += 1
    }
    var best = windowSum
    for right in k..<items.count {
        windowSum += items[right] - items[right - k]   // one in, one out
        operations += 2
        best = max(best, windowSum)
    }
    return (best, operations)
}

let numbers = (0..<10_000).map { ($0 * 37) % 101 }
let result = maxWindowSum(numbers, 1_000)
print(result.best, result.operations)
