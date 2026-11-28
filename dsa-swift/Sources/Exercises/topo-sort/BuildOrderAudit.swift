// Problem: Audit a build order (M43 · DAGs and dependency ordering)

public enum BuildOrderAudit {
    /// Targets are numbered 0..<targets. Each pair `[target, requirement]` in `needs` means `target`
    /// can only be built after `requirement`. Replays `order` one step at a time and returns the index
    /// of the first step that goes wrong: a number that isn't a target, a target built a second time,
    /// or a target with a requirement not yet built. If every step works but some targets were never
    /// built, returns `order.count`. Returns -1 if `order` is a valid build order of every target.
    public static func firstBadStep(targets: Int, needs: [[Int]], order: [Int]) -> Int {
        // Write your solution here, then run:
        // swift test --filter BuildOrderAuditTests
        return 0
    }
}
