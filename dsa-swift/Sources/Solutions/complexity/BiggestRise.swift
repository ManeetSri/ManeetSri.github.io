// Reference solution: The biggest rise. One pass, remembering the lowest reading so far, so each
// reading is compared with the best possible earlier one: O(n) time, O(1) extra space.

public enum BiggestRise {
    public static func biggestRise(in readings: [Int]) -> Int? {
        guard readings.count >= 2 else { return nil }
        var lowest = readings[0]
        var best = readings[1] - readings[0]
        for reading in readings.dropFirst() {
            best = max(best, reading - lowest)   // compare with the lowest *earlier* reading
            lowest = min(lowest, reading)        // then let this reading count for later ones
        }
        return best
    }
}
