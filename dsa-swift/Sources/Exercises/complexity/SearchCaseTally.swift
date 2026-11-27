// Problem: Tally the search cases (M14 · Best, average and worst case)

public enum SearchCaseTally {
    /// The fewest and most comparisons any query needed, and the total over all queries.
    public struct Tally: Equatable {
        public var best: Int
        public var worst: Int
        public var total: Int

        public init(best: Int, worst: Int, total: Int) {
            self.best = best
            self.worst = worst
            self.total = total
        }
    }

    /// The comparisons linear search makes for each query (stopping at the first match, or after
    /// every item if there's none), summarised as best, worst and total. Don't run every search.
    public static func tally(items: [Int], queries: [Int]) -> Tally {
        // Write your solution here, then run:
        // swift test --filter SearchCaseTallyTests
        return Tally(best: -1, worst: -1, total: -1)
    }
}
