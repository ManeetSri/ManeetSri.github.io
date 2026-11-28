import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RecurrenceLevelSumsTests {
    typealias MasterCase = RecurrenceLevelSums.MasterCase

    // The recursion itself, for small n
    static func recursiveWork(n: Int, a: Int, b: Int, d: Int) -> Int {
        if n == 1 {
            return 1
        }
        var own = 1
        for _ in 0..<d {
            own *= n
        }
        var total = own
        for _ in 0..<a {
            total += recursiveWork(n: n / b, a: a, b: b, d: d)
        }
        return total
    }

    @Test("Work examples", arguments: [
        (8, 2, 2, 1, 32), (64, 1, 2, 1, 127), (64, 4, 2, 1, 8_128), (27, 2, 3, 1, 65),
        (256, 1, 2, 1, 511), (1_024, 1, 2, 1, 2_047), (64, 2, 2, 1, 448), (256, 2, 2, 1, 2_304),
        (1_024, 2, 2, 1, 11_264), (256, 4, 2, 1, 130_816), (1_024, 4, 2, 1, 2_096_128),
        (16, 3, 2, 1, 211), (81, 1, 3, 1, 121), (1, 5, 3, 2, 1),
    ])
    func workExamples(n: Int, a: Int, b: Int, d: Int, expected: Int) {
        #expect(RecurrenceLevelSums.work(n: n, a: a, b: b, d: d) == expected)
    }

    @Test("Work matches the recursion for small powers of b")
    func workMatchesRecursion() {
        var wrong: [String] = []
        for a in 1...5 {
            for b in 2...4 {
                for d in 0...3 {
                    var n = 1
                    while n <= 300 {
                        if RecurrenceLevelSums.work(n: n, a: a, b: b, d: d) != Self.recursiveWork(n: n, a: a, b: b, d: d) {
                            wrong.append("n \(n), a \(a), b \(b), d \(d)")
                        }
                        n *= b
                    }
                }
            }
        }
        #expect(wrong.isEmpty, "wrong for \(Array(wrong.prefix(5)))")
    }

    @Test("Big inputs, level by level instead of call by call")
    func workBig() {
        // binary search: one unit per level
        #expect(RecurrenceLevelSums.work(n: 1 << 60, a: 1, b: 2, d: 0) == 61)
        // 2T(n/2) + 1: 2n − 1 calls
        #expect(RecurrenceLevelSums.work(n: 1 << 20, a: 2, b: 2, d: 0) == 2_097_151)
        // 3T(n/3) + n: n on each of 11 levels
        #expect(RecurrenceLevelSums.work(n: 59_049, a: 3, b: 3, d: 1) == 649_539)
        // 8T(n/2) + n² and 2T(n/2) + n²
        #expect(RecurrenceLevelSums.work(n: 1_024, a: 8, b: 2, d: 2) == 2_146_435_072)
        #expect(RecurrenceLevelSums.work(n: 1_024, a: 2, b: 2, d: 2) == 2_096_128)
        // 4T(n/2) + n at n = 2³⁰: 2n² − n, from over 10¹⁸ calls
        #expect(RecurrenceLevelSums.work(n: 1 << 30, a: 4, b: 2, d: 1) == 2_305_843_008_139_952_128)
        // 16T(n/4) + n² at n = 4¹⁰: 11 levels of n²
        #expect(RecurrenceLevelSums.work(n: 1_048_576, a: 16, b: 4, d: 2) == 12_094_627_905_536)
    }

    @Test("Predicted cases from the lesson's table", arguments: [
        (1, 2, 0, MasterCase.balanced), (1, 2, 1, .rootDominates), (2, 2, 0, .leavesDominate),
        (2, 2, 1, .balanced), (2, 2, 2, .rootDominates), (4, 2, 1, .leavesDominate),
        (3, 2, 1, .leavesDominate), (3, 3, 1, .balanced), (8, 2, 2, .leavesDominate),
        (7, 2, 2, .leavesDominate), (8, 2, 3, .balanced), (16, 4, 2, .balanced), (1, 10, 3, .rootDominates),
    ])
    func cases(a: Int, b: Int, d: Int, expected: MasterCase) {
        #expect(RecurrenceLevelSums.predictedCase(a: a, b: b, d: d) == expected)
    }

    @Test("Growing n by a factor of b grows the work as the case predicts", arguments: [
        (1, 2, 1), (2, 2, 1), (4, 2, 1), (2, 2, 2), (8, 2, 2), (3, 3, 1), (9, 3, 1), (2, 4, 1), (16, 4, 1),
    ])
    func ratiosMatchCase(a: Int, b: Int, d: Int) {
        var n = 1
        while n <= 1_000_000 / b {
            n *= b
        }
        let ratio = Double(RecurrenceLevelSums.work(n: n * b, a: a, b: b, d: d)) / Double(RecurrenceLevelSums.work(n: n, a: a, b: b, d: d))
        var split = 1
        for _ in 0..<d {
            split *= b
        }
        switch RecurrenceLevelSums.predictedCase(a: a, b: b, d: d) {
        case .rootDominates:
            #expect(abs(ratio - Double(split)) < 0.05 * Double(split))
        case .balanced:
            #expect(ratio > Double(split) && ratio < 1.2 * Double(split))
        case .leavesDominate:
            #expect(abs(ratio - Double(a)) < 0.05 * Double(a))
        }
    }
}
