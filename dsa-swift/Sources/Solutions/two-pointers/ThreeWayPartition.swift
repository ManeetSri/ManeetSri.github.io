// Reference solution: Three-way partition. The Dutch national flag algorithm with "less than",
// "equal to" and "greater than" the pivot as its three groups. When it ends, the equal block is
// low...high, which is low..<(high + 1). O(n) time, O(1) extra space, one pass.

public enum ThreeWayPartition {
    public static func partition(_ numbers: inout [Int], around pivot: Int) -> Range<Int> {
        var low = 0
        var mid = 0
        var high = numbers.count - 1
        while mid <= high {
            if numbers[mid] < pivot {
                numbers.swapAt(low, mid)
                low += 1
                mid += 1
            } else if numbers[mid] == pivot {
                mid += 1
            } else {
                numbers.swapAt(mid, high)
                high -= 1
            }
        }
        return low..<(high + 1)
    }
}
