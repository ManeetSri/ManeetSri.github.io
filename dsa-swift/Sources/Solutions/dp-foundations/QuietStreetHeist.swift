// Reference solution: Rob a quiet street. best[i] = the most from the first i houses, and
// best[i] = max(best[i - 1], best[i - 2] + houses[i - 1]): skip the last house, or rob it and skip its
// neighbour. Each entry reads only the two before it, so two rolling variables are enough.
// O(n) time, O(1) space.

public enum QuietStreetHeist {
    public static func maximumLoot(houses: [Int]) -> Int {
        var (twoBack, oneBack) = (0, 0)
        for cash in houses {
            (twoBack, oneBack) = (oneBack, max(oneBack, twoBack + cash))
        }
        return oneBack
    }
}
