// Reference solution: Popping bubbles for points. Pad the row with a 1 at each end, which acts like a
// missing neighbour. best[left][right] is the most points from popping every bubble strictly between
// those two positions while they stay. Choosing the bubble popped LAST in that range splits it into two
// independent ranges, and that bubble's neighbours when it pops are exactly left and right.
// O(n³) time, O(n²) space.

public enum BubblePoppingPoints {
    public static func maxPoints(_ bubbles: [Int]) -> Int {
        let values = [1] + bubbles + [1]
        let n = values.count
        guard n >= 3 else { return 0 }
        var best = Array(repeating: Array(repeating: 0, count: n), count: n)
        for gap in 2..<n {
            for left in 0..<(n - gap) {
                let right = left + gap
                let ends = values[left] * values[right]
                var top = 0
                for last in (left + 1)..<right {
                    top = max(top, best[left][last] + best[last][right] + ends * values[last])
                }
                best[left][right] = top
            }
        }
        return best[0][n - 1]
    }
}
