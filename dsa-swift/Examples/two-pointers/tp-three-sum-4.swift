// Generated from src/dsa/content/lessons/two-pointers/tp-three-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func threeSumClosest(_ numbers: [Int], _ target: Int) -> Int {
    let nums = numbers.sorted()
    var best = nums[0] + nums[1] + nums[2]
    for i in 0..<(nums.count - 2) {
        var left = i + 1
        var right = nums.count - 1
        while left < right {
            let sum = nums[i] + nums[left] + nums[right]
            if abs(sum - target) < abs(best - target) {
                best = sum
            }
            if sum < target {
                left += 1
            } else if sum > target {
                right -= 1
            } else {
                return sum
            }
        }
    }
    return best
}

print(threeSumClosest([4, -3, 1, 9, -6], 5))
