import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RangeClampTests {
    @Test("Values inside the range are unchanged", arguments: [5, 0, 10, 7])
    func inside(value: Int) {
        #expect(RangeClamp.clamp(value, to: 0...10) == value)
    }

    @Test("Values below the range become the lower end", arguments: [-1, -50, Int.min])
    func below(value: Int) {
        #expect(RangeClamp.clamp(value, to: 0...10) == 0)
    }

    @Test("Values above the range become the upper end", arguments: [11, 99, Int.max])
    func above(value: Int) {
        #expect(RangeClamp.clamp(value, to: 0...10) == 10)
    }

    @Test("Works with a range of negative numbers", arguments: [
        (-30, -20),
        (-20, -20),
        (-15, -15),
        (-10, -10),
        (0, -10),
    ])
    func negativeRange(value: Int, expected: Int) {
        #expect(RangeClamp.clamp(value, to: -20...(-10)) == expected)
    }

    @Test("A range of one value always gives that value", arguments: [-5, 3, 4, 100])
    func singleValue(value: Int) {
        #expect(RangeClamp.clamp(value, to: 4...4) == 4)
    }
}
