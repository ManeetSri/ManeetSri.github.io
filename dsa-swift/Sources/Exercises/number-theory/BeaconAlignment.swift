// Problem: When all the beacons flash (M66 · Fermat's little theorem and CRT)

public enum BeaconAlignment {
    /// Beacon i flashes at every time t ≥ 0 with t % periods[i] == offsets[i]. Returns the earliest time
    /// at which every beacon flashes, or nil if they never all flash together. The lcm of all the periods
    /// is at most 10¹⁸.
    public static func firstSharedFlash(offsets: [Int], periods: [Int]) -> Int? {
        // Write your solution here, then run:
        // swift test --filter BeaconAlignmentTests
        return nil
    }
}
