// Generated from src/dsa/content/lessons/patterns/pat-templates-linear.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Opposite ends: the pair rule decides which pointer moves
func pairWithSum(_ sorted: [Int], _ target: Int) -> (Int, Int)? {
    var left = 0
    var right = sorted.count - 1
    while left < right {                          // two different elements
        let sum = sorted[left] + sorted[right]
        if sum == target { return (left, right) }
        if sum < target {
            left += 1                             // sorted[left] is too small for every partner left
        } else {
            right -= 1                            // sorted[right] is too big for every partner left
        }
    }
    return nil
}

func mostWater(_ heights: [Int]) -> Int {
    var left = 0
    var right = heights.count - 1
    var best = 0
    while left < right {
        let area = min(heights[left], heights[right]) * (right - left)
        best = max(best, area)
        if heights[left] < heights[right] {
            left += 1                             // the shorter wall can't do better with anyone nearer
        } else {
            right -= 1
        }
    }
    return best
}

print(pairWithSum([1, 3, 4, 6, 8, 11], 10) ?? (-1, -1))
print(pairWithSum([2, 5], 4) == nil)
print(mostWater([1, 8, 6, 2, 5, 4, 8, 3, 7]))
