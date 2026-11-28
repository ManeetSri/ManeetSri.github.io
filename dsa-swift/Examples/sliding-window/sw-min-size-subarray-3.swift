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

func shortestBrute(_ items: [Int], atLeast target: Int) -> Int {
    var best = 0
    for start in items.indices {
        var sum = 0
        for end in start..<items.count {
            sum += items[end]
            if sum >= target && (best == 0 || end - start + 1 < best) {
                best = end - start + 1
            }
        }
    }
    return best
}

print(shortestWindow([1, -5, 6], atLeast: 6))
print(shortestBrute([1, -5, 6], atLeast: 6))
