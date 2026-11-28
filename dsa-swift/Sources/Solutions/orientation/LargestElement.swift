// Reference solution: The largest number. One pass, O(n) time, O(1) extra space.

public enum LargestElement {
    public static func largest(in numbers: [Int]) -> Int? {
        guard var best = numbers.first else { return nil }
        for number in numbers.dropFirst() where number > best {
            best = number
        }
        return best
    }
}
