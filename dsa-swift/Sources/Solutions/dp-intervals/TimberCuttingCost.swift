// Reference solution: Cheapest way to saw a beam. Sort the marks and add both ends of the beam as
// points. best[left][right] is the cheapest way to make every cut strictly between points[left] and
// points[right]. The first cut on that piece costs its length whichever mark it is at, and leaves two
// independent pieces, so best = length + the cheapest split. The table is indexed by marks, not by
// positions along the beam.
// O(m³) time, O(m²) space for m marks.

public enum TimberCuttingCost {
    public static func minimumCost(length: Int, marks: [Int]) -> Int {
        let points = [0] + marks.sorted() + [length]
        let m = points.count
        guard m >= 3 else { return 0 }
        var best = Array(repeating: Array(repeating: 0, count: m), count: m)
        for gap in 2..<m {
            for left in 0..<(m - gap) {
                let right = left + gap
                var cheapest = Int.max
                for k in (left + 1)..<right {
                    cheapest = min(cheapest, best[left][k] + best[k][right])
                }
                best[left][right] = cheapest + points[right] - points[left]
            }
        }
        return best[0][m - 1]
    }
}
