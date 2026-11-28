// Generated from src/dsa/content/lessons/two-pointers/tp-container-water.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func mostWater(_ heights: [Int], moveShorter: Bool) -> Int {
    var left = 0
    var right = heights.count - 1
    var best = 0
    while left < right {
        best = max(best, min(heights[left], heights[right]) * (right - left))
        let leftIsShorter = heights[left] < heights[right]
        if leftIsShorter == moveShorter {
            left += 1
        } else {
            right -= 1
        }
    }
    return best
}

print("move the shorter wall:", mostWater([2, 9, 9, 3], moveShorter: true))
print("move the taller wall: ", mostWater([2, 9, 9, 3], moveShorter: false))
