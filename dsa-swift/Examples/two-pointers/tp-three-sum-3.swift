// Generated from src/dsa/content/lessons/two-pointers/tp-three-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fourSum(_ numbers: [Int], _ target: Int) -> [[Int]] {
    let nums = numbers.sorted()
    let n = nums.count
    var result: [[Int]] = []
    for a in 0..<n {
        if a > 0 && nums[a] == nums[a - 1] { continue }
        for b in (a + 1)..<n {
            if b > a + 1 && nums[b] == nums[b - 1] { continue }
            var left = b + 1
            var right = n - 1
            while left < right {
                let sum = nums[a] + nums[b] + nums[left] + nums[right]
                if sum < target {
                    left += 1
                } else if sum > target {
                    right -= 1
                } else {
                    result.append([nums[a], nums[b], nums[left], nums[right]])
                    left += 1
                    right -= 1
                    while left < right && nums[left] == nums[left - 1] { left += 1 }
                }
            }
        }
    }
    return result
}

print(fourSum([2, -1, 0, 1, -2, 0, 3], 2))
print(fourSum([1, 1, 1, 1, 1], 4))
