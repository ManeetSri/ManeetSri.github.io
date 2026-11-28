// Reference solution: Largest square of ones. side[c] is the side of the largest all-ones square whose
// bottom-right corner is column c of the current row: 0 for a 0 cell, otherwise 1 + the minimum of the
// square ending above, to the left and diagonally above-left, because the weakest of the three limits
// it. One row of sides is kept, with the diagonal saved before it's overwritten. O(rows × cols) time,
// O(cols) space.

public enum LargestSquareOfOnes {
    public static func largestArea(_ field: [[Int]]) -> Int {
        guard let cols = field.first?.count else { return 0 }
        var side = Array(repeating: 0, count: cols + 1)   // side[c + 1] is column c; side[0] stays 0
        var largest = 0
        for row in field {
            var diagonal = 0
            for c in 0..<cols {
                let above = side[c + 1]
                side[c + 1] = row[c] == 1 ? 1 + min(above, side[c], diagonal) : 0
                diagonal = above
                largest = max(largest, side[c + 1])
            }
        }
        return largest * largest
    }
}
