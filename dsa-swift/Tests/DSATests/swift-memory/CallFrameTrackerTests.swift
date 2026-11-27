import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CallFrameTrackerTests {
    typealias Report = CallFrameTracker.Report

    @Test("Frames come and go; the peak is the deepest moment")
    func nestedCalls() {
        let events = [
            "call main 32",
            "call sumDigits 48", "call sumDigits 48", "return", "return",
            "call print 16", "return",
            "return",
        ]
        #expect(CallFrameTracker.analyse(events, limit: 1_000) == Report(peakBytes: 128, peakDepth: 3, overflowIndex: nil))
    }

    @Test("A return frees its frame at once, so siblings reuse the space")
    func siblingsReuseSpace() {
        let events = ["call main 10", "call a 100", "return", "call b 100", "return", "call c 100", "return", "return"]
        #expect(CallFrameTracker.analyse(events, limit: 1_000) == Report(peakBytes: 110, peakDepth: 2, overflowIndex: nil))
    }

    @Test("The most bytes and the most frames can happen at different times")
    func peaksAtDifferentTimes() {
        let events = ["call main 8", "call big 500", "return", "call f 8", "call f 8", "call f 8", "return", "return", "return"]
        #expect(CallFrameTracker.analyse(events, limit: 1_000) == Report(peakBytes: 508, peakDepth: 4, overflowIndex: nil))
    }

    @Test("Deep recursion overflows the stack")
    func overflow() {
        let events = ["call main 32", "call f 48", "call f 48", "call f 48", "call f 48", "return", "return"]
        #expect(CallFrameTracker.analyse(events, limit: 200) == Report(peakBytes: 176, peakDepth: 4, overflowIndex: 4))
    }

    @Test("Filling the stack exactly is fine")
    func exactlyFull() {
        let events = ["call main 100", "call f 100", "return", "return"]
        #expect(CallFrameTracker.analyse(events, limit: 200) == Report(peakBytes: 200, peakDepth: 2, overflowIndex: nil))
    }

    @Test("Even the first call can overflow")
    func firstCallOverflows() {
        #expect(CallFrameTracker.analyse(["call main 64", "return"], limit: 32) == Report(peakBytes: 0, peakDepth: 0, overflowIndex: 0))
    }

    @Test("No events, no stack")
    func noEvents() {
        #expect(CallFrameTracker.analyse([], limit: 100) == Report(peakBytes: 0, peakDepth: 0, overflowIndex: nil))
    }

    @Test("100,000 nested calls against an 8 MB stack, then a smaller one")
    func longRecursion() {
        var events = ["call main 64"]
        for _ in 0..<100_000 {
            events.append("call countdown 80")
        }
        let report = CallFrameTracker.analyse(events, limit: 8_388_608)
        #expect(report == Report(peakBytes: 8_000_064, peakDepth: 100_001, overflowIndex: nil))
        let tight = CallFrameTracker.analyse(events, limit: 800_064)
        #expect(tight == Report(peakBytes: 800_064, peakDepth: 10_001, overflowIndex: 10_001))
    }
}
