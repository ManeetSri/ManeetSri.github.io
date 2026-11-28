// Problem: Longest dry spell (M60 · A generic SegmentTree<T>)

public enum LongestDrySpell {
    /// A weather log with one entry per day: rainy (`true`) or dry (`false`). Entries can be corrected.
    public struct Log {
        // Write your solution here, then run:
        // swift test --filter LongestDrySpellTests
        // Add whatever private storage you need. DSAKit's SegmentTree is available too, with
        // `import DSAKit`, if you'd rather design only the summary and its merge.

        /// Stores the log. `rainy[d]` says whether day d was rainy. Aim for O(n).
        public init(_ rainy: [Bool]) {}

        /// Corrects day `day` to rainy or dry. Aim for O(log n).
        public mutating func setRainy(_ rainy: Bool, on day: Int) {}

        /// The length of the longest run of consecutive dry days within days `start...end`.
        /// Aim for O(log n).
        public func longestDryRun(from start: Int, through end: Int) -> Int {
            return 0
        }
    }
}
