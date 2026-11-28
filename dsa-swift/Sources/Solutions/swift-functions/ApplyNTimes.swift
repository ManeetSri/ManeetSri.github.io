// Reference solution: Apply a function n times. n calls to transform, O(n) time, O(1) space.

public enum ApplyNTimes {
    public static func apply(_ transform: (Int) -> Int, times n: Int, to value: Int) -> Int {
        var result = value
        for _ in 0..<n {
            result = transform(result)
        }
        return result
    }
}
