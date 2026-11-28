// Reference solution: A score that stays in range. One didSet clamps the new value, then updates best and
// changes. Assigning to `current` inside its own didSet doesn't run the observer again. Every operation
// is O(1); replaying n scores is O(n).

public enum ClampedScoreTracker {
    public struct Tracker {
        public static let maximum = 1_000

        public var current: Int {
            didSet {
                current = Tracker.clamped(current)
                if current != oldValue {
                    changes += 1
                }
                if current > best {
                    best = current
                }
            }
        }

        public private(set) var best: Int
        public private(set) var changes = 0

        // Observers don't run during init, so the initialiser has to clamp too
        public init(starting: Int) {
            let start = Tracker.clamped(starting)
            current = start
            best = start
        }

        private static func clamped(_ value: Int) -> Int {
            min(max(value, 0), maximum)
        }

        public static func replaying(_ scores: [Int]) -> Tracker {
            var tracker = Tracker(starting: 0)
            for score in scores {
                tracker.current = score
            }
            return tracker
        }
    }
}
