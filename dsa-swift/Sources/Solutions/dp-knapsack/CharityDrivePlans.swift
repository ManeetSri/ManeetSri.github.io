// Reference solution: Charity drive plans. A counting 0/1 knapsack with two dimensions: volunteers (a
// budget) and money (a goal, clamped so that column `goal` means "goal or more"). ways[v][f] counts plans
// using at most v volunteers whose clamped money is f; the empty plan fits every budget, so ways[v][0]
// starts at 1. Each project pushes ways[v - need][f] into ways[v][min(goal, f + raise)], with both loops
// downward so no project is used twice. O(n · volunteers · goal) time, O(volunteers · goal) space.

public enum CharityDrivePlans {
    public static func count(volunteers: Int, goal: Int, needs: [Int], raises: [Int]) -> Int {
        let mod = 1_000_000_007
        var ways = Array(repeating: Array(repeating: 0, count: goal + 1), count: volunteers + 1)
        for v in 0...volunteers {
            ways[v][0] = 1
        }
        for (need, raise) in zip(needs, raises) where need <= volunteers {
            for v in stride(from: volunteers, through: need, by: -1) {
                for f in stride(from: goal, through: 0, by: -1) {
                    let capped = min(goal, f + raise)
                    ways[v][capped] = (ways[v][capped] + ways[v - need][f]) % mod
                }
            }
        }
        return ways[volunteers][goal]
    }
}
