// Reference solution: Insert a time slot. Three phases over the sorted list: copy the slots that end
// before the new one starts, absorb every slot that starts at or before its end (closed slots, so
// touching ones join), add the merged slot, then copy the rest. O(n) time, O(n) space for the result.

public enum InsertTimeSlot {
    public static func insert(_ newSlot: [Int], into slots: [[Int]]) -> [[Int]] {
        var result: [[Int]] = []
        result.reserveCapacity(slots.count + 1)
        var merged = newSlot
        var i = 0
        // 1. Slots that end before the new slot starts
        while i < slots.count && slots[i][1] < merged[0] {
            result.append(slots[i])
            i += 1
        }
        // 2. Slots that overlap or touch it
        while i < slots.count && slots[i][0] <= merged[1] {
            merged[0] = min(merged[0], slots[i][0])
            merged[1] = max(merged[1], slots[i][1])
            i += 1
        }
        result.append(merged)
        // 3. Everything after it
        result.append(contentsOf: slots[i...])
        return result
    }
}
