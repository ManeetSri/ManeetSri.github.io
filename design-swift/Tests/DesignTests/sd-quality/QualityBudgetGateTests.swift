import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct QualityBudgetGateTests {
    private typealias Budget = QualityBudgetGate.Budget
    private typealias Outcome = QualityBudgetGate.Outcome

    private func close(_ a: Double?, _ b: Double) -> Bool {
        guard let a else { return false }
        return abs(a - b) < 1e-9
    }

    // Ten cold launches in milliseconds: most are quick, two are slow (a cold cache, a busy device)
    private let launches: [Double] = [350, 1200, 310, 380, 330, 900, 320, 370, 340, 360]

    private let coldLaunch = Budget(id: "cold-launch-p90", metric: "coldLaunchMs", statistic: .percentile(90), limit: 1000, maxRegression: 0.1)
    private let crashFree = Budget(id: "crash-free", metric: "crashFreePercent", statistic: .mean, limit: 99.8, direction: .higherIsBetter)
    private let scrolling = Budget(id: "scroll-fps", metric: "scrollFPS", statistic: .mean, limit: 55, direction: .higherIsBetter, maxRegression: 0.05)

    private var samples: [String: [Double]] {
        ["coldLaunchMs": launches, "crashFreePercent": [99.9, 99.7, 99.95], "scrollFPS": [60, 58, 59, 57, 60]]
    }

    @Test("Percentiles use the nearest rank, on unsorted samples")
    func percentiles() {
        let small: [Double] = [5, 1, 4, 2, 3]
        #expect(QualityBudgetGate.value(of: .percentile(50), in: small) == 3)
        #expect(QualityBudgetGate.value(of: .percentile(90), in: small) == 5)
        #expect(QualityBudgetGate.value(of: .percentile(20), in: small) == 1)
        #expect(QualityBudgetGate.value(of: .percentile(0), in: small) == 1)
        #expect(QualityBudgetGate.value(of: .percentile(100), in: small) == 5)
        #expect(QualityBudgetGate.value(of: .percentile(50), in: launches) == 350)
        #expect(QualityBudgetGate.value(of: .percentile(90), in: launches) == 900)
        #expect(QualityBudgetGate.value(of: .percentile(95), in: launches) == 1200)
    }

    @Test("Mean and maximum, and no value at all without samples")
    func otherStatistics() {
        #expect(close(QualityBudgetGate.value(of: .mean, in: launches), 486))
        #expect(QualityBudgetGate.value(of: .maximum, in: launches) == 1200)
        #expect(QualityBudgetGate.value(of: .mean, in: []) == nil)
        #expect(QualityBudgetGate.value(of: .maximum, in: []) == nil)
        #expect(QualityBudgetGate.value(of: .percentile(90), in: []) == nil)
    }

    @Test("Measurements inside their limits pass, in either direction, in the budgets' order")
    func passes() {
        let outcomes = QualityBudgetGate.evaluate([coldLaunch, crashFree, scrolling], samples: samples)
        #expect(outcomes.map(\.budgetID) == ["cold-launch-p90", "crash-free", "scroll-fps"])
        #expect(outcomes.map(\.verdict) == [.pass, .pass, .pass])
        #expect(outcomes.count == 3)
        if outcomes.count == 3 {
            #expect(close(outcomes[0].measured, 900))
            #expect(close(outcomes[1].measured, 99.85))
            #expect(close(outcomes[2].measured, 58.8))
        }
    }

    @Test("A measurement on the wrong side of its limit breaches it; exactly at the limit passes")
    func breaches() {
        let tight = [
            Budget(id: "cold-launch-p90", metric: "coldLaunchMs", statistic: .percentile(90), limit: 800),
            Budget(id: "crash-free", metric: "crashFreePercent", statistic: .mean, limit: 99.9, direction: .higherIsBetter),
            Budget(id: "worst-launch", metric: "coldLaunchMs", statistic: .maximum, limit: 1200),
        ]
        #expect(QualityBudgetGate.evaluate(tight, samples: samples).map(\.verdict) == [.breached, .breached, .pass])
    }

    @Test("Worse than the baseline by more than the allowance is a regression, even inside the limit")
    func regressions() {
        let budgets = [coldLaunch, scrolling, crashFree]
        // 900 ms against 800 ms is 12.5% slower (allowed 10%); 58.8 fps against 62.5 is 5.9% lower (allowed 5%)
        let worse = QualityBudgetGate.evaluate(budgets, samples: samples, baseline: ["cold-launch-p90": 800, "scroll-fps": 62.5, "crash-free": 100])
        #expect(worse.map(\.verdict) == [.regressed, .regressed, .pass])
        // 900 against 850 is 5.9% slower; 58.8 against 60 is 2% lower: both allowed
        let fine = QualityBudgetGate.evaluate(budgets, samples: samples, baseline: ["cold-launch-p90": 850, "scroll-fps": 60])
        #expect(fine.map(\.verdict) == [.pass, .pass, .pass])
    }

    @Test("A breach is reported as a breach, not a regression")
    func breachBeatsRegression() {
        let strict = Budget(id: "cold-launch-p90", metric: "coldLaunchMs", statistic: .percentile(90), limit: 800, maxRegression: 0.1)
        let outcomes = QualityBudgetGate.evaluate([strict], samples: samples, baseline: ["cold-launch-p90": 500])
        #expect(outcomes == [Outcome(budgetID: "cold-launch-p90", measured: 900, verdict: .breached)])
    }

    @Test("Missing or empty samples fail as noData, never pass")
    func noData() {
        let memory = Budget(id: "peak-memory", metric: "memoryMB", statistic: .maximum, limit: 300)
        let outcomes = QualityBudgetGate.evaluate([memory, coldLaunch], samples: ["memoryMB": []])
        #expect(outcomes == [
            Outcome(budgetID: "peak-memory", measured: nil, verdict: .noData),
            Outcome(budgetID: "cold-launch-p90", measured: nil, verdict: .noData),
        ])
    }

    @Test("The ratchet only moves a baseline towards better, and only on a pass")
    func ratchet() {
        let memory = Budget(id: "peak-memory", metric: "memoryMB", statistic: .maximum, limit: 300)
        let outcomes = [
            Outcome(budgetID: "cold-launch-p90", measured: 700, verdict: .pass),   // faster: new baseline
            Outcome(budgetID: "scroll-fps", measured: 58.8, verdict: .pass),       // passed, but worse: keep 60
            Outcome(budgetID: "crash-free", measured: 99.85, verdict: .pass),      // first measurement: added
            Outcome(budgetID: "peak-memory", measured: 250, verdict: .regressed),  // didn't pass: unchanged
        ]
        let next = QualityBudgetGate.ratchet(
            ["cold-launch-p90": 800, "scroll-fps": 60, "peak-memory": 200, "binary-size": 40],
            budgets: [coldLaunch, scrolling, crashFree, memory],
            outcomes: outcomes
        )
        #expect(next == ["cold-launch-p90": 700, "scroll-fps": 60, "crash-free": 99.85, "peak-memory": 200, "binary-size": 40])

        let better = QualityBudgetGate.ratchet(["scroll-fps": 60, "cold-launch-p90": 800], budgets: [coldLaunch, scrolling], outcomes: [
            Outcome(budgetID: "scroll-fps", measured: 61, verdict: .pass),
            Outcome(budgetID: "cold-launch-p90", measured: 850, verdict: .pass),
        ])
        #expect(better == ["scroll-fps": 61, "cold-launch-p90": 800])
    }

    @Test("A run, its ratchet, then the same samples again: the gate holds steady")
    func endToEnd() {
        let budgets = [coldLaunch, crashFree, scrolling]
        let first = QualityBudgetGate.evaluate(budgets, samples: samples, baseline: ["cold-launch-p90": 950])
        let baseline = QualityBudgetGate.ratchet(["cold-launch-p90": 950], budgets: budgets, outcomes: first)
        #expect(close(baseline["cold-launch-p90"], 900))
        #expect(close(baseline["scroll-fps"], 58.8))
        let second = QualityBudgetGate.evaluate(budgets, samples: samples, baseline: baseline)
        #expect(second.map(\.verdict) == [.pass, .pass, .pass])
        // A slower build (p90 now 1000 ms, 11% over the new 900 ms baseline) is caught as a regression
        let slower = samples.merging(["coldLaunchMs": launches.map { $0 == 900 ? 1000 : $0 }]) { _, new in new }
        #expect(QualityBudgetGate.evaluate(budgets, samples: slower, baseline: baseline).first?.verdict == .regressed)
    }
}
