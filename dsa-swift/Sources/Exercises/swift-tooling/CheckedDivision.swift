// Problem: Division that can't crash (M12 · throws, try and Result)

public enum CheckedDivision {
    public enum DivisionError: Error, Equatable {
        /// The divisor was zero.
        case divisionByZero
        /// The exact answer doesn't fit in an Int (only Int.min / -1).
        case overflow
    }

    /// `dividend / divisor`, rounded towards zero like Swift's `/`, or the reason it can't be computed.
    public static func divide(_ dividend: Int, by divisor: Int) -> Result<Int, DivisionError> {
        // Write your solution here, then run:
        // swift test --filter CheckedDivisionTests
        return .success(0)
    }

    /// Divides `start` by each divisor in turn, left to right, and stops at the first failure.
    public static func divide(_ start: Int, byEach divisors: [Int]) -> Result<Int, DivisionError> {
        return .success(0)
    }
}
