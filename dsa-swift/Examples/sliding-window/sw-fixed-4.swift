// Generated from src/dsa/content/lessons/sliding-window/sw-fixed.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func windowSums(_ items: [Int], _ k: Int) -> [Int] {
    var sums: [Int] = []
    var windowSum = 0
    for right in 0..<items.count {
        windowSum += items[right]             // entering
        if right >= k {
            windowSum -= items[right - k]     // leaving
        }
        if right >= k - 1 {
            sums.append(windowSum)            // a full window ends at right
        }
    }
    return sums
}

print(windowSums([2, 1, 5, 1, 3, 2], 3))
print(windowSums([4, 4], 3))
