import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ClampWithDefaultsTests {
    @Test("Uses the default bounds 0...100", arguments: [(42, 42), (150, 100), (-5, 0), (0, 0), (100, 100)])
    func defaultBounds(value: Int, expected: Int) {
        #expect(ClampWithDefaults.clamp(value) == expected)
    }

    @Test("Uses a custom lower bound")
    func customLower() {
        #expect(ClampWithDefaults.clamp(5, lower: 10) == 10)
        #expect(ClampWithDefaults.clamp(50, lower: 10) == 50)
        #expect(ClampWithDefaults.clamp(500, lower: 10) == 100)
    }

    @Test("Uses a custom upper bound")
    func customUpper() {
        #expect(ClampWithDefaults.clamp(5, upper: 3) == 3)
        #expect(ClampWithDefaults.clamp(-1, upper: 3) == 0)
    }

    @Test("Uses both custom bounds, including negative ones")
    func bothBounds() {
        #expect(ClampWithDefaults.clamp(-20, lower: -10, upper: 10) == -10)
        #expect(ClampWithDefaults.clamp(20, lower: -10, upper: 10) == 10)
        #expect(ClampWithDefaults.clamp(-3, lower: -10, upper: 10) == -3)
    }

    @Test("Works when the bounds are equal")
    func equalBounds() {
        #expect(ClampWithDefaults.clamp(99, lower: 7, upper: 7) == 7)
        #expect(ClampWithDefaults.clamp(-99, lower: 7, upper: 7) == 7)
    }

    @Test("Handles the extremes of Int")
    func extremes() {
        #expect(ClampWithDefaults.clamp(Int.max) == 100)
        #expect(ClampWithDefaults.clamp(Int.min) == 0)
    }
}
