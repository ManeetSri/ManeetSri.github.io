// Reference solution: Count the calls.
// split: the recursion tree has n leaves (calls of size 1) and n − 1 calls that split, so 2n − 1: O(1).
// fibonacci: the counts obey C(n) = 1 + C(n − 1) + C(n − 2), computed bottom-up in O(n) time,
// although the recursion itself makes exponentially many calls.

public enum RecursiveCallCount {
    public static func splitCalls(_ n: Int) -> Int {
        n == 0 ? 1 : 2 * n - 1
    }

    public static func fibonacciCalls(_ n: Int) -> Int {
        if n < 2 {
            return 1
        }
        var beforePrevious = 1   // C(0)
        var previous = 1         // C(1)
        for _ in 2...n {
            (beforePrevious, previous) = (previous, 1 + previous + beforePrevious)
        }
        return previous
    }
}
