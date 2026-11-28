// Reference solution: Sorted squares. The largest remaining square is always at one of the two ends,
// so compare the ends and fill the result from the back. O(n) time, O(1) extra space besides the output.

public enum SortedSquares {
    public static func squares(of sorted: [Int]) -> [Int] {
        var result = Array(repeating: 0, count: sorted.count)
        var left = 0
        var right = sorted.count - 1
        var write = sorted.count - 1
        while left <= right {
            let leftSquare = sorted[left] * sorted[left]
            let rightSquare = sorted[right] * sorted[right]
            if leftSquare > rightSquare {
                result[write] = leftSquare
                left += 1
            } else {
                result[write] = rightSquare
                right -= 1
            }
            write -= 1
        }
        return result
    }
}
