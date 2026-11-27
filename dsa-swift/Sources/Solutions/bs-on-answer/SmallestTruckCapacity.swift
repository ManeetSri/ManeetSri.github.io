// Reference solution: Smallest truck capacity. Binary search on the capacity. For a given capacity, load
// greedily: keep adding parcels in order, and start a new day when the next one wouldn't fit. More
// capacity never needs more days, so "fits in the days" is monotonic. The answer lies between the
// heaviest parcel (anything less can never carry it) and the total weight (one day carries everything).
// O(n log(sum)) time, O(1) space.

public enum SmallestTruckCapacity {
    public static func minimumCapacity(parcels: [Int], days: Int) -> Int {
        var low = parcels.max()!
        var high = parcels.reduce(0, +)
        while low < high {
            let mid = low + (high - low) / 2
            if daysNeeded(parcels, capacity: mid) <= days {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low
    }

    /// Days the greedy loading takes. Needs capacity ≥ the heaviest parcel.
    private static func daysNeeded(_ parcels: [Int], capacity: Int) -> Int {
        var days = 1
        var load = 0
        for weight in parcels {
            if load + weight > capacity {            // doesn't fit: it goes on tomorrow's truck
                days += 1
                load = 0
            }
            load += weight
        }
        return days
    }
}
