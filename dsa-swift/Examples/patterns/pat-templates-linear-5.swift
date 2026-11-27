// Generated from src/dsa/content/lessons/patterns/pat-templates-linear.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Variable window, longest: the longest run of 1s if you may flip at most k zeros
func longestWithFlips(_ bits: [Int], _ k: Int) -> Int {
    var zeros = 0                                 // the window's state
    var left = 0
    var best = 0
    for right in bits.indices {
        if bits[right] == 0 { zeros += 1 }        // 1. grow
        while zeros > k {                         // 2. shrink while invalid
            if bits[left] == 0 { zeros -= 1 }
            left += 1
        }
        best = max(best, right - left + 1)        // 3. record the valid window
    }
    return best
}

// Variable window, shortest: the shortest run of positive values adding up to at least target
func shortestReaching(_ items: [Int], _ target: Int) -> Int {
    var sum = 0
    var left = 0
    var best = Int.max
    for right in items.indices {
        sum += items[right]
        while sum >= target {                     // shrink while the goal is still reached
            best = min(best, right - left + 1)    // record before removing
            sum -= items[left]
            left += 1
        }
    }
    return best == Int.max ? 0 : best
}

print(longestWithFlips([1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1], 2))
print(longestWithFlips([0, 0, 0], 0))
print(shortestReaching([2, 1, 5, 2, 3, 2], 7))
print(shortestReaching([1, 1, 1], 5))
