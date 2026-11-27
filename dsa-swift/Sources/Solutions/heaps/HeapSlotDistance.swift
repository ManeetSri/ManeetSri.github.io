// Reference solution: Steps between two heap slots. In a level-by-level layout a larger index is never
// on a shallower level, so while the two positions differ, lift the larger one to its parent,
// (i - 1) / 2, counting steps. They meet at the lowest common ancestor. O(log n) time, O(1) space.

public enum HeapSlotDistance {
    public static func steps(from first: Int, to second: Int) -> Int {
        var a = first
        var b = second
        var steps = 0
        while a != b {
            if a > b {
                a = (a - 1) / 2                      // the larger index is never shallower
            } else {
                b = (b - 1) / 2
            }
            steps += 1
        }
        return steps
    }
}
