// Reference solution: A subarray sum that checks its input. Each precondition becomes a guard that throws,
// in the required order, before any element is read. O(length) time, O(1) extra space.

public enum CheckedSubarraySum {
    public enum RangeError: Error, Equatable {
        case negativeLength(Int)
        case startOutOfBounds(Int)
        case tooLong(available: Int)
    }

    public static func sum(of numbers: [Int], from start: Int, length: Int) throws -> Int {
        guard length >= 0 else {
            throw RangeError.negativeLength(length)
        }
        guard start >= 0 && start <= numbers.count else {
            throw RangeError.startOutOfBounds(start)
        }
        let available = numbers.count - start
        // Compare with what's available rather than computing start + length, which could overflow
        guard length <= available else {
            throw RangeError.tooLong(available: available)
        }
        var total = 0
        for index in start..<(start + length) {
            total += numbers[index]
        }
        return total
    }
}
