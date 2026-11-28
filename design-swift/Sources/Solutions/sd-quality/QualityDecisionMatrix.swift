// Reference solution: Weighted decision matrix. Validate first, so a typo in a criterion name fails
// loudly instead of quietly scoring zero. Then score the options that meet every minimum, rank them,
// and test how fragile the winner is by nudging one weight at a time.
import Foundation

public enum QualityDecisionMatrix {
    public struct Criterion: Sendable, Equatable {
        public let name: String
        public let weight: Double
        public let minimum: Double?

        public init(_ name: String, weight: Double, minimum: Double? = nil) {
            self.name = name
            self.weight = weight
            self.minimum = minimum
        }
    }

    public struct Option: Sendable, Equatable {
        public let name: String
        public let scores: [String: Double]

        public init(_ name: String, scores: [String: Double]) {
            self.name = name
            self.scores = scores
        }
    }

    public struct Ranked: Sendable, Equatable {
        public let name: String
        public let score: Double

        public init(name: String, score: Double) {
            self.name = name
            self.score = score
        }
    }

    public struct Decision: Sendable, Equatable {
        public let ranking: [Ranked]
        public let eliminated: [String]

        public init(ranking: [Ranked], eliminated: [String]) {
            self.ranking = ranking
            self.eliminated = eliminated
        }

        public var winner: String? { ranking.first?.name }
    }

    public enum MatrixError: Error, Equatable {
        case noCriteria
        case invalidWeight(criterion: String)
        case missingScore(option: String, criterion: String)
    }

    public static func decide(_ options: [Option], by criteria: [Criterion]) throws -> Decision {
        guard !criteria.isEmpty else { throw MatrixError.noCriteria }
        if let bad = criteria.first(where: { !($0.weight > 0) || !$0.weight.isFinite }) {
            throw MatrixError.invalidWeight(criterion: bad.name)
        }
        for option in options {
            if let missing = criteria.first(where: { option.scores[$0.name] == nil }) {
                throw MatrixError.missingScore(option: option.name, criterion: missing.name)
            }
        }

        let totalWeight = criteria.reduce(0) { $0 + $1.weight }
        var ranking: [Ranked] = []
        var eliminated: [String] = []
        for option in options {
            let failsMinimum = criteria.contains { criterion in
                guard let minimum = criterion.minimum else { return false }
                return option.scores[criterion.name, default: 0] < minimum
            }
            if failsMinimum {
                eliminated.append(option.name)
                continue
            }
            let weighted = criteria.reduce(0) { $0 + $1.weight * option.scores[$1.name, default: 0] }
            ranking.append(Ranked(name: option.name, score: weighted / totalWeight))
        }
        ranking.sort { $0.score != $1.score ? $0.score > $1.score : $0.name < $1.name }
        return Decision(ranking: ranking, eliminated: eliminated)
    }

    public static func swingCriteria(_ options: [Option], by criteria: [Criterion], change: Double) throws -> [String] {
        guard let winner = try decide(options, by: criteria).winner else { return [] }
        var swings: [String] = []
        for (index, criterion) in criteria.enumerated() {
            for factor in [1 + change, 1 - change] {
                var nudged = criteria
                nudged[index] = Criterion(criterion.name, weight: criterion.weight * factor, minimum: criterion.minimum)
                if try decide(options, by: nudged).winner != winner {
                    swings.append(criterion.name)
                    break
                }
            }
        }
        return swings
    }
}
