// Reference solution: Zero-sum triplets. Sort, fix each value in turn, and run a two-pointer pair
// search on the values to its right. Duplicates are skipped for the fixed value and after each match.
// O(n²) time, O(1) extra space besides the sorted copy and the output.

public enum ZeroSumTriplets {
    public static func triplets(in numbers: [Int]) -> [[Int]] {
        let nums = numbers.sorted()
        var result: [[Int]] = []
        for i in nums.indices {
            if i > 0 && nums[i] == nums[i - 1] {
                continue
            }
            if nums[i] > 0 {
                break
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
                        left += 1
                    }
                }
            }
        }
        return result
    }
}
