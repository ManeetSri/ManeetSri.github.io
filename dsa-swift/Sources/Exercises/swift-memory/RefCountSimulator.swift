// Problem: Counting references by hand (M11 · Automatic Reference Counting)

public enum RefCountSimulator {
    public struct Outcome: Equatable {
        /// The ids of the objects freed, in the order they were freed.
        public let freed: [Int]
        /// The ids of the objects still alive at the end, smallest first.
        public let alive: [Int]

        public init(freed: [Int], alive: [Int]) {
            self.freed = freed
            self.alive = alive
        }
    }

    /// Plays out `commands` the way ARC would. Each object has one optional strong property, `next`.
    ///
    /// - "new a 1": creates object 1 and stores it in variable `a`.
    /// - "set b a": `b = a` (so `b` becomes empty if `a` is).
    /// - "clear a": `a = nil`.
    /// - "link a b": `a.next = b`, for the object in `a`.
    /// - "unlink a": `a.next = nil`.
    /// - "follow a": `a = a.next`.
    ///
    /// When a reference is replaced, the new object gains its reference before the old one loses
    /// its own. An object whose count reaches zero is freed at once, and then its `next` lets go.
    public static func simulate(_ commands: [String]) -> Outcome {
        // Write your solution here, then run:
        // swift test --filter RefCountSimulatorTests
        return Outcome(freed: [], alive: [])
    }
}
