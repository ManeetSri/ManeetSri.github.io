// Reference solution: Earliest minute for the bakery order. By minute t, oven i has finished t / time[i]
// batches (integer division), so "is t enough?" is a quick count, and once t is enough every later minute
// is too. That's a monotonic predicate: binary search on the answer between 1 and the fastest oven's time
// multiplied by the order size (that oven alone would finish by then). Simulating batch by batch with a
// heap is correct but takes O(batches · log n), hopeless for 10^12 batches. The count stops as soon as
// it reaches the order, so it can't overflow even when t is huge.
// O(n log(minTime · batches)) time, O(1) extra space.

public enum BakeryOrderDeadline {
    public static func earliestMinute(bakeTimes: [Int], batches: Int) -> Int {
        guard let fastest = bakeTimes.min() else { return 0 }

        func enough(_ minute: Int) -> Bool {
            var done = 0
            for time in bakeTimes {
                done += minute / time
                if done >= batches { return true }
            }
            return false
        }

        var low = 1
        var high = fastest * batches          // always enough
        while low < high {
            let mid = low + (high - low) / 2
            if enough(mid) {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low
    }
}
