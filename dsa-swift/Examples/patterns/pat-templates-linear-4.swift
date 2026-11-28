// Generated from src/dsa/content/lessons/patterns/pat-templates-linear.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Fixed-size window: the best total of any k consecutive values
func bestWindowSum(_ items: [Int], _ k: Int) -> Int? {
    guard k > 0, k <= items.count else { return nil }
    var sum = 0
    var best = Int.min
    for right in items.indices {
        sum += items[right]                       // grow
        if right >= k {
            sum -= items[right - k]               // the element that just left
        }
        if right >= k - 1 {
            best = max(best, sum)                 // a full window: items[right - k + 1...right]
        }
    }
    return best
}

print(bestWindowSum([4, -1, 3, 5, -2, 6, 1], 3) ?? "none")
print(bestWindowSum([-5, -2, -7], 2) ?? "none")
print(bestWindowSum([1, 2], 3) ?? "none")
