// Problem: Shared recording windows (M33 · Interval intersections and free time)

public enum SharedRecordingWindows {
    /// Each list holds one camera's recording windows, sorted by start, with no two windows in the
    /// same list sharing a second. A window is a closed `[start, end]` pair covering every second from
    /// `start` to `end`. Returns the windows when both cameras were recording, sorted by start.
    public static func sharedWindows(_ first: [[Int]], _ second: [[Int]]) -> [[Int]] {
        // Write your solution here, then run:
        // swift test --filter SharedRecordingWindowsTests
        return []
    }
}
