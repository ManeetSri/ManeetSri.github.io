import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CircuitRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct CircuitBracketingsTests {
    private static let mod = 1_000_000_007

    private func apply(_ op: Character, _ left: Bool, _ right: Bool) -> Bool {
        switch op {
        case "&": return left && right
        case "|": return left || right
        case "^": return left != right
        default: return !left || right                        // implies
        }
    }

    /// The value of every bracketing of symbols i...j, one entry per bracketing
    private func everyValue(_ symbols: [Bool], _ operators: [Character], _ i: Int, _ j: Int) -> [Bool] {
        if i == j { return [symbols[i]] }
        var values: [Bool] = []
        for k in i..<j {
            let left = everyValue(symbols, operators, i, k), right = everyValue(symbols, operators, k + 1, j)
            for l in left {
                for r in right {
                    values.append(apply(operators[k], l, r))
                }
            }
        }
        return values
    }

    private func split(_ expression: String) -> (symbols: [Bool], operators: [Character]) {
        let tokens = Array(expression)
        return (stride(from: 0, to: tokens.count, by: 2).map { tokens[$0] == "T" },
                stride(from: 1, to: tokens.count, by: 2).map { tokens[$0] })
    }

    /// Top-down with memoised (true, false) pairs, modulo the prime
    private func memoised(_ expression: String) -> (trueWays: Int, falseWays: Int) {
        let (symbols, operators) = split(expression)
        let n = symbols.count
        var memo: [[(Int, Int)?]] = Array(repeating: Array(repeating: nil, count: n), count: n)
        func ways(_ i: Int, _ j: Int) -> (Int, Int) {
            if let known = memo[i][j] { return known }
            if i == j { return symbols[i] ? (1, 0) : (0, 1) }
            var yes = 0, no = 0
            for k in i..<j {
                let (lt, lf) = ways(i, k), (rt, rf) = ways(k + 1, j)
                for (l, lc) in [(true, lt), (false, lf)] {
                    for (r, rc) in [(true, rt), (false, rf)] {
                        let pairs = lc * rc % Self.mod
                        if apply(operators[k], l, r) { yes = (yes + pairs) % Self.mod } else { no = (no + pairs) % Self.mod }
                    }
                }
            }
            memo[i][j] = (yes, no)
            return (yes, no)
        }
        return ways(0, n - 1)
    }

    private func catalan(_ count: Int) -> Int {
        var c = [1]
        for size in stride(from: 1, through: count, by: 1) {
            var total = 0
            for left in 0..<size {
                total = (total + c[left] * c[size - 1 - left]) % Self.mod
            }
            c.append(total)
        }
        return c[count]
    }

    private func randomExpression(_ symbols: Int, using random: inout CircuitRandom) -> String {
        var text = ""
        for index in 0..<symbols {
            if index > 0 { text.append(["&", "|", "^", ">"][Int.random(in: 0..<4, using: &random)]) }
            text.append(Bool.random(using: &random) ? "T" : "F")
        }
        return text
    }

    @Test("Examples and small cases", arguments: [
        ("T^T&F|T", 2, 3),
        ("T|F&F^T", 4, 1),
        ("T", 1, 0),
        ("F", 0, 1),
        ("T>F", 0, 1),
        ("F>T>F", 1, 1),                       // (F>T)>F is false, F>(T>F) is true
        ("T>F>F", 2, 0),
        ("F>F>F", 1, 1),
        ("T&T&T&T", 5, 0),
        ("F^F", 0, 1),
        ("T|F", 1, 0),
    ])
    func examples(expression: String, trueWays: Int, falseWays: Int) {
        #expect(CircuitBracketings.count(expression, wanted: true) == trueWays)
        #expect(CircuitBracketings.count(expression, wanted: false) == falseWays)
    }

    @Test("Matches evaluating every bracketing on 300 random circuits")
    func randomSmall() {
        var random = CircuitRandom(seed: 56)
        for _ in 0..<300 {
            let expression = randomExpression(Int.random(in: 1...8, using: &random), using: &random)
            let (symbols, operators) = split(expression)
            let values = everyValue(symbols, operators, 0, symbols.count - 1)
            #expect(CircuitBracketings.count(expression, wanted: true) == values.filter { $0 }.count)
            #expect(CircuitBracketings.count(expression, wanted: false) == values.filter { !$0 }.count)
        }
    }

    @Test("40 symbols match a memoised top-down count")
    func medium() {
        var random = CircuitRandom(seed: 40)
        for _ in 0..<5 {
            let expression = randomExpression(40, using: &random)
            let expected = memoised(expression)
            #expect(CircuitBracketings.count(expression, wanted: true) == expected.trueWays)
            #expect(CircuitBracketings.count(expression, wanted: false) == expected.falseWays)
        }
    }

    @Test("150 symbols: the counts overflow without the modulo")
    func large() {
        // Every bracketing is either true or false, so the two counts add up to the Catalan number
        var random = CircuitRandom(seed: 150)
        let expression = randomExpression(150, using: &random)
        let yes = CircuitBracketings.count(expression, wanted: true)
        let no = CircuitBracketings.count(expression, wanted: false)
        #expect((0..<Self.mod).contains(yes) && (0..<Self.mod).contains(no))
        #expect((yes + no) % Self.mod == catalan(149))

        // And is associative and all-true, so every bracketing of T&T&…&T is true
        let allAnd = Array(repeating: "T", count: 150).joined(separator: "&")
        #expect(CircuitBracketings.count(allAnd, wanted: true) == catalan(149))
        #expect(CircuitBracketings.count(allAnd, wanted: false) == 0)

        // 149 Ts joined by xor: an odd number of trues is true, however it's bracketed
        let allXor = Array(repeating: "T", count: 149).joined(separator: "^")
        #expect(CircuitBracketings.count(allXor, wanted: false) == 0)
    }
}
