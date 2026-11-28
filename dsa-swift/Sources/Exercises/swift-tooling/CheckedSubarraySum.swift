// Problem: A subarray sum that checks its input (M12 · precondition, assert, fatalError and defer)

public enum CheckedSubarraySum {
    public enum RangeError: Error, Equatable {
        /// `length` was negative.
        case negativeLength(Int)
        /// `start` was below 0 or past the end of the array.
        case startOutOfBounds(Int)
        /// The window runs past the end; at most this many elements are available from `start`.
        case tooLong(available: Int)
    }

    /// The sum of the `length` numbers starting at index `start`, after checking, in this order, that
    /// the length isn't negative, the start is within 0...numbers.count, and the window fits.
    public static func sum(of numbers: [Int], from start: Int, length: Int) throws -> Int {
        // Write your solution here, then run:
        // swift test --filter CheckedSubarraySumTests
        return 0
    }
}
