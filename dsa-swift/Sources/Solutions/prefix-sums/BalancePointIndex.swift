// Reference solution: Balance point. With the total known, the right-hand sum at i is
// total - leftSum - numbers[i], so one running sum is enough. O(n) time, O(1) extra space.

public enum BalancePointIndex {
    public static func balancePoint(in numbers: [Int]) -> Int? {
        let total = numbers.reduce(0, +)
        var leftSum = 0
        for (i, value) in numbers.enumerated() {
            if leftSum == total - leftSum - value {
                return i
            }
            leftSum += value
        }
        return nil
    }
}
