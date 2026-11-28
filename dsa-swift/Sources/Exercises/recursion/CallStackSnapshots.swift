// Problem: Call stack snapshots (M17 · The call stack, visualised)

// The recursion being traced:
//
//     func probe(_ n: Int) {
//         if n == 0 { return }
//         probe(n / 2)
//         probe(n / 3)
//     }

public enum CallStackSnapshots {
    /// The stack (arguments from the first call to the newest) at the moment each call of `probe(n)`
    /// starts, in the order the calls start.
    public static func snapshots(_ n: Int) -> [[Int]] {
        // Write your solution here, then run:
        // swift test --filter CallStackSnapshotsTests
        return []
    }

    /// The argument of each call of `probe(n)`, in the order the calls return.
    public static func returnOrder(_ n: Int) -> [Int] {
        return []
    }
}
