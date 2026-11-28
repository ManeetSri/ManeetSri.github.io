// Reference solution: Copies while an array grows.
// Doubling: growths happen at capacities 1, 2, 4, … below n, so add them up: O(log n).
// Fixed step: growths happen at counts 1, 1 + step, 1 + 2·step, … below n, an arithmetic series
// with a closed form: O(1). Simulating every append would be O(n), far too slow for 10⁹ appends.

public enum GrowthCopies {
    public static func copiesWhenDoubling(appends n: Int) -> Int {
        var capacity = 1
        var copies = 0
        while capacity < n {          // full at count == capacity, and another append is coming
            copies += capacity
            capacity *= 2
        }
        return copies
    }

    public static func copiesWhenGrowing(by step: Int, appends n: Int) -> Int {
        guard n >= 2 else { return 0 }
        // Growth number m (from 0) happens at count 1 + m·step, as long as that's at most n − 1
        let last = (n - 2) / step
        let growths = last + 1
        // Sum of (1 + m·step) for m = 0...last
        return growths + step * (last * growths / 2)
    }
}
