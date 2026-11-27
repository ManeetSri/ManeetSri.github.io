// Reference solution: Rob the ring road. A plan can't rob both house 0 and the last house, so one of
// them is left alone: run the straight-street DP on houses 1...n - 1 and on houses 0...n - 2, and take
// the better. A single house has no neighbours, so it's robbed on its own. O(n) time, O(1) space.

public enum RingRoadHeist {
    public static func maximumLoot(houses: [Int]) -> Int {
        if houses.count == 1 {
            return houses[0]
        }
        return max(straightStreet(houses.dropFirst()), straightStreet(houses.dropLast()))
    }

    /// House robber on a row. Loops over values, so a slice's original indexes don't matter.
    private static func straightStreet(_ houses: ArraySlice<Int>) -> Int {
        var (twoBack, oneBack) = (0, 0)
        for cash in houses {
            (twoBack, oneBack) = (oneBack, max(oneBack, twoBack + cash))
        }
        return oneBack
    }
}
