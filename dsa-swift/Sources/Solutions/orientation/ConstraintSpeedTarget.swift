// Reference solution: What speed do the constraints ask for? A switch tries the limits from the
// smallest up and stops at the first one maxN doesn't exceed. O(1) time and space.

public enum ConstraintSpeedTarget {
    public static func aim(forMaxN maxN: Int) -> String {
        switch maxN {
        case ...10: return "O(n!)"
        case ...20: return "O(2^n)"
        case ...500: return "O(n^3)"
        case ...5_000: return "O(n^2)"
        case ...1_000_000: return "O(n log n)"
        default: return "O(log n)"
        }
    }
}
