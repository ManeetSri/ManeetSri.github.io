// Reference solution: Two unpaired numbers. XOR everything to get a ^ b, pick a bit where a and b
// differ, and XOR only the numbers with that bit set to separate them. O(n) time, O(1) space.

public enum TwoUnpairedNumbers {
    public static func find(in numbers: [Int]) -> [Int] {
        let both = numbers.reduce(0, ^)
        let bit = both & -both
        var first = 0
        for number in numbers where number & bit != 0 {
            first ^= number
        }
        let second = both ^ first
        return [min(first, second), max(first, second)]
    }
}
