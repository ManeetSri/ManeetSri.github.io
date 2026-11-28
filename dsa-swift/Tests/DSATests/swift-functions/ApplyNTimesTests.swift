import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ApplyNTimesTests {
    @Test("Doubling repeatedly gives powers of two")
    func doubling() {
        #expect(ApplyNTimes.apply({ $0 * 2 }, times: 3, to: 1) == 8)
        #expect(ApplyNTimes.apply({ $0 * 2 }, times: 10, to: 1) == 1024)
    }

    @Test("Adding one n times adds n")
    func addingOne() {
        #expect(ApplyNTimes.apply({ $0 + 1 }, times: 5, to: 10) == 15)
        #expect(ApplyNTimes.apply({ $0 + 1 }, times: 1_000, to: -500) == 500)
    }

    @Test("Applying zero times returns the value unchanged", arguments: [0, 7, -3])
    func zeroTimes(value: Int) {
        #expect(ApplyNTimes.apply({ $0 * 100 }, times: 0, to: value) == value)
    }

    @Test("Applying once is one call")
    func once() {
        #expect(ApplyNTimes.apply({ $0 * $0 }, times: 1, to: 9) == 81)
    }

    @Test("Each step uses the previous result")
    func chaining() {
        // 3 → 9 → 81
        #expect(ApplyNTimes.apply({ $0 * $0 }, times: 2, to: 3) == 81)
        // 100 → 50 → 25 → 12 → 6
        #expect(ApplyNTimes.apply({ $0 / 2 }, times: 4, to: 100) == 6)
    }

    @Test("Calls the function exactly n times")
    func callCount() {
        var calls = 0
        let result = ApplyNTimes.apply({ value in
            calls += 1
            return value - 2
        }, times: 6, to: 0)
        #expect(result == -12)
        #expect(calls == 6)
    }
}
