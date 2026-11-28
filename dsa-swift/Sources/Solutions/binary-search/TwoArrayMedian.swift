// Reference solution: Median of two sorted arrays. Split both arrays so the left parts together hold
// half the values (the extra one when the total is odd). Choosing i values from the shorter array
// fixes j = half - i from the longer one, so binary search over i. The split is right when
// first[i - 1] ≤ second[j] and second[j - 1] ≤ first[i]; a missing neighbour counts as Int.min on the
// left or Int.max on the right. Then the median comes from the largest left value and the smallest
// right value. O(log min(m, n)) time, O(1) space.

public enum TwoArrayMedian {
    public static func median(of first: [Int], and second: [Int]) -> Double {
        if first.count > second.count {
            return median(of: second, and: first)    // search the shorter array
        }
        let m = first.count
        let n = second.count
        let leftSize = (m + n + 1) / 2
        var low = 0
        var high = m
        while low <= high {
            let i = low + (high - low) / 2           // values taken from first
            let j = leftSize - i                     // values taken from second
            let firstLeft = i > 0 ? first[i - 1] : Int.min
            let firstRight = i < m ? first[i] : Int.max
            let secondLeft = j > 0 ? second[j - 1] : Int.min
            let secondRight = j < n ? second[j] : Int.max
            if firstLeft > secondRight {
                high = i - 1                         // took too many from first
            } else if secondLeft > firstRight {
                low = i + 1                          // took too few from first
            } else {
                let leftMax = Swift.max(firstLeft, secondLeft)
                if (m + n) % 2 == 1 {
                    return Double(leftMax)
                }
                let rightMin = Swift.min(firstRight, secondRight)
                return Double(leftMax + rightMin) / 2    // values are within ±10⁹: no overflow
            }
        }
        preconditionFailure("Both arrays must be sorted, with at least one value between them")
    }
}
