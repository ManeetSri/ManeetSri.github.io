import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct KaprekarTraceTests {
    @Test("Follows the routine to 6174", arguments: [
        (3524, [3524, 3087, 8352, 6174]),
        (2111, [2111, 999, 8991, 8082, 8532, 6174]),
        (1000, [1000, 999, 8991, 8082, 8532, 6174]),
        (9998, [9998, 999, 8991, 8082, 8532, 6174]),
        (21, [21, 2088, 8532, 6174]),
        (1234, [1234, 3087, 8352, 6174]),
    ])
    func reaches6174(start: Int, expected: [Int]) {
        #expect(KaprekarTrace.trace(from: start) == expected)
    }

    @Test("Stops straight away at 6174 and 0")
    func alreadyStopped() {
        #expect(KaprekarTrace.trace(from: 6174) == [6174])
        #expect(KaprekarTrace.trace(from: 0) == [0])
    }

    @Test("Four equal digits fall to 0", arguments: [1111, 2222, 5555, 9999])
    func repdigits(start: Int) {
        #expect(KaprekarTrace.trace(from: start) == [start, 0])
    }

    @Test("Leading zeros count as digits")
    func leadingZeros() {
        // 999 is 0999, so the next value is 9990 - 0999, not 999 - 999
        #expect(KaprekarTrace.trace(from: 999) == [999, 8991, 8082, 8532, 6174])
        #expect(KaprekarTrace.trace(from: 1) == [1, 999, 8991, 8082, 8532, 6174])
    }

    @Test("Every start from 0 to 9999 stops within seven steps")
    func everyStart() {
        var longest = 0
        var firstWrong: Int? = nil
        for start in 0...9999 {
            let trace = KaprekarTrace.trace(from: start)
            let text = String(start)
            let fourEqualDigits = text.count == 4 && Set(text).count == 1
            let expectedEnd = start == 0 || fourEqualDigits ? 0 : 6174
            if trace.first != start || trace.last != expectedEnd || trace.count > 8 {
                firstWrong = firstWrong ?? start
            }
            longest = max(longest, trace.count)
        }
        #expect(firstWrong == nil, "the first start with a wrong trace")
        #expect(longest == 8)
    }
}
