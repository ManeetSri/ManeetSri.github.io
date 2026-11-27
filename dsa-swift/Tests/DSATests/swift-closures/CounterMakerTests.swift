import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CounterMakerTests {
    @Test("Counts 0, 1, 2, … by default")
    func defaults() {
        let counter = CounterMaker.makeCounter()
        #expect(counter() == 0)
        #expect(counter() == 1)
        #expect(counter() == 2)
    }

    @Test("Starts from a custom value")
    func customStart() {
        let counter = CounterMaker.makeCounter(start: 10)
        #expect(counter() == 10)
        #expect(counter() == 11)
    }

    @Test("Uses a custom step")
    func customStep() {
        let counter = CounterMaker.makeCounter(start: 5, step: 2)
        #expect([counter(), counter(), counter()] == [5, 7, 9])
        let byTens = CounterMaker.makeCounter(step: 10)
        #expect([byTens(), byTens(), byTens()] == [0, 10, 20])
    }

    @Test("Can count down")
    func negativeStep() {
        let counter = CounterMaker.makeCounter(start: 10, step: -3)
        #expect([counter(), counter(), counter(), counter(), counter()] == [10, 7, 4, 1, -2])
    }

    @Test("A step of 0 always returns the start")
    func zeroStep() {
        let counter = CounterMaker.makeCounter(start: 4, step: 0)
        #expect([counter(), counter(), counter()] == [4, 4, 4])
    }

    @Test("Counters made separately are independent")
    func independent() {
        let first = CounterMaker.makeCounter()
        let second = CounterMaker.makeCounter()
        #expect(first() == 0)
        #expect(first() == 1)
        #expect(second() == 0)
        #expect(first() == 2)
        #expect(second() == 1)
    }

    @Test("Two names for one counter share its count")
    func shared() {
        let counter = CounterMaker.makeCounter(start: 1)
        let sameCounter = counter
        #expect(counter() == 1)
        #expect(sameCounter() == 2)
        #expect(counter() == 3)
    }

    @Test("Keeps counting over many calls")
    func manyCalls() {
        let counter = CounterMaker.makeCounter(start: 0, step: 3)
        var last = -1
        for _ in 0..<1_000 {
            last = counter()
        }
        #expect(last == 2_997)
    }
}
