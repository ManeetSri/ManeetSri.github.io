// Problem: Turn penalty routes (M74 · A route planner with Dijkstra and A*)

public enum TurnPenaltyRoutes {
    /// The cheapest trip from `start` to `goal`: the lengths of the roads driven, plus
    /// `leftTurnPenalty` for every left turn, with no U-turns. `places[i]` is `[x, y]` (y points
    /// north) and each road is `[a, b, length]`, usable both ways. Nil if `goal` can't be reached.
    public static func cheapest(places: [[Int]], roads: [[Int]], from start: Int, to goal: Int,
                                leftTurnPenalty: Int) -> Int? {
        // Write your solution here, then run:
        // swift test --filter TurnPenaltyRoutesTests
        return -1
    }
}
