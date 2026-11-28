// Problem: A score that stays in range (M09 · Property observers and static members)

public enum ClampedScoreTracker {
    public struct Tracker {
        /// The highest score a tracker accepts.
        public static let maximum = 1_000

        // Write your solution here, then run:
        // swift test --filter ClampedScoreTrackerTests

        /// The current score, always kept within 0...Tracker.maximum. Give it a property observer.
        public var current: Int

        /// The highest value `current` has held, including the starting value.
        public private(set) var best: Int

        /// How many times setting `current` actually changed its value, after clamping.
        public private(set) var changes = 0

        /// A tracker starting at `starting`, clamped into range. Starting doesn't count as a change.
        public init(starting: Int) {
            current = starting
            best = 0
        }

        /// A tracker that starts at 0 and then has each score in `scores` set in turn.
        public static func replaying(_ scores: [Int]) -> Tracker {
            return Tracker(starting: 0)
        }
    }
}
