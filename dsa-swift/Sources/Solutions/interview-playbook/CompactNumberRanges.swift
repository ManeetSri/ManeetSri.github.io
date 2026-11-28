// Reference solution: compact number ranges. Sort, then walk the values once, skipping duplicates and
// closing a run whenever the next value isn't exactly one more. "Exactly one more" is tested without
// arithmetic that can overflow: `previous + 1` traps at Int.max, and `value - previous` traps for
// Int.min and Int.max, so check `previous < Int.max` before adding. O(n log n) time, O(n) space.

public enum CompactNumberRanges {
    public static func summary(_ values: [Int]) -> String {
        let sorted = values.sorted()
        guard var runStart = sorted.first else { return "" }
        var runEnd = runStart
        var parts: [String] = []

        func closeRun() {
            if runStart == runEnd {
                parts.append("\(runStart)")
            } else if runStart < Int.max && runStart + 1 == runEnd {
                parts.append("\(runStart), \(runEnd)")          // a run of two is written as two values
            } else {
                parts.append("\(runStart)...\(runEnd)")
            }
        }

        for value in sorted.dropFirst() where value != runEnd {   // equal values are duplicates
            if runEnd < Int.max && runEnd + 1 == value {
                runEnd = value
            } else {
                closeRun()
                runStart = value
                runEnd = value
            }
        }
        closeRun()
        return parts.joined(separator: ", ")
    }
}
