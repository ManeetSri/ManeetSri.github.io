// Reference solution: The kth smallest gap between houses. The number of pairs at most d apart grows with
// d, so binary search for the smallest d whose count reaches k. On the sorted positions, two pointers count
// the pairs for one d in O(n). O(n log n + n log D) time, where D is the spread of the positions.

public enum KthSmallestHouseGap {
    public static func kthGap(_ houses: [Int], k: Int) -> Int {
        let sorted = houses.sorted()

        func pairs(within d: Int) -> Int {
            var count = 0
            var left = 0
            for right in sorted.indices {
                while sorted[right] - sorted[left] > d {
                    left += 1
                }
                count += right - left             // every house from left to right − 1 pairs with right
            }
            return count
        }

        var low = 0
        var high = sorted[sorted.count - 1] - sorted[0]
        while low < high {
            let mid = low + (high - low) / 2
            if pairs(within: mid) >= k {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low
    }
}
