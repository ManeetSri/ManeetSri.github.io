// Problem: Find a circular dependency (M42 · Cycle detection in undirected and directed graphs)

public enum DependencyCycleFinder {
    /// Modules are numbered 0..<modules, and [a, b] in dependencies means a depends on b. Returns
    /// modules [m0, m1, …, mk] where each depends on the next and mk depends on m0, or [] if there
    /// is no circular dependency.
    public static func cycle(_ modules: Int, dependencies: [[Int]]) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter DependencyCycleFinderTests
        return []
    }
}
