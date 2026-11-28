// Reference solution: Fenwick slots and walks. `i & -i` is the lowest set bit; slot i covers the
// lowbit(i) positions ending at i. The query walk strips the lowest bit, the update walk adds it. For a
// range, both prefix walks share a common tail, so walk them together, always stepping the larger index,
// until they meet. Every walk is O(log i).

public enum FenwickSlotWalks {
    public static func lowbit(_ i: Int) -> Int {
        i & -i
    }

    public static func responsibility(of i: Int) -> ClosedRange<Int> {
        (i - lowbit(i) + 1)...i
    }

    public static func queryPath(to i: Int) -> [Int] {
        var path: [Int] = []
        var slot = i
        while slot > 0 {
            path.append(slot)
            slot -= lowbit(slot)                  // remove the lowest set bit
        }
        return path
    }

    public static func updatePath(from i: Int, size n: Int) -> [Int] {
        var path: [Int] = []
        var slot = i
        while slot <= n {
            path.append(slot)
            slot += lowbit(slot)                  // add the lowest set bit: it carries upwards
        }
        return path
    }

    public static func rangeSlots(from l: Int, through r: Int) -> (add: [Int], subtract: [Int]) {
        var add: [Int] = []
        var subtract: [Int] = []
        var a = r
        var b = l - 1
        while a != b {                            // once they meet, the rest of both walks is shared
            if a > b {
                add.append(a)
                a -= lowbit(a)
            } else {
                subtract.append(b)
                b -= lowbit(b)
            }
        }
        return (add, subtract)
    }
}
