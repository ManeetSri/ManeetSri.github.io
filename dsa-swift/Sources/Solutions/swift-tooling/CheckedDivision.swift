// Reference solution: Division that can't crash. Check the two cases where `/` would trap before dividing,
// and chain divisions by unwrapping each Result with get(). O(1) per division, O(n) for n divisors.

public enum CheckedDivision {
    public enum DivisionError: Error, Equatable {
        case divisionByZero
        case overflow
    }

    public static func divide(_ dividend: Int, by divisor: Int) -> Result<Int, DivisionError> {
        if divisor == 0 {
            return .failure(.divisionByZero)
        }
        if dividend == Int.min && divisor == -1 {
            return .failure(.overflow)   // the answer, Int.max + 1, doesn't fit
        }
        return .success(dividend / divisor)
    }

    public static func divide(_ start: Int, byEach divisors: [Int]) -> Result<Int, DivisionError> {
        var current = start
        for divisor in divisors {
            switch divide(current, by: divisor) {
            case .success(let quotient):
                current = quotient
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(current)
    }
}
