import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CatalanDisguisesTests {
    private let p = 1_000_000_007

    /// Exact Catalan numbers C(0)...C(35), from the recurrence (each fits in an Int)
    private var exact: [Int] {
        var values = [1]
        for n in 0..<35 {
            var next = 0
            for i in 0...n {
                next += values[i] * values[n - i]
            }
            values.append(next)
        }
        return values
    }

    /// Counts bracket strings with n pairs by trying every string
    private func bracketBrute(_ pairs: Int) -> Int {
        var count = 0
        for mask in 0..<(1 << (2 * pairs)) {
            var depth = 0
            var valid = true
            for bit in 0..<(2 * pairs) {
                depth += mask & (1 << bit) != 0 ? 1 : -1
                if depth < 0 {
                    valid = false
                    break
                }
            }
            if valid && depth == 0 { count += 1 }
        }
        return count
    }

    @Test("The examples")
    func examples() {
        #expect(CatalanDisguises.answers([.bracketStrings(pairs: 3), .treeShapes(nodes: 4)]) == [5, 14])
        #expect(CatalanDisguises.answers([.triangulations(sides: 6), .triangulations(sides: 3)]) == [14, 1])
        #expect(CatalanDisguises.answers([.matrixOrders(matrices: 4), .matrixOrders(matrices: 1)]) == [5, 1])
        #expect(CatalanDisguises.answers([.bracketStrings(pairs: 0), .treeShapes(nodes: 0)]) == [1, 1])
        #expect(CatalanDisguises.answers([.bracketStrings(pairs: 35), .treeShapes(nodes: 1_000_000)]) == [93_302_951, 70_646_122])
        #expect(CatalanDisguises.answers([]) == [])
    }

    @Test("Each disguise has its own offset")
    func offsets() {
        let values = exact
        for n in 0...20 {
            let answers = CatalanDisguises.answers([
                .bracketStrings(pairs: n), .treeShapes(nodes: n),
                .triangulations(sides: n + 3), .matrixOrders(matrices: n + 1),
            ])
            #expect(answers == [values[n], values[n], values[n + 1], values[n]].map { $0 % p }, "n = \(n)")
        }
    }

    @Test("Bracket strings match trying every string, up to 9 pairs")
    func bruteForce() {
        let answers = CatalanDisguises.answers((0...9).map { .bracketStrings(pairs: $0) })
        #expect(answers == (0...9).map(bracketBrute))
    }

    @Test("Exact values up to C(35), reduced modulo the prime")
    func exactValues() {
        let answers = CatalanDisguises.answers((0...35).map { .treeShapes(nodes: $0) })
        #expect(answers == exact.map { $0 % p })
    }

    @Test("Matches the recurrence modulo the prime, up to 2,000")
    func recurrence() {
        var values = [1]
        for n in 0..<2_000 {
            var next = 0
            for i in 0...n {
                next = (next + values[i] * values[n - i]) % p
            }
            values.append(next)
        }
        let sizes = [36, 37, 100, 999, 1_500, 2_000]
        let answers = CatalanDisguises.answers(sizes.map { .bracketStrings(pairs: $0) } + sizes.map { .triangulations(sides: $0 + 2) })
        #expect(answers == (sizes + sizes).map { values[$0] })
        #expect(CatalanDisguises.answers([.bracketStrings(pairs: 100), .bracketStrings(pairs: 1_000)]) == [558_488_487, 110_961_515])
    }

    @Test("100,000 questions with sizes near a million")
    func large() {
        var questions: [CatalanDisguises.Question] = []
        for i in 0..<100_000 {
            switch i % 4 {
            case 0: questions.append(.bracketStrings(pairs: 1_000_000 - i))
            case 1: questions.append(.treeShapes(nodes: i))
            case 2: questions.append(.triangulations(sides: 1_000_002 - i))
            default: questions.append(.matrixOrders(matrices: 1_000_001))
            }
        }
        let answers = CatalanDisguises.answers(questions)
        #expect(answers.count == questions.count)
        guard answers.count == questions.count else { return }
        #expect(answers[0] == 70_646_122)        // C(1,000,000)
        #expect(answers[3] == 70_646_122)        // 1,000,001 matrices: C(1,000,000)
        #expect(answers[1] == 1)                 // one node: one shape
        #expect(answers[2] == 135_849_840)       // 1,000,000 corners: C(999,998)
        #expect(answers[4] == 832_713_057)       // 999,996 pairs
        #expect(answers[5] == 42)                // five nodes
    }
}
