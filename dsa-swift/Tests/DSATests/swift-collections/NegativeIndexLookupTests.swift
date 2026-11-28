import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NegativeIndexLookupTests {
    static let numbers = [10, 20, 30, 40]

    @Test("Counts from the front for 0 and above", arguments: [(0, 10), (1, 20), (2, 30), (3, 40)])
    func front(position: Int, expected: Int) {
        #expect(NegativeIndexLookup.element(in: Self.numbers, at: position) == expected)
    }

    @Test("Counts from the back for negative positions", arguments: [(-1, 40), (-2, 30), (-3, 20), (-4, 10)])
    func back(position: Int, expected: Int) {
        #expect(NegativeIndexLookup.element(in: Self.numbers, at: position) == expected)
    }

    @Test("Returns nil out of range in either direction", arguments: [4, 5, 1_000_000, -5, -6, -1_000_000])
    func outOfRange(position: Int) {
        #expect(NegativeIndexLookup.element(in: Self.numbers, at: position) == nil)
    }

    @Test("Every position of an empty array is nil", arguments: [0, -1, 1, -1_000_000, 1_000_000])
    func empty(position: Int) {
        #expect(NegativeIndexLookup.element(in: [], at: position) == nil)
    }

    @Test("A single element is both first and last")
    func single() {
        #expect(NegativeIndexLookup.element(in: [7], at: 0) == 7)
        #expect(NegativeIndexLookup.element(in: [7], at: -1) == 7)
        #expect(NegativeIndexLookup.element(in: [7], at: 1) == nil)
        #expect(NegativeIndexLookup.element(in: [7], at: -2) == nil)
    }

    @Test("Works with negative and repeated values")
    func values() {
        let values = [-3, -3, 0, -8]
        #expect(NegativeIndexLookup.element(in: values, at: -1) == -8)
        #expect(NegativeIndexLookup.element(in: values, at: 2) == 0)
        #expect(NegativeIndexLookup.element(in: values, at: -4) == -3)
    }

    @Test("Reaches both ends of 100,000 elements")
    func large() {
        let numbers = Array(0..<100_000)
        #expect(NegativeIndexLookup.element(in: numbers, at: 99_999) == 99_999)
        #expect(NegativeIndexLookup.element(in: numbers, at: -100_000) == 0)
        #expect(NegativeIndexLookup.element(in: numbers, at: -1) == 99_999)
        #expect(NegativeIndexLookup.element(in: numbers, at: 100_000) == nil)
        #expect(NegativeIndexLookup.element(in: numbers, at: -100_001) == nil)
    }
}
