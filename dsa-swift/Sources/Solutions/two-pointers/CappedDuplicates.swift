// Reference solution: Cap the duplicates. Read/write pointers: in a sorted array, a value can be kept
// unless the kept element `limit` slots back is the same value, which would mean `limit` copies are
// already kept. O(n) time, O(1) extra space.

public enum CappedDuplicates {
    public static func compact(_ numbers: inout [Int], keeping limit: Int) -> Int {
        var write = 0
        for read in numbers.indices {
            if write < limit || numbers[read] != numbers[write - limit] {
                numbers[write] = numbers[read]
                write += 1
            }
        }
        return write
    }
}
