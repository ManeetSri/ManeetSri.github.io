// Generated from src/dsa/content/lessons/sliding-window/sw-min-size-subarray.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func shortestWindow(_ items: [Int], atLeast target: Int) -> Int {
    var left = 0
    var sum = 0
    var best = Int.max
    for right in 0..<items.count {
        sum += items[right]
        while sum >= target {
            best = min(best, right - left + 1)
            sum -= items[left]
            left += 1
        }
    }
    return best == Int.max ? 0 : best
}

print(shortestWindow([1, 4, 2, 2, 3, 1, 5], atLeast: 8))
print(shortestWindow([5, 1, 3, 5, 10, 7, 4, 9, 2, 8], atLeast: 15))
print(shortestWindow([1, 1, 1], atLeast: 10))
