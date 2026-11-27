// Generated from src/dsa/content/lessons/two-pointers/tp-why-it-works.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func pairsBelow(_ sorted: [Int], _ target: Int) -> Int {
    var left = 0
    var right = sorted.count - 1
    var count = 0
    while left < right {
        if sorted[left] + sorted[right] < target {
            count += right - left      // left pairs with every index from left + 1 to right
            left += 1
        } else {
            right -= 1
        }
    }
    return count
}

print(pairsBelow([1, 3, 4, 6, 8], 10))
print(pairsBelow([-2, 0, 1, 5], 3))
