// Reference solution: Nesting gift boxes. Turn every box so its shorter side comes first; a box can be
// turned to fit inside another exactly when it fits with both turned that way. Then it's Russian doll
// envelopes: sort by the shorter side ascending and, for equal shorter sides, the longer side
// descending, so at most one box per shorter side can join a strictly rising run. The answer is the
// longest strictly increasing subsequence of the longer sides, found with patience sorting.
// O(n log n) time, O(n) space.

public enum NestingGiftBoxes {
    public static func deepestNesting(_ boxes: [[Int]]) -> Int {
        let turned = boxes.map { (short: min($0[0], $0[1]), long: max($0[0], $0[1])) }
        let longSides = turned
            .sorted { $0.short != $1.short ? $0.short < $1.short : $0.long > $1.long }
            .map(\.long)
        var tails: [Int] = []
        for side in longSides {
            var low = 0
            var high = tails.count
            while low < high {                          // the first tail >= side
                let mid = low + (high - low) / 2
                if tails[mid] >= side {
                    high = mid
                } else {
                    low = mid + 1
                }
            }
            if low == tails.count {
                tails.append(side)
            } else {
                tails[low] = side
            }
        }
        return tails.count
    }
}
