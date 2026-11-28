// Problem: Nearby close values (M38 · Build an ordered set and map in Swift)

import DSAKit   // DSAKit's SortedSet is here if you want it

public enum NearbyCloseValues {
    /// Returns true if two different positions i and j satisfy both `abs(i - j) <= k` and
    /// `abs(values[i] - values[j]) <= t`: two values that are close in position and close in size.
    public static func exists(in values: [Int], maxIndexGap k: Int, maxValueGap t: Int) -> Bool {
        // Write your solution here, then run:
        // swift test --filter NearbyCloseValuesTests
        return false
    }
}
