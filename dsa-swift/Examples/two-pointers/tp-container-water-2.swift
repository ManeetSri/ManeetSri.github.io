// Generated from src/dsa/content/lessons/two-pointers/tp-container-water.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func mostWater(_ heights: [Int]) -> Int {
    var left = 0
    var right = heights.count - 1
    var best = 0
    while left < right {
        let water = min(heights[left], heights[right]) * (right - left)
        print("left \(left) (height \(heights[left])), right \(right) (height \(heights[right])): water \(water)")
        best = max(best, water)
        if heights[left] < heights[right] {
            left += 1
        } else {
            right -= 1
        }
    }
    return best
}

print(mostWater([3, 7, 2, 5, 4, 8, 3, 6]))
