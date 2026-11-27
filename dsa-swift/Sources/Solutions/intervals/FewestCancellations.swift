// Reference solution: Fewest cancellations. Keep as many bookings as possible, greedily: sort by end
// and keep each booking that starts at or after the end of the last one kept (half-open, so touching
// is fine). An exchange argument shows the earliest-ending booking is always safe to keep.
// The answer is the number not kept. O(n log n) time, O(n) space for the sorted copy.

public enum FewestCancellations {
    public static func minimumCancellations(_ bookings: [[Int]]) -> Int {
        let sorted = bookings.sorted { $0[1] < $1[1] }
        var kept = 0
        var lastEnd = Int.min
        for booking in sorted where booking[0] >= lastEnd {
            kept += 1
            lastEnd = booking[1]
        }
        return bookings.count - kept
    }
}
