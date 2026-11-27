// Reference solution: Trapped rainwater. Two pointers with running maximums. Whichever side has the
// smaller maximum knows its water level for certain, because the other side has already seen a bar at
// least that tall. O(n) time, O(1) space.

public enum TrappedRainwater {
    public static func trappedWater(heights: [Int]) -> Int {
        var left = 0
        var right = heights.count - 1
        var leftMax = 0
        var rightMax = 0
        var total = 0
        while left <= right {
            leftMax = max(leftMax, heights[left])
            rightMax = max(rightMax, heights[right])
            if leftMax <= rightMax {
                total += leftMax - heights[left]
                left += 1
            } else {
                total += rightMax - heights[right]
                right -= 1
            }
        }
        return total
    }
}
