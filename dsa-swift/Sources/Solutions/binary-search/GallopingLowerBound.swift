// Reference solution: First reading at least a target, length unknown. Gallop: read index 1, 2, 4, 8,
// … until the reading is nil or at least target. The previous index read was below target, so the
// answer lies in (bound / 2, bound], and a lower-bound binary search finds it, treating nil (past the
// end) like a reading that's too big. If the answer p is past the end, there's no such reading.
// O(log p) reads, O(1) space.

public enum GallopingLowerBound {
    public static func firstIndex(atLeast target: Int, reading value: (Int) -> Int?) -> Int? {
        guard let first = value(0) else { return nil }          // no readings at all
        if first >= target { return 0 }
        // 1. Gallop: index bound / 2 is known to be below target
        var bound = 1
        while let reading = value(bound), reading < target {
            bound *= 2
        }
        // 2. The answer is in (bound / 2, bound]. Find the first index that is nil or ≥ target.
        var low = bound / 2 + 1
        var high = bound
        while low < high {
            let mid = low + (high - low) / 2
            if let reading = value(mid), reading < target {
                low = mid + 1                                    // a real reading, still too small
            } else {
                high = mid                                       // big enough, or past the end
            }
        }
        return value(low) == nil ? nil : low                     // past the end means "none"
    }
}
