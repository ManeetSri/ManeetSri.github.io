// Problem: A counter that remembers (M06 · Capturing values)

public enum CounterMaker {
    /// Returns a closure that counts. Its first call returns `start`, and each later call
    /// returns `step` more than the call before. Every counter keeps its own count.
    public static func makeCounter(start: Int = 0, step: Int = 1) -> () -> Int {
        // Write your solution here, then run:
        // swift test --filter CounterMakerTests
        return { 0 }
    }
}
