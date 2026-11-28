// Reference solution: Call stack snapshots. Mirror the call stack in a shared array: push when a call
// starts (and snapshot), pop when it returns (and record it). O(calls × depth) for the snapshots.

public enum CallStackSnapshots {
    static func trace(_ n: Int) -> (snapshots: [[Int]], order: [Int]) {
        var stack: [Int] = []
        var snapshots: [[Int]] = []
        var order: [Int] = []

        func probe(_ n: Int) {
            stack.append(n)                      // the frame is pushed
            snapshots.append(stack)
            defer {
                stack.removeLast()               // the frame is popped
                order.append(n)
            }
            if n == 0 {
                return
            }
            probe(n / 2)
            probe(n / 3)
        }

        probe(n)
        return (snapshots, order)
    }

    public static func snapshots(_ n: Int) -> [[Int]] {
        trace(n).snapshots
    }

    public static func returnOrder(_ n: Int) -> [Int] {
        trace(n).order
    }
}
