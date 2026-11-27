// Reference solution: Fair rewards in a line. A left-to-right pass gives each child 1 more than the
// child on their left when rated higher (otherwise 1), and a right-to-left pass does the same for the
// right neighbour. Each pass gives a lower bound that every valid handout must meet, and the larger of
// the two satisfies both rules, so it's the minimum. O(n) time, O(n) space.

public enum FairRewardsLine {
    public static func fewestRewards(_ ratings: [Int]) -> Int {
        let n = ratings.count
        var rewards = Array(repeating: 1, count: n)
        for i in stride(from: 1, to: n, by: 1) where ratings[i] > ratings[i - 1] {
            rewards[i] = rewards[i - 1] + 1
        }
        var fromRight = 1                  // what the right-neighbour rule alone needs for child i
        var total = n > 0 ? rewards[n - 1] : 0
        for i in stride(from: n - 2, through: 0, by: -1) {
            fromRight = ratings[i] > ratings[i + 1] ? fromRight + 1 : 1
            rewards[i] = max(rewards[i], fromRight)
            total += rewards[i]
        }
        return total
    }
}
