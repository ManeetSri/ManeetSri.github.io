import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SafeDialCodesTests {
    /// Every way to split `total` into `parts` numbers from 0 to 9, in increasing order, kept only when
    /// no two neighbours are equal. With `fromNine`, each number is how far its digit is below 9.
    private func splits(_ total: Int, into parts: Int, fromNine: Bool = false) -> [String] {
        var found: [String] = []
        var current: [Int] = []
        func build(_ left: Int) {
            if current.count == parts {
                if left == 0 {
                    let digits = fromNine ? current.map { 9 - $0 } : current
                    if zip(digits, digits.dropFirst()).allSatisfy({ $0 != $1 }) {
                        found.append(digits.map(String.init).joined())
                    }
                }
                return
            }
            for part in 0...min(9, left) {
                current.append(part)
                build(left - part)
                current.removeLast()
            }
        }
        build(total)
        return found.sorted()
    }

    @Test("Examples and small cases", arguments: [
        (2, 1, ["01", "10"]),
        (1, 0, ["0"]),
        (1, 9, ["9"]),
        (1, 10, []),
        (2, 17, ["89", "98"]),
        (2, 18, []),                                   // 99 has equal neighbours
        (2, 0, []),
        (3, 26, ["989"]),
        (4, 3, ["0102", "0120", "0201", "0210", "1020", "2010"]),
        (12, 0, []),
    ] as [(Int, Int, [String])])
    func examples(length: Int, digitSum: Int, expected: [String]) {
        #expect(SafeDialCodes.codes(length: length, digitSum: digitSum) == expected)
    }

    @Test("Three digits adding up to 5")
    func threeDigits() {
        let expected = ["014", "023", "032", "041", "050", "104", "131", "140", "203", "212", "230", "302", "320", "401", "410"]
        #expect(SafeDialCodes.codes(length: 3, digitSum: 5) == expected)
    }

    @Test("Every code of up to 5 digits, checked one by one", arguments: 1...5)
    func everyCode(length: Int) {
        // Count up through every number with `length` digits, keeping the valid ones by digit sum
        var bySum: [[String]] = Array(repeating: [], count: 9 * length + 2)
        var limit = 1
        for _ in 0..<length { limit *= 10 }
        for number in 0..<limit {
            var digits: [Int] = []
            var rest = number
            for _ in 0..<length {
                digits.append(rest % 10)
                rest /= 10
            }
            digits.reverse()
            if zip(digits, digits.dropFirst()).allSatisfy({ $0 != $1 }) {
                bySum[digits.reduce(0, +)].append(digits.map(String.init).joined())
            }
        }
        for sum in bySum.indices {
            #expect(SafeDialCodes.codes(length: length, digitSum: sum) == bySum[sum])
        }
    }

    @Test("Twelve digits with a very small or very large sum")
    func twelveDigits() {
        // The full tree has 10 · 9¹¹ leaves, about 3 × 10¹¹: these need pruning in both directions
        #expect(SafeDialCodes.codes(length: 12, digitSum: 5) == [])          // zeros can't sit together
        #expect(SafeDialCodes.codes(length: 12, digitSum: 6) == ["010101010101", "101010101010"])
        #expect(SafeDialCodes.codes(length: 12, digitSum: 8) == splits(8, into: 12))
        #expect(SafeDialCodes.codes(length: 12, digitSum: 8).count == 114)
        #expect(SafeDialCodes.codes(length: 12, digitSum: 102) == ["898989898989", "989898989898"])
        #expect(SafeDialCodes.codes(length: 12, digitSum: 101) == splits(108 - 101, into: 12, fromNine: true))
        #expect(SafeDialCodes.codes(length: 12, digitSum: 101).count == 22)
        #expect(SafeDialCodes.codes(length: 12, digitSum: 103) == [])
        #expect(SafeDialCodes.codes(length: 12, digitSum: 108) == [])
    }
}
