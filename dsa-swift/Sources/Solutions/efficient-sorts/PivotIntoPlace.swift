// Reference solution: Put the pivot in its place. Lomuto partitioning: `boundary` marks the end of
// the "smaller than the pivot" block. Scan j from low to high - 1, and swap every smaller element to
// the boundary. Finally swap the pivot from high to the boundary, between the two blocks. One pass:
// O(n) time for a range of n elements, O(1) extra space.

public enum PivotIntoPlace {
    public static func partition(_ numbers: inout [Int], low: Int, high: Int) -> Int {
        let pivot = numbers[high]
        var boundary = low                               // low..<boundary: smaller than the pivot
        for j in low..<high where numbers[j] < pivot {
            numbers.swapAt(boundary, j)
            boundary += 1
        }
        numbers.swapAt(boundary, high)                   // the pivot moves between the two blocks
        return boundary
    }
}
