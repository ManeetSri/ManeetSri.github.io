// Problem: Lineage queries (M47 · LCA with binary lifting)

public enum LineageQueries {
    /// For each query [person, k], the ancestor k generations above person (k = 0 is the person
    /// themselves), or -1 if the family tree doesn't go back that far. `parent[root]` is -1.
    public static func kthAncestors(parent: [Int], queries: [[Int]]) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter LineageQueriesTests
        return []
    }

    /// For each query [a, b], the lowest common ancestor of a and b: the deepest person who is an
    /// ancestor of both (a person counts as their own ancestor).
    public static func lowestCommonAncestors(parent: [Int], queries: [[Int]]) -> [Int] {
        return []
    }
}
