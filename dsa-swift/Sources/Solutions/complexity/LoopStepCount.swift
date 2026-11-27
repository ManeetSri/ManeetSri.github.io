// Reference solution: Count the loop steps. pairChecks uses the triangle formula, O(1).
// shrinkingPasses adds n + n/2 + n/4 + … one pass at a time: O(log n) instead of O(n).

public enum LoopStepCount {
    public static func pairChecks(_ n: Int) -> Int {
        // 0 + 1 + … + (n − 1), which is n(n − 1) / 2; also right for n = 0 and n = 1
        n * (n - 1) / 2
    }

    public static func shrinkingPasses(_ n: Int) -> Int {
        var total = 0
        var size = n
        while size > 0 {
            total += size     // the whole pass, added in one step
            size /= 2
        }
        return total
    }
}
