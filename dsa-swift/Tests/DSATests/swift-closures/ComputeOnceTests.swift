import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ComputeOnceTests {
    @Test("Returns the computed value", arguments: [42, 7, -15, 1_000_000])
    func value(answer: Int) {
        let wrapped = ComputeOnce.wrap { answer }
        #expect(wrapped() == answer)
        #expect(wrapped() == answer)
    }

    @Test("Runs the computation only once over many calls")
    func runsOnce() {
        var runs = 0
        let wrapped = ComputeOnce.wrap {
            runs += 1
            return runs * 10
        }
        var results: [Int] = []
        for _ in 0..<1_000 {
            results.append(wrapped())
        }
        #expect(runs == 1)
        #expect(results.allSatisfy { $0 == 10 })
    }

    @Test("Waits for the first call before computing")
    func waits() {
        var runs = 0
        let wrapped = ComputeOnce.wrap {
            runs += 1
            return 99
        }
        #expect(runs == 0)
        #expect(wrapped() == 99)
        #expect(runs == 1)
    }

    @Test("Never computes if the closure is never called")
    func neverCalled() {
        var runs = 0
        _ = ComputeOnce.wrap {
            runs += 1
            return 5
        }
        #expect(runs == 0)
    }

    @Test("Remembers a result of 0 and negative results", arguments: [0, -1, -999])
    func zeroAndNegative(answer: Int) {
        var runs = 0
        let wrapped = ComputeOnce.wrap {
            runs += 1
            return answer
        }
        #expect(wrapped() == answer)
        #expect(wrapped() == answer)
        #expect(wrapped() == answer)
        #expect(runs == 1)
    }

    @Test("Each wrapper has its own memory")
    func independent() {
        var runs = 0
        let compute: () -> Int = {
            runs += 1
            return runs
        }
        let first = ComputeOnce.wrap(compute)
        let second = ComputeOnce.wrap(compute)
        #expect(first() == 1)
        #expect(second() == 2)
        #expect(first() == 1)
        #expect(second() == 2)
        #expect(runs == 2)
    }

    @Test("Two names for one wrapper share its memory")
    func shared() {
        var runs = 0
        let wrapped = ComputeOnce.wrap {
            runs += 1
            return 3
        }
        let sameWrapper = wrapped
        #expect(wrapped() == 3)
        #expect(sameWrapper() == 3)
        #expect(runs == 1)
    }
}
