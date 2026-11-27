// Reference solution: Walk the Gray code. Decode by XORing every right shift; walk subsets by updating
// the one item that changes at step i, bit i.trailingZeroBitCount. O(2ⁿ) for the walk.

public enum GrayCodeWalk {
    public static func sequence(width: Int) -> [Int] {
        (0..<(1 << width)).map { $0 ^ ($0 >> 1) }
    }

    public static func step(ofCode code: Int) -> Int {
        var value = code
        var shifted = code >> 1
        while shifted != 0 {
            value ^= shifted                     // bit k of i is the XOR of the Gray bits at or above k
            shifted >>= 1
        }
        return value
    }

    public static func subsetTotals(_ prices: [Int]) -> [Int] {
        var totals = [0]                         // step 0: the empty subset
        totals.reserveCapacity(1 << prices.count)
        var total = 0
        for i in 1..<(1 << prices.count) {
            let item = i.trailingZeroBitCount    // the only bit that changes
            let gray = i ^ (i >> 1)
            if gray & (1 << item) != 0 {
                total += prices[item]            // it joined
            } else {
                total -= prices[item]            // it left
            }
            totals.append(total)
        }
        return totals
    }
}
