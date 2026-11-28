// Reference solution: Keep it in range. max lifts anything below the range up to lowerBound, then
// min brings anything above it down to upperBound. O(1) time and space.

public enum RangeClamp {
    public static func clamp(_ value: Int, to range: ClosedRange<Int>) -> Int {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
