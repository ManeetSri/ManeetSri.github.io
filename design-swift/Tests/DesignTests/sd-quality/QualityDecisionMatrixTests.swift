import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct QualityDecisionMatrixTests {
    private typealias Criterion = QualityDecisionMatrix.Criterion
    private typealias Option = QualityDecisionMatrix.Option
    private typealias MatrixError = QualityDecisionMatrix.MatrixError

    private func close(_ a: Double, _ b: Double) -> Bool { abs(a - b) < 1e-9 }

    // Speed matters most; P is fast, Q is cheap, and they're equally safe. Q wins 3.9 to 3.8.
    private let criteria = [
        Criterion("Speed", weight: 4),
        Criterion("Cost", weight: 3),
        Criterion("Safety", weight: 3),
    ]
    private let options = [
        Option("P", scores: ["Speed": 5, "Cost": 2, "Safety": 4]),
        Option("Q", scores: ["Speed": 3, "Cost": 5, "Safety": 4]),
    ]

    @Test("Each option scores the weighted mean of its scores, best first")
    func weightedMean() throws {
        let decision = try QualityDecisionMatrix.decide(
            [Option("Y", scores: ["A": 3, "B": 5]), Option("X", scores: ["A": 5, "B": 2])],
            by: [Criterion("A", weight: 2), Criterion("B", weight: 1)]
        )
        #expect(decision.ranking.map(\.name) == ["X", "Y"])
        #expect(decision.ranking.count == 2)
        if decision.ranking.count == 2 {
            #expect(close(decision.ranking[0].score, 4))
            #expect(close(decision.ranking[1].score, 11.0 / 3))
        }
        #expect(decision.winner == "X")
        #expect(decision.eliminated.isEmpty)
    }

    @Test("Weights are relative: doubling every weight changes nothing")
    func relativeWeights() throws {
        let doubled = criteria.map { Criterion($0.name, weight: $0.weight * 2) }
        let original = try QualityDecisionMatrix.decide(options, by: criteria)
        let scaled = try QualityDecisionMatrix.decide(options, by: doubled)
        #expect(original.ranking.map(\.name) == ["Q", "P"])
        #expect(scaled.ranking.map(\.name) == ["Q", "P"])
        #expect(zip(original.ranking, scaled.ranking).allSatisfy { close($0.score, $1.score) })
        #expect(close(original.ranking.first?.score ?? 0, 3.9))
    }

    @Test("Equal scores are ranked alphabetically, so the result never depends on input order")
    func ties() throws {
        let same = ["Speed": 4.0, "Cost": 4.0, "Safety": 4.0]
        let decision = try QualityDecisionMatrix.decide([Option("Beta", scores: same), Option("Alpha", scores: same)], by: criteria)
        #expect(decision.ranking.map(\.name) == ["Alpha", "Beta"])
    }

    @Test("An option below a minimum is eliminated, however well it scores elsewhere")
    func minimums() throws {
        let withMustHave = criteria + [Criterion("Runs on iOS 16", weight: 1, minimum: 3)]
        let decision = try QualityDecisionMatrix.decide([
            Option("Shiny", scores: ["Speed": 5, "Cost": 5, "Safety": 5, "Runs on iOS 16": 1]),
            Option("Steady", scores: ["Speed": 3, "Cost": 3, "Safety": 4, "Runs on iOS 16": 5]),
            Option("Edge", scores: ["Speed": 2, "Cost": 2, "Safety": 2, "Runs on iOS 16": 3]),
        ], by: withMustHave)
        #expect(decision.winner == "Steady")
        #expect(decision.ranking.map(\.name) == ["Steady", "Edge"])
        #expect(decision.eliminated == ["Shiny"])
    }

    @Test("No options gives an empty decision with no winner")
    func noOptions() throws {
        let decision = try QualityDecisionMatrix.decide([], by: criteria)
        #expect(decision.ranking.isEmpty && decision.eliminated.isEmpty && decision.winner == nil)
    }

    @Test("Bad input throws a MatrixError instead of quietly scoring zero")
    func validation() {
        #expect(throws: MatrixError.noCriteria) {
            try QualityDecisionMatrix.decide(options, by: [])
        }
        #expect(throws: MatrixError.invalidWeight(criterion: "Cost")) {
            try QualityDecisionMatrix.decide(options, by: [Criterion("Speed", weight: 1), Criterion("Cost", weight: 0)])
        }
        #expect(throws: MatrixError.invalidWeight(criterion: "Speed")) {
            try QualityDecisionMatrix.decide(options, by: [Criterion("Speed", weight: -2)])
        }
        #expect(throws: MatrixError.missingScore(option: "Q", criterion: "Battery")) {
            try QualityDecisionMatrix.decide([
                Option("P", scores: ["Speed": 5, "Battery": 3]),
                Option("Q", scores: ["Speed": 3]),
            ], by: [Criterion("Speed", weight: 1), Criterion("Battery", weight: 1)])
        }
    }

    @Test("Swing criteria are the weights a 25% nudge would flip the winner on")
    func swingAtQuarter() throws {
        // Speed up to 5 makes P win; Cost down to 2.25 makes P win; Safety can't separate them.
        #expect(try QualityDecisionMatrix.swingCriteria(options, by: criteria, change: 0.25) == ["Speed", "Cost"])
    }

    @Test("A decision that survives every nudge has no swing criteria")
    func robustDecision() throws {
        #expect(try QualityDecisionMatrix.swingCriteria(options, by: criteria, change: 0.1).isEmpty)
        let clearWinner = [
            Option("Strong", scores: ["Speed": 5, "Cost": 5, "Safety": 5]),
            Option("Weak", scores: ["Speed": 1, "Cost": 1, "Safety": 1]),
        ]
        #expect(try QualityDecisionMatrix.swingCriteria(clearWinner, by: criteria, change: 0.9).isEmpty)
    }

    @Test("Swing analysis respects minimums, and with no winner there's nothing to swing")
    func swingWithMinimums() throws {
        let strict = criteria.map { Criterion($0.name, weight: $0.weight, minimum: 3) }
        // P fails the Cost minimum, so Q wins whatever the weights.
        #expect(try QualityDecisionMatrix.swingCriteria(options, by: strict, change: 0.5).isEmpty)
        let impossible = criteria.map { Criterion($0.name, weight: $0.weight, minimum: 6) }
        #expect(try QualityDecisionMatrix.swingCriteria(options, by: impossible, change: 0.25).isEmpty)
        #expect(try QualityDecisionMatrix.decide(options, by: impossible).eliminated == ["P", "Q"])
    }
}
