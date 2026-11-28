// Reference solution: Loading the van. continue skips a misread parcel; break ends loading at the
// first parcel that doesn't fit. O(n) time, O(1) extra space.

public enum VanParcelLoading {
    public static func loadedCount(_ weights: [Int], capacity: Int) -> Int {
        var load = 0
        var loaded = 0
        for weight in weights {
            if weight <= 0 {
                continue // a misread label: skip this parcel only
            }
            if load + weight > capacity {
                break // the van leaves; nothing behind this parcel is loaded
            }
            load += weight
            loaded += 1
        }
        return loaded
    }
}
