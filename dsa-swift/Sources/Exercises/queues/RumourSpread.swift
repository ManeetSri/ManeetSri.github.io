// Problem: Rumour spread (M27 · A preview of BFS)

public enum RumourSpread {
    /// Each string is a row of desks: "K" someone who knows the rumour, "U" someone who doesn't yet,
    /// "." an empty desk. Every minute, everyone who knows tells the people directly above, below,
    /// left and right of them. Returns the minutes until nobody is left unaware, 0 if nobody is
    /// unaware to begin with, or -1 if someone will never hear it.
    public static func minutesUntilEveryoneKnows(_ seating: [String]) -> Int {
        // Write your solution here, then run:
        // swift test --filter RumourSpreadTests
        return 0
    }
}
