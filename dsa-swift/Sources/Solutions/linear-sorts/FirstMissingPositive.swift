// Reference solution: First missing positive. The answer is between 1 and n + 1, so only values from
// 1 to n matter. Cyclic sort sends each of those to index v − 1 and ignores everything else; then
// the first index i not holding i + 1 gives the answer, or n + 1 if every index is right.
// The range check comes first, so no out-of-range value is used as an index, and `value - 1` is
// never computed for Int.min. O(n) time, O(1) extra space.

public enum FirstMissingPositive {
    public static func find(in numbers: inout [Int]) -> Int {
        let n = numbers.count
        var i = 0
        while i < n {
            let value = numbers[i]
            if value >= 1 && value <= n && numbers[value - 1] != value {
                numbers.swapAt(i, value - 1)              // send it home
            } else {
                i += 1                                    // out of range, a spare copy, or home
            }
        }
        for index in 0..<n where numbers[index] != index + 1 {
            return index + 1
        }
        return n + 1
    }
}
