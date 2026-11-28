// Reference solution: Recurrences, level by level. Level i of the recursion tree has aⁱ calls of size
// n / bⁱ, so it does aⁱ × (n / bⁱ)ᵈ work: add up the log_b n + 1 levels. O(log n) levels.

public enum RecurrenceLevelSums {
    public enum MasterCase: Equatable {
        case rootDominates, balanced, leavesDominate
    }

    static func power(_ base: Int, _ exponent: Int) -> Int {
        var result = 1
        for _ in 0..<exponent {
            result *= base
        }
        return result
    }

    public static func work(n: Int, a: Int, b: Int, d: Int) -> Int {
        var total = 0
        var calls = 1
        var size = n
        while true {
            total += calls * power(size, d)   // a whole level at once
            if size == 1 {
                return total                  // the leaves: stop before going further
            }
            calls *= a
            size /= b
        }
    }

    public static func predictedCase(a: Int, b: Int, d: Int) -> MasterCase {
        let split = power(b, d)
        if a < split { return .rootDominates }
        if a == split { return .balanced }
        return .leavesDominate
    }
}
