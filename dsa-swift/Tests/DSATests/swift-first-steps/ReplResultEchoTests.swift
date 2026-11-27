import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ReplResultEchoTests {
    @Test("Builds the REPL's line", arguments: [
        (1, 3, "$R0: Int = 3"),
        (2, 36, "$R1: Int = 36"),
        (3, 99, "$R2: Int = 99"),
    ])
    func buildsLine(position: Int, value: Int, expected: String) {
        #expect(ReplResultEcho.line(position: position, value: value) == expected)
    }

    @Test("Counts the temporary names from 0")
    func countsFromZero() {
        #expect(ReplResultEcho.line(position: 1, value: 7) == "$R0: Int = 7")
        #expect(ReplResultEcho.line(position: 10, value: 7) == "$R9: Int = 7")
        #expect(ReplResultEcho.line(position: 11, value: 7) == "$R10: Int = 7")
    }

    @Test("Shows zero and negative values as they are")
    func zeroAndNegative() {
        #expect(ReplResultEcho.line(position: 3, value: 0) == "$R2: Int = 0")
        #expect(ReplResultEcho.line(position: 11, value: -5) == "$R10: Int = -5")
    }

    @Test("Works at the ends of the allowed ranges")
    func extremes() {
        #expect(ReplResultEcho.line(position: 1_000, value: 1_000_000_000) == "$R999: Int = 1000000000")
        #expect(ReplResultEcho.line(position: 1, value: -1_000_000_000) == "$R0: Int = -1000000000")
    }
}
