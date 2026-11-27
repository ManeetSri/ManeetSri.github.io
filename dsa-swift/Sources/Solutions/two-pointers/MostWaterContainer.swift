// Reference solution: Container with most water. Start with the widest pair and always move the
// shorter wall inwards: every other container using that wall is narrower and no taller.
// O(n) time, O(1) space.

public enum MostWaterContainer {
    public static func maxWater(heights: [Int]) -> Int {
        var left = 0
        var right = heights.count - 1
        var best = 0
        while left < right {
            best = max(best, min(heights[left], heights[right]) * (right - left))
            if heights[left] < heights[right] {
                left += 1
            } else {
                right -= 1
            }
        }
        return best
    }
}
