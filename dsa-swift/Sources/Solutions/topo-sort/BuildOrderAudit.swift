// Reference solution: Audit a build order. Replay the order one step at a time, keeping a `built` flag
// per target. A step fails if its number isn't a target, if that target is already built, or if any of
// its requirements isn't built yet. Each requirement list is read once, when its target's step comes,
// so the replay is O(targets + needs + order) time and O(targets + needs) space.

public enum BuildOrderAudit {
    public static func firstBadStep(targets: Int, needs: [[Int]], order: [Int]) -> Int {
        // requirements[t]: what target t needs built before it. Edge requirement → t, "before → after".
        var requirements: [[Int]] = Array(repeating: [], count: targets)
        for pair in needs {
            requirements[pair[0]].append(pair[1])
        }
        var built = Array(repeating: false, count: targets)
        for (step, target) in order.enumerated() {
            guard (0..<targets).contains(target), !built[target] else { return step }   // unknown or twice
            if requirements[target].contains(where: { !built[$0] }) {
                return step                          // an edge pointing backwards (or a self-dependency)
            }
            built[target] = true
        }
        // No step failed, so every target in the order is distinct. Any left over were never built.
        return order.count < targets ? order.count : -1
    }
}
