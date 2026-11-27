import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private struct SlotRandom {
    var state: UInt64
    mutating func next(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int((state >> 33) % UInt64(bound))
    }
}

@Suite struct MeetingSlotPlannerTests {
    /// Whether a code holds in a plan: x means meeting x is in the morning, ~x that it's in the afternoon.
    private func holds(_ code: Int, in plan: [Bool]) -> Bool {
        code >= 0 ? plan[code] : !plan[~code]
    }

    private func keepsEveryRule(_ plan: [Bool], _ meetings: Int, _ rules: [[Int]]) -> Bool {
        plan.count == meetings && rules.allSatisfy { holds($0[0], in: plan) || holds($0[1], in: plan) }
    }

    /// Tries all 2ⁿ plans: only for a few meetings.
    private func anyPlanWorks(_ meetings: Int, _ rules: [[Int]]) -> Bool {
        (0..<(1 << meetings)).contains { mask in
            keepsEveryRule((0..<meetings).map { (mask >> $0) & 1 == 1 }, meetings, rules)
        }
    }

    @Test("Plans that exist", arguments: [
        (3, [[0, 1], [~0, 2], [~1, ~2]]),
        (2, [[0, 1], [~0, ~1]]),
        (3, [[~2, ~2]]),
        (4, []),
        (1, [[0, ~0]]),
        (3, [[0, 0], [~0, 1], [~1, 2]]),
        (4, [[0, 1], [~1, 2], [~2, 3], [~3, ~0], [0, 3]]),
    ] as [(Int, [[Int]])])
    func plansExist(meetings: Int, rules: [[Int]]) {
        let plan = MeetingSlotPlanner.plan(meetings, rules)
        #expect(plan != nil)
        if let plan {
            #expect(keepsEveryRule(plan, meetings, rules))
        }
    }

    @Test("Forced choices", arguments: [
        (3, [[~2, ~2]], [2], [false]),
        (3, [[0, 0], [~0, 1], [~1, 2]], [0, 1, 2], [true, true, true]),
        (2, [[0, 1], [0, ~1]], [0], [true]),
    ] as [(Int, [[Int]], [Int], [Bool])])
    func forced(meetings: Int, rules: [[Int]], which: [Int], slots: [Bool]) {
        let plan = MeetingSlotPlanner.plan(meetings, rules)
        #expect(plan.map { plan in which.map { plan[$0] } } == slots)
    }

    @Test("Impossible plans", arguments: [
        (1, [[0, 0], [~0, ~0]]),
        (2, [[0, 1], [0, ~1], [~0, 1], [~0, ~1]]),
        (3, [[0, 0], [~0, 1], [~1, 2], [~2, ~0]]),
        (4, [[0, 1], [~0, 1], [~1, 2], [~1, ~2], [3, 3]]),
    ] as [(Int, [[Int]])])
    func impossible(meetings: Int, rules: [[Int]]) {
        #expect(MeetingSlotPlanner.plan(meetings, rules) == nil)
    }

    @Test("Matches brute force on 400 random small instances")
    func randomSmall() {
        var random = SlotRandom(state: 2)
        func code(_ meetings: Int) -> Int {
            let x = random.next(meetings)
            return random.next(2) == 0 ? x : ~x
        }
        for _ in 0..<400 {
            let meetings = 1 + random.next(7)
            let rules = (0..<(1 + random.next(16))).map { _ in [code(meetings), code(meetings)] }
            let plan = MeetingSlotPlanner.plan(meetings, rules)
            if anyPlanWorks(meetings, rules) {
                #expect(plan != nil)
                if let plan { #expect(keepsEveryRule(plan, meetings, rules)) }
            } else {
                #expect(plan == nil)
            }
        }
    }

    @Test("Large plans: 100,000 meetings (needs an iterative DFS)")
    func largePlans() {
        let n = 100_000
        // Meeting 0 in the morning forces each next meeting into the morning, all the way down
        let chain = [[0, 0]] + (0..<(n - 1)).map { [~$0, $0 + 1] }
        let plan = MeetingSlotPlanner.plan(n, chain)
        #expect(plan == [Bool](repeating: true, count: n))
        // ...and if the last morning then forces meeting 0 into the afternoon, nothing works
        #expect(MeetingSlotPlanner.plan(n, chain + [[~(n - 1), ~0]]) == nil)

        // 300,000 random rules, each kept by a hidden plan
        var random = SlotRandom(state: 300)
        let secret = (0..<n).map { _ in random.next(2) == 0 }
        func code() -> Int {
            let x = random.next(n)
            return random.next(2) == 0 ? x : ~x
        }
        var rules: [[Int]] = []
        while rules.count < 300_000 {
            let rule = [code(), code()]
            if holds(rule[0], in: secret) || holds(rule[1], in: secret) { rules.append(rule) }
        }
        let found = MeetingSlotPlanner.plan(n, rules)
        #expect(found != nil)
        if let found { #expect(keepsEveryRule(found, n, rules)) }
    }
}
