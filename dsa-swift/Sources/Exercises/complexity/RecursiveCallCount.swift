// Problem: Count the calls (M14 · Recurrences: substitution and recursion trees)

public enum RecursiveCallCount {
    /// How many times `split` is called, counting the first call, when you call `split(n)`:
    ///
    ///     func split(_ n: Int) {
    ///         if n <= 1 { return }
    ///         split(n / 2)
    ///         split(n - n / 2)
    ///     }
    public static func splitCalls(_ n: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter RecursiveCallCountTests
        return 0
    }

    /// How many times `fibonacci` is called, counting the first call, when you call `fibonacci(n)`:
    ///
    ///     func fibonacci(_ n: Int) -> Int {
    ///         if n < 2 { return n }
    ///         return fibonacci(n - 1) + fibonacci(n - 2)
    ///     }
    ///
    /// Don't run the recursion: it's far too slow for large n.
    public static func fibonacciCalls(_ n: Int) -> Int {
        return 0
    }
}
