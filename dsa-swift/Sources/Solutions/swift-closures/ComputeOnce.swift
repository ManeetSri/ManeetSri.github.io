// Reference solution: Work it out once. The returned closure keeps `compute` for later, so the
// parameter is @escaping, and captures an optional that remembers the result once it exists.
// O(1) per call after the first, O(1) space.

public enum ComputeOnce {
    public static func wrap(_ compute: @escaping () -> Int) -> () -> Int {
        var remembered: Int? = nil
        return {
            if let value = remembered {
                return value
            }
            let value = compute()
            remembered = value
            return value
        }
    }
}
