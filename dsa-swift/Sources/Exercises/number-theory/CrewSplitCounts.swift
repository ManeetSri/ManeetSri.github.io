// Problem: Ways to split tasks among crews (M66 · Catalan, Stirling and Bell numbers)

public enum CrewSplitCounts {
    /// Precomputes counting tables up to `maxTasks`, then answers each question in O(1), modulo
    /// 1,000,000,007.
    public struct Planner {
        // Write your solution here, then run:
        // swift test --filter CrewSplitCountsTests
        // Add whatever private storage you need: the tables the initialiser fills.

        /// Builds the tables for up to `maxTasks` tasks (0...1,000). O(maxTasks²).
        public init(maxTasks: Int) {}

        /// Ways to split n distinct tasks into exactly k non-empty crews without names.
        public func unnamedCrews(tasks n: Int, crews k: Int) -> Int {
            return 0
        }

        /// Ways to split n distinct tasks into exactly k non-empty named crews.
        public func namedCrews(tasks n: Int, crews k: Int) -> Int {
            return 0
        }

        /// Ways to split n distinct tasks into any number of non-empty crews without names.
        public func anyCrews(tasks n: Int) -> Int {
            return 0
        }

        /// Ways to seat n people at exactly k identical round tables, none empty.
        public func roundTables(people n: Int, tables k: Int) -> Int {
            return 0
        }
    }
}
