// Reference solution: Merge into the first array. Fill `first` from the back: the larger of the two
// last unplaced values goes into the last free slot. Writing from the back never overwrites a value
// of `first` that hasn't been placed yet. O(m + n) time, O(1) extra space.

public enum MergeIntoFirst {
    public static func merge(_ first: inout [Int], used: Int, with second: [Int]) {
        var i = used - 1              // last unplaced value in first
        var j = second.count - 1      // last unplaced value in second
        var write = used + second.count - 1
        while j >= 0 {
            if i >= 0 && first[i] > second[j] {
                first[write] = first[i]
                i -= 1
            } else {
                first[write] = second[j]
                j -= 1
            }
            write -= 1
        }
        // Whatever is left of first is already in place
    }
}
