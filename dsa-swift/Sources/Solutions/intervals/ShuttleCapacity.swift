// Reference solution: Shuttle capacity. A difference array over the stops: each trip adds its
// passengers at the pick-up stop and removes them at the drop-off stop (riders are on board for the
// half-open stretch [pickUp, dropOff)). A running sum gives the load after each stop.
// O(n + S) time and O(S) space, where S is the last drop-off stop.
// With huge stop numbers, sort (stop, change) events instead: O(n log n).

public enum ShuttleCapacity {
    public static func canCarryAll(_ trips: [[Int]], capacity: Int) -> Bool {
        let lastStop = trips.map { $0[2] }.max() ?? 0
        var change = Array(repeating: 0, count: lastStop + 1)
        for trip in trips {
            change[trip[1]] += trip[0]
            change[trip[2]] -= trip[0]
        }
        var onBoard = 0
        for delta in change {
            onBoard += delta
            if onBoard > capacity {
                return false
            }
        }
        return true
    }
}
