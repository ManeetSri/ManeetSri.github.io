// Reference solution: A counter that remembers. The closure captures its own `next` variable.
// Each call is O(1) time, and each counter stores one Int.

public enum CounterMaker {
    public static func makeCounter(start: Int = 0, step: Int = 1) -> () -> Int {
        var next = start
        return {
            let current = next
            next += step
            return current
        }
    }
}
