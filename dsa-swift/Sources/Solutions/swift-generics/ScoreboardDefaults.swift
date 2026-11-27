// Reference solution: Scoreboards with defaults. The protocol extension gives every conforming type a
// default ranking() plus three bonus members written in terms of it. GolfCard replaces only ranking(),
// and the bonus members follow along because ranking() is a requirement. Ranking sorts: O(n log n).

public enum ScoreboardDefaults {
    public protocol Scoreboard {
        var scores: [Int] { get }
        func ranking() -> [Int]
    }

    public struct ArcadeBoard: Scoreboard {
        public var scores: [Int]

        public init(scores: [Int]) {
            self.scores = scores
        }
    }

    public struct GolfCard: Scoreboard {
        public var scores: [Int]

        public init(scores: [Int]) {
            self.scores = scores
        }

        // In golf the lowest score is the best
        public func ranking() -> [Int] {
            scores.sorted()
        }
    }
}

extension ScoreboardDefaults.Scoreboard {
    public func ranking() -> [Int] {
        scores.sorted(by: >)
    }

    public var totalScore: Int {
        scores.reduce(0, +)
    }

    public var bestScore: Int? {
        ranking().first
    }

    public func topScores(_ count: Int) -> [Int] {
        Array(ranking().prefix(max(count, 0)))
    }
}

// A plain array of Ints becomes a scoreboard, gaining every default above
extension Array: ScoreboardDefaults.Scoreboard where Element == Int {
    public var scores: [Int] {
        self
    }
}
