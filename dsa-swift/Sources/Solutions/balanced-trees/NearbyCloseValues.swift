// Reference solution: Nearby close values. Slide a window over the last k values, kept in a sorted set.
// For each new value x, the only window value that matters is the smallest one ≥ x - t (the ceiling):
// if even that one is above x + t, nothing in the window is within t of x. Then add x and drop the value
// that has fallen k places behind. If a value repeats inside the window, the ceiling finds it (a gap of
// 0 is always close enough), so the set never needs to hold duplicates. O(n log k) time, O(k) space.

import DSAKit

public enum NearbyCloseValues {
    public static func exists(in values: [Int], maxIndexGap k: Int, maxValueGap t: Int) -> Bool {
        guard k > 0 else { return false }
        var window = SortedSet<Int>()
        for (i, x) in values.enumerated() {
            if let nearest = window.ceiling(x - t), nearest <= x + t {
                return true
            }
            window.insert(x)
            if i >= k {
                window.remove(values[i - k])                 // keep only the last k values
            }
        }
        return false
    }
}
