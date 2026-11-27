// Reference solution: The first negative number. A linear search that returns as soon as it finds a
// match, and nil when the loop ends without one. O(n) time, O(1) space.

public enum FirstNegativeIndex {
    public static func find(in numbers: [Int]) -> Int? {
        for index in 0..<numbers.count where numbers[index] < 0 {
            return index
        }
        return nil
    }
}
