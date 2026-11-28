// Kata: Weighted decision matrix (D01 · Making "it depends" concrete with decision matrices)
import DesignKit
import Foundation

public enum QualityDecisionMatrix {
    /// One thing the options are judged on, such as "Migration safety"
    public struct Criterion: Sendable, Equatable {
        public let name: String
        /// How much this criterion matters relative to the others. Must be more than zero.
        public let weight: Double
        /// A must-have: an option scoring below this is eliminated, however well it does elsewhere
        public let minimum: Double?

        public init(_ name: String, weight: Double, minimum: Double? = nil) {
            self.name = name
            self.weight = weight
            self.minimum = minimum
        }
    }

    /// One candidate, with a score for every criterion, keyed by the criterion's name
    public struct Option: Sendable, Equatable {
        public let name: String
        public let scores: [String: Double]

        public init(_ name: String, scores: [String: Double]) {
            self.name = name
            self.scores = scores
        }
    }

    /// An option and its weighted score: Σ(weight × score) ÷ Σ weight, on the same scale as the scores
    public struct Ranked: Sendable, Equatable {
        public let name: String
        public let score: Double

        public init(name: String, score: Double) {
            self.name = name
            self.score = score
        }
    }

    public struct Decision: Sendable, Equatable {
        /// The options that meet every minimum, highest score first; equal scores in alphabetical order
        public let ranking: [Ranked]
        /// The options that missed a minimum, in the order they were given
        public let eliminated: [String]

        public init(ranking: [Ranked], eliminated: [String]) {
            self.ranking = ranking
            self.eliminated = eliminated
        }

        public var winner: String? { ranking.first?.name }
    }

    public enum MatrixError: Error, Equatable {
        /// There's nothing to judge the options on
        case noCriteria
        /// The first criterion whose weight isn't a finite number above zero
        case invalidWeight(criterion: String)
        /// The first option (in order) without a score for a criterion (the first such criterion, in order)
        case missingScore(option: String, criterion: String)
    }

    /// Scores and ranks the options. Validates the input first: no criteria, a bad weight or a missing
    /// score throws a `MatrixError`.
    public static func decide(_ options: [Option], by criteria: [Criterion]) throws -> Decision {
        // Write your solution here, then run:
        // swift test --filter QualityDecisionMatrixTests
        throw Unimplemented()
    }

    /// The criteria (in the order given) whose weight, multiplied by `1 + change` or by `1 - change`
    /// with every other weight left alone, would give a different winner. `change` is between 0 and 1:
    /// 0.25 means "25% more or less important". No winner means no swing criteria.
    public static func swingCriteria(_ options: [Option], by criteria: [Criterion], change: Double) throws -> [String] {
        throw Unimplemented()
    }
}
