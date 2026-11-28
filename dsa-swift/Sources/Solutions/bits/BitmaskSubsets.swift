// Reference solution: Bitmask subsets. Count through the masks 0..<2ⁿ and decode each one bit by bit.
// O(2ⁿ · n) time and space, which is the size of the answer.

public enum BitmaskSubsets {
    public static func subsets(of items: [Int]) -> [[Int]] {
        var result: [[Int]] = []
        for mask in 0..<(1 << items.count) {
            var subset: [Int] = []
            for i in 0..<items.count where mask & (1 << i) != 0 {
                subset.append(items[i])
            }
            result.append(subset)
        }
        return result
    }
}
