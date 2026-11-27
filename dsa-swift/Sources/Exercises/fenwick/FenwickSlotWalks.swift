// Problem: Fenwick slots and walks (M61 · The lowest set bit, i & -i)

public enum FenwickSlotWalks {
    /// The lowest set bit of `i`, for i ≥ 1.
    public static func lowbit(_ i: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter FenwickSlotWalksTests
        return 0
    }

    /// The positions slot `i` of a Fenwick array covers, counting from 1: the lowbit(i) positions
    /// ending at i.
    public static func responsibility(of i: Int) -> ClosedRange<Int> {
        return 0...0
    }

    /// The slots a prefix query for positions 1...i reads, in visiting order. Empty for i = 0.
    public static func queryPath(to i: Int) -> [Int] {
        return []
    }

    /// The slots that change when position `i` changes, in a Fenwick array of `n` slots, in visiting
    /// order.
    public static func updatePath(from i: Int, size n: Int) -> [Int] {
        return []
    }

    /// The slots the sum of positions l...r needs: `add` from r's query walk and `subtract` from
    /// (l − 1)'s, each in visiting order, leaving out every slot that both walks read.
    public static func rangeSlots(from l: Int, through r: Int) -> (add: [Int], subtract: [Int]) {
        return ([], [])
    }
}
