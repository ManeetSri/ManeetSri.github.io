// Problem: Shared superview (M71 · iOS-flavoured DSA questions)

public enum SharedSuperview {
    /// The nearest view that contains both `a` and `b`, where a view counts as containing itself.
    /// `superviewOf[v]` is the view that directly contains `v`; a view with no entry is a window, the top
    /// of its hierarchy. Returns nil if `a` and `b` are in different windows.
    public static func nearestCommonSuperview(_ a: String, _ b: String, superviewOf: [String: String]) -> String? {
        // Write your solution here, then run:
        // swift test --filter SharedSuperviewTests
        return nil
    }

    /// The views from `a` up to their nearest common superview and back down to `b`, both ends
    /// included. Returns nil if `a` and `b` are in different windows.
    public static func path(from a: String, to b: String, superviewOf: [String: String]) -> [String]? {
        return nil
    }
}
