// Reference solution: Count the moves of an array queue. Only the number of items waiting matters, so
// keep a count: each dequeue from c items adds c - 1 moves. O(n) time, O(1) space.

public enum ArrayQueueShiftCount {
    public static func moves(for operations: String) -> Int {
        var waiting = 0
        var total = 0
        for operation in operations.utf8 {
            if operation == UInt8(ascii: "E") {
                waiting += 1
            } else if waiting > 0 {
                total += waiting - 1             // everyone behind the front slides along
                waiting -= 1
            }
        }
        return total
    }
}
