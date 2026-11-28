import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BracketingRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BracketingOutcomesTests {
    /// Bottom-up over ranges of numbers, shortest first: a different route to the same answers
    private func reference(_ numbers: [Int], _ operators: [Character]) -> [Int] {
        let n = numbers.count
        var table = Array(repeating: Array(repeating: [Int](), count: n), count: n)
        for index in 0..<n {
            table[index][index] = [numbers[index]]
        }
        if n >= 2 {
            for length in 2...n {
                for first in 0...(n - length) {
                    let last = first + length - 1
                    var values: [Int] = []
                    for split in first..<last {
                        for a in table[first][split] {
                            for b in table[split + 1][last] {
                                values.append(operators[split] == "+" ? a + b : operators[split] == "-" ? a - b : a * b)
                            }
                        }
                    }
                    table[first][last] = values
                }
            }
        }
        return table[0][n - 1].sorted()
    }

    private func text(_ numbers: [Int], _ operators: [Character]) -> String {
        var result = String(numbers[0])
        for (index, symbol) in operators.enumerated() {
            result.append(symbol)
            result += String(numbers[index + 1])
        }
        return result
    }

    private let catalan = [1, 1, 2, 5, 14, 42, 132, 429, 1_430, 4_862, 16_796]

    @Test("Examples and small cases", arguments: [
        ("5-1-2", [2, 6]),
        ("3*4+2", [14, 18]),
        ("6-2*3+1", [-2, -1, 1, 13, 16]),
        ("7", [7]),
        ("0*9-9", [-9, 0]),
        ("2+2+2", [6, 6]),
        ("10-30", [-20]),
        ("1-2-3-4", [-8, -2, -2, 0, 6]),
        ("0", [0]),
        ("12*0+3", [3, 36]),
    ] as [(String, [Int])])
    func examples(expression: String, expected: [Int]) {
        #expect(BracketingOutcomes.allValues(expression) == expected)
    }

    @Test("One value per bracketing: the Catalan numbers", arguments: Array(0...10))
    func catalanCounts(operators: Int) {
        // "1+1+...+1" has every bracketing worth the same, so only the count can differ
        let expression = Array(repeating: "1", count: operators + 1).joined(separator: "+")
        #expect(BracketingOutcomes.allValues(expression) == Array(repeating: operators + 1, count: catalan[operators]))
    }

    @Test("Matches a bottom-up table on 300 random expressions")
    func randomSmall() {
        var random = BracketingRandom(seed: 241)
        let symbols: [Character] = ["+", "-", "*"]
        for _ in 0..<300 {
            let count = Int.random(in: 1...7, using: &random)
            let numbers = (0..<count).map { _ in Int.random(in: 0...30, using: &random) }
            let operators = (0..<(count - 1)).map { _ in symbols[Int.random(in: 0..<3, using: &random)] }
            #expect(BracketingOutcomes.allValues(text(numbers, operators)) == reference(numbers, operators))
        }
    }

    @Test("Ten operators: 16,796 bracketings")
    func largest() {
        var random = BracketingRandom(seed: 1_962)
        let symbols: [Character] = ["+", "-", "*"]
        for _ in 0..<3 {
            let numbers = (0..<11).map { _ in Int.random(in: 0...30, using: &random) }
            let operators = (0..<10).map { _ in symbols[Int.random(in: 0..<3, using: &random)] }
            let values = BracketingOutcomes.allValues(text(numbers, operators))
            #expect(values.count == 16_796)
            #expect(values == reference(numbers, operators))
        }
        let biggest = BracketingOutcomes.allValues("30*30*30*30*30*30*30*30*30*30*30")
        #expect(biggest == Array(repeating: 17_714_700_000_000_000, count: 16_796))
    }
}
