// Problem: Leaderboard with custom tie-breaks (M68 · final, dispatch and generic specialisation)

public enum LeaderboardDispatch {
    /// Anything that can appear on a leaderboard.
    public protocol Entry {
        /// The entry's score: more points rank higher.
        var points: Int { get }
    }

    /// The k best entries, best first: more points, then higher tieBreak, then earlier in the input.
    public static func top<E: Entry>(_ entries: [E], count k: Int) -> [E] {
        // Write your solution here, then run:
        // swift test --filter LeaderboardDispatchTests
        // Read the statement's "trap" first: something in this file needs to change besides these bodies.
        return []
    }

    /// The same ranking for a mixed list of entry types.
    public static func top(mixed entries: [any Entry], count k: Int) -> [any Entry] {
        return []
    }
}

extension LeaderboardDispatch.Entry {
    /// How ties on points are broken: higher wins. Entry types may provide their own; the default is 0.
    public var tieBreak: Int { 0 }
}
