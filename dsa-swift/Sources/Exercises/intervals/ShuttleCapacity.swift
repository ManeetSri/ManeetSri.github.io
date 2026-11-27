// Problem: Shuttle capacity (M33 · Sweep-line events)

public enum ShuttleCapacity {
    /// Each trip is `[passengers, pickUp, dropOff]`, with `pickUp < dropOff`. The shuttle drives one
    /// way, from stop 0 upwards. At each stop, riders leave before new riders board. Returns whether
    /// the shuttle never has more than `capacity` people on board.
    public static func canCarryAll(_ trips: [[Int]], capacity: Int) -> Bool {
        // Write your solution here, then run:
        // swift test --filter ShuttleCapacityTests
        return false
    }
}
