// Problem: Scoreboards with defaults (M10 · Extensions and protocol extensions)

public enum ScoreboardDefaults {
    public protocol Scoreboard {
        /// Every score, in the order it was recorded.
        var scores: [Int] { get }
        /// The scores from best to worst.
        func ranking() -> [Int]
    }

    /// An arcade machine's board. It uses the default ranking: higher scores are better.
    public struct ArcadeBoard: Scoreboard {
        public var scores: [Int]

        public init(scores: [Int]) {
            self.scores = scores
        }
    }

    /// A golf scorecard, where lower scores are better.
    public struct GolfCard: Scoreboard {
        public var scores: [Int]

        public init(scores: [Int]) {
            self.scores = scores
        }

        // Give GolfCard its own ranking(), with the lowest score first.
    }
}

// Write your solution here, then run:
// swift test --filter ScoreboardDefaultsTests

extension ScoreboardDefaults.Scoreboard {
    /// The default ranking: every score, highest first.
    public func ranking() -> [Int] {
        return []
    }

    /// The sum of every score.
    public var totalScore: Int {
        return 0
    }

    /// The first score in the ranking, or nil if there are no scores.
    public var bestScore: Int? {
        return nil
    }

    /// The first `count` scores of the ranking (all of them if there are fewer, none if `count` ≤ 0).
    public func topScores(_ count: Int) -> [Int] {
        return []
    }
}

/// Every [Int] is a scoreboard of its own elements.
extension Array: ScoreboardDefaults.Scoreboard where Element == Int {
    public var scores: [Int] {
        return []
    }
}
