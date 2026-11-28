// Reference solution: Sum the real numbers. Int(text) does the validating; an optional total stays nil
// until the first valid number arrives. O(n) time for n strings, O(1) extra space.

public enum ValidNumberSum {
    public static func sum(of texts: [String]) -> Int? {
        var total: Int? = nil
        for text in texts {
            if let number = Int(text) {
                total = (total ?? 0) + number
            }
        }
        return total
    }
}
