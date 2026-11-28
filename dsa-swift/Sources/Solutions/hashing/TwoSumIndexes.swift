// Reference solution: Two sum with indexes. One pass with a dictionary from value to the first index
// it appeared at. At each j, the partner target - numbers[j] has already been recorded if it exists
// earlier, so the first j that finds one is the smallest j, and the first index stored is the
// smallest i. Checking before recording stops a value pairing with itself. O(n) time, O(n) space.

public enum TwoSumIndexes {
    public static func indexes(in numbers: [Int], summingTo target: Int) -> [Int]? {
        var firstIndex: [Int: Int] = [:]
        for (j, number) in numbers.enumerated() {
            if let i = firstIndex[target - number] {
                return [i, j]
            }
            if firstIndex[number] == nil {
                firstIndex[number] = j
            }
        }
        return nil
    }
}
