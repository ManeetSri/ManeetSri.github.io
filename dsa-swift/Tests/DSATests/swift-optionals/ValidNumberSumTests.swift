import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ValidNumberSumTests {
    @Test("Adds the valid numbers and ignores the rest", arguments: [
        (["4", "x", "10"], 14),
        (["12", "30", "8"], 50),
        (["7"], 7),
        (["-5", "20", "oops"], 15),
        (["+3", "007"], 10),
    ])
    func sums(texts: [String], expected: Int) {
        #expect(ValidNumberSum.sum(of: texts) == expected)
    }

    @Test("Decimals, spaces and empty strings are not whole numbers")
    func strictParsing() {
        #expect(ValidNumberSum.sum(of: ["2.5", " 4", "", "6 ", "1"]) == 1)
    }

    @Test("A total of zero is still a total", arguments: [["0"], ["-5", "5"], ["0", "zero"]])
    func zeroTotal(texts: [String]) {
        #expect(ValidNumberSum.sum(of: texts) == 0)
    }

    @Test("Returns nil when there are no valid numbers", arguments: [["a", ""], ["one", "two"], ["1.5"], []])
    func noNumbers(texts: [String]) {
        #expect(ValidNumberSum.sum(of: texts) == nil)
    }

    @Test("Numbers too big for an Int are ignored")
    func tooBig() {
        #expect(ValidNumberSum.sum(of: ["99999999999999999999", "5"]) == 5)
    }

    @Test("Handles 10,000 strings")
    func large() {
        var texts: [String] = []
        for i in 1...10_000 {
            texts.append(i % 2 == 0 ? "\(i)" : "n\(i)")
        }
        #expect(ValidNumberSum.sum(of: texts) == 25_005_000)
    }
}
