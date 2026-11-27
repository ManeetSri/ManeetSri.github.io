// Generated from src/dsa/content/lessons/two-pointers/tp-three-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func threeSum(_ numbers: [Int]) -> [[Int]] {
    let nums = numbers.sorted()
    var result: [[Int]] = []
    for i in nums.indices {
        if i > 0 && nums[i] == nums[i - 1] {
            continue                          // same fixed value as last time
        }
        if nums[i] > 0 {
            break                             // everything to the right is positive too
        }
        var left = i + 1
        var right = nums.count - 1
        while left < right {
            let sum = nums[i] + nums[left] + nums[right]
            if sum < 0 {
                left += 1
            } else if sum > 0 {
                right -= 1
            } else {
                result.append([nums[i], nums[left], nums[right]])
                left += 1
                right -= 1
                while left < right && nums[left] == nums[left - 1] {
                    left += 1                 // skip copies of the value just used
                }
            }
        }
    }
    return result
}

print(threeSum([-2, 0, 1, 1, 2, -1, -4, 2]))
print(threeSum([0, 0, 0, 0]))
print(threeSum([3, -1, -1, 0, 1, -2, 2]))
print(threeSum([1, 2, 3]))
