// Problem: Work it out once (M06 · Escaping and non-escaping closures)

public enum ComputeOnce {
    /// Returns a closure whose first call runs `compute` and returns its result.
    /// Later calls return the same result without running `compute` again.
    /// `wrap` itself must not call `compute`.
    ///
    /// This signature is missing one word. Swift will ask for it as soon as
    /// the closure you return uses `compute`.
    public static func wrap(_ compute: () -> Int) -> () -> Int {
        // Write your solution here, then run:
        // swift test --filter ComputeOnceTests
        return { 0 }
    }
}
