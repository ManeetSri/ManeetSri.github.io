// Generated from src/dsa/content/lessons/two-pointers/tp-trapping-rain-water.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func trappedWater(_ heights: [Int]) -> Int {
    var left = 0
    var right = heights.count - 1
    var leftMax = 0
    var rightMax = 0
    var total = 0
    while left <= right {
        leftMax = max(leftMax, heights[left])
        rightMax = max(rightMax, heights[right])
        if leftMax <= rightMax {
            print("position \(left): leftMax \(leftMax) <= rightMax \(rightMax), water \(leftMax - heights[left])")
            total += leftMax - heights[left]
            left += 1
        } else {
            print("position \(right): rightMax \(rightMax) < leftMax \(leftMax), water \(rightMax - heights[right])")
            total += rightMax - heights[right]
            right -= 1
        }
    }
    return total
}

print(trappedWater([4, 1, 3, 0, 2, 5, 1, 2]))
