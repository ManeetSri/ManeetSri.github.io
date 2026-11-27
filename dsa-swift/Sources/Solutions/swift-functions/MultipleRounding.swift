// Reference solution: Round to a multiple. Rounding down fixes the sign of `%` for negative
// values; rounding up and to the nearest build on it. Three overloads told apart by their labels.
// O(1) time and space each.

public enum MultipleRounding {
    public static func rounded(_ value: Int, downToMultipleOf step: Int) -> Int {
        let remainder = value % step
        if remainder < 0 {
            return value - remainder - step
        }
        return value - remainder
    }

    public static func rounded(_ value: Int, upToMultipleOf step: Int) -> Int {
        let down = rounded(value, downToMultipleOf: step)
        return down == value ? value : down + step
    }

    public static func rounded(_ value: Int, toNearestMultipleOf step: Int) -> Int {
        let down = rounded(value, downToMultipleOf: step)
        let up = rounded(value, upToMultipleOf: step)
        return value - down < up - value ? down : up
    }
}
