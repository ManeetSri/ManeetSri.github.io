// Reference solution: Performance budget gate. Reduce each metric's samples to one statistic, compare it
// with the absolute limit first and the baseline second, and treat missing data as a failure. The
// ratchet only ever moves a baseline towards better, so the bar rises as the app gets faster.
import Foundation

public enum QualityBudgetGate {
    public enum Statistic: Sendable, Equatable {
        case mean
        case maximum
        case percentile(Double)
    }

    public enum Direction: Sendable, Equatable {
        case lowerIsBetter
        case higherIsBetter
    }

    public struct Budget: Sendable, Equatable {
        public let id: String
        public let metric: String
        public let statistic: Statistic
        public let limit: Double
        public let direction: Direction
        public let maxRegression: Double?

        public init(id: String, metric: String, statistic: Statistic, limit: Double, direction: Direction = .lowerIsBetter, maxRegression: Double? = nil) {
            self.id = id
            self.metric = metric
            self.statistic = statistic
            self.limit = limit
            self.direction = direction
            self.maxRegression = maxRegression
        }
    }

    public enum Verdict: Sendable, Equatable {
        case pass
        case breached
        case regressed
        case noData
    }

    public struct Outcome: Sendable, Equatable {
        public let budgetID: String
        public let measured: Double?
        public let verdict: Verdict

        public init(budgetID: String, measured: Double?, verdict: Verdict) {
            self.budgetID = budgetID
            self.measured = measured
            self.verdict = verdict
        }
    }

    public static func value(of statistic: Statistic, in samples: [Double]) -> Double? {
        guard !samples.isEmpty else { return nil }
        switch statistic {
        case .mean:
            return samples.reduce(0, +) / Double(samples.count)
        case .maximum:
            return samples.max()
        case .percentile(let p):
            let sorted = samples.sorted()
            let rank = Int((p * Double(sorted.count) / 100).rounded(.up))
            return sorted[min(max(rank, 1), sorted.count) - 1]
        }
    }

    /// Whether `value` is worse than `reference` for this direction
    private static func isWorse(_ value: Double, than reference: Double, _ direction: Direction) -> Bool {
        direction == .lowerIsBetter ? value > reference : value < reference
    }

    public static func evaluate(_ budgets: [Budget], samples: [String: [Double]], baseline: [String: Double] = [:]) -> [Outcome] {
        budgets.map { budget in
            guard let measured = value(of: budget.statistic, in: samples[budget.metric] ?? []) else {
                return Outcome(budgetID: budget.id, measured: nil, verdict: .noData)
            }
            if isWorse(measured, than: budget.limit, budget.direction) {
                return Outcome(budgetID: budget.id, measured: measured, verdict: .breached)
            }
            if let allowed = budget.maxRegression, let previous = baseline[budget.id] {
                let threshold = budget.direction == .lowerIsBetter ? previous * (1 + allowed) : previous * (1 - allowed)
                if isWorse(measured, than: threshold, budget.direction) {
                    return Outcome(budgetID: budget.id, measured: measured, verdict: .regressed)
                }
            }
            return Outcome(budgetID: budget.id, measured: measured, verdict: .pass)
        }
    }

    public static func ratchet(_ baseline: [String: Double], budgets: [Budget], outcomes: [Outcome]) -> [String: Double] {
        let budgetByID = Dictionary(budgets.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var next = baseline
        for outcome in outcomes where outcome.verdict == .pass {
            guard let measured = outcome.measured, let budget = budgetByID[outcome.budgetID] else { continue }
            if let previous = next[outcome.budgetID], !isWorse(previous, than: measured, budget.direction) {
                continue
            }
            next[outcome.budgetID] = measured
        }
        return next
    }
}
