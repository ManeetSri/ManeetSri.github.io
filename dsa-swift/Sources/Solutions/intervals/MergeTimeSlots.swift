// Reference solution: Merge overlapping time slots. Sort by start, then make one pass: a slot that
// starts at or before the last merged slot's end overlaps or touches it (the slots are closed), so
// stretch that end with max; otherwise the slot starts a new merged slot.
// O(n log n) time for the sort, O(n) space for the sorted copy and the result.

public enum MergeTimeSlots {
    public static func merge(_ slots: [[Int]]) -> [[Int]] {
        let sorted = slots.sorted { $0[0] < $1[0] }
        var merged: [[Int]] = []
        merged.reserveCapacity(sorted.count)
        for slot in sorted {
            if let last = merged.last, slot[0] <= last[1] {
                merged[merged.count - 1][1] = max(last[1], slot[1])
            } else {
                merged.append(slot)
            }
        }
        return merged
    }
}
