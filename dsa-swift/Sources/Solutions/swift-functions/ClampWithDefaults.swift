// Reference solution: Clamp with default bounds. Two comparisons, O(1) time and space.

public enum ClampWithDefaults {
    public static func clamp(_ value: Int, lower: Int = 0, upper: Int = 100) -> Int {
        if value < lower {
            return lower
        }
        if value > upper {
            return upper
        }
        return value
    }
}
