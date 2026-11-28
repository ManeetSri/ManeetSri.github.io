// Reference solution: Spread out the sensors. Sort the points, then binary search on the gap. For a gap
// g, place greedily: the first sensor at the first point, each next one at the first point at least g
// past the previous sensor. If that places every sensor, g works, and so does every smaller gap, so the
// predicate is true … true, false … false: search for the first gap that fails and step back one.
// O(n log n) to sort plus O(n log(span)) to search; O(n) space for the sorted copy.

public enum SensorSpacing {
    public static func widestMinimumGap(points: [Int], sensors: Int) -> Int {
        let sorted = points.sorted()
        let span = sorted[sorted.count - 1] - sorted[0]
        // Gaps 1…span are the candidates; a gap of 1 always works with distinct points.
        // Find the first gap that fails, in 1..<(limit), where the limit counts as failing.
        var low = 1
        var high = span / (sensors - 1) + 1              // sensors - 1 gaps fit in the span
        while low < high {
            let mid = low + (high - low) / 2
            if canPlace(sensors, in: sorted, gap: mid) {
                low = mid + 1                            // mid works: the first failure is later
            } else {
                high = mid
            }
        }
        return low - 1                                   // the last gap that works
    }

    /// True if `count` sensors fit in the sorted points with every pair at least `gap` apart.
    private static func canPlace(_ count: Int, in sorted: [Int], gap: Int) -> Bool {
        var placed = 1
        var last = sorted[0]
        for point in sorted.dropFirst() where point - last >= gap {
            placed += 1
            last = point
            if placed == count { return true }
        }
        return placed >= count
    }
}
