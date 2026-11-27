// Reference solution: Smallest and largest in one pass. O(n) time, O(1) extra space.

public enum MinAndMaxTogether {
    public static func minAndMax(of numbers: [Int]) -> (min: Int, max: Int)? {
        guard let first = numbers.first else { return nil }
        var smallest = first
        var largest = first
        for number in numbers.dropFirst() {
            if number < smallest {
                smallest = number
            } else if number > largest {
                largest = number
            }
        }
        return (min: smallest, max: largest)
    }
}
