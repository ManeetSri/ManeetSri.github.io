// Reference solution: Commuter pass planner. Greedy rules ("buy the long pass when the days are dense")
// fail on small examples, so use dynamic programming. State: cost[i] is the cheapest way to cover travel
// days i, i + 1, …, n - 1. Transition: the earliest uncovered day, days[i], must be covered by some pass
// bought on that day (buying it earlier would waste coverage), and a pass of length L then covers every
// travel day before days[i] + L; the plan continues from the first travel day after that. Base: cost[n] = 0.
// Order: i from n - 1 down to 0. Answer: cost[0]. As i falls, each pass's "first day after" index only
// moves left, so one pointer per pass replaces a binary search.
// O(n · p) time for n travel days and p passes, O(n + p) space.

public enum CommuterPassPlanner {
    public static func cheapestCost(travelDays: [Int], passes: [[Int]]) -> Int {
        let n = travelDays.count
        var cost = Array(repeating: 0, count: n + 1)
        var after = Array(repeating: n, count: passes.count)   // for each pass, the first day it doesn't cover
        for i in stride(from: n - 1, through: 0, by: -1) {
            var best = Int.max
            for (p, pass) in passes.enumerated() {
                let firstUncovered = travelDays[i] + pass[0]
                while after[p] > i + 1, travelDays[after[p] - 1] >= firstUncovered {
                    after[p] -= 1
                }
                best = min(best, pass[1] + cost[after[p]])
            }
            cost[i] = best
        }
        return cost[0]
    }
}
