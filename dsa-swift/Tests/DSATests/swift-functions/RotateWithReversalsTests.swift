import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RotateWithReversalsTests {
    @Test("Rotates to the right", arguments: [
        ([1, 2, 3, 4, 5, 6, 7], 3, [5, 6, 7, 1, 2, 3, 4]),
        ([1, 2, 3, 4, 5], 1, [5, 1, 2, 3, 4]),
        ([1, 2, 3, 4, 5], 4, [2, 3, 4, 5, 1]),
        ([10, 20], 1, [20, 10]),
        ([-1, -100, 3, 99], 2, [3, 99, -1, -100]),
    ])
    func rotates(numbers: [Int], k: Int, expected: [Int]) {
        var values = numbers
        RotateWithReversals.rotateRight(&values, by: k)
        #expect(values == expected)
    }

    @Test("Rotating by 0 or by the length changes nothing", arguments: [0, 5, 10])
    func fullTurns(k: Int) {
        var values = [1, 2, 3, 4, 5]
        RotateWithReversals.rotateRight(&values, by: k)
        #expect(values == [1, 2, 3, 4, 5])
    }

    @Test("k can be bigger than the array")
    func bigK() {
        var values = [1, 2, 3]
        RotateWithReversals.rotateRight(&values, by: 7)
        #expect(values == [3, 1, 2])
        var pair = [1, 2]
        RotateWithReversals.rotateRight(&pair, by: 1_000_000_001)
        #expect(pair == [2, 1])
    }

    @Test("Empty and single-element arrays are left alone")
    func tiny() {
        var empty: [Int] = []
        RotateWithReversals.rotateRight(&empty, by: 4)
        #expect(empty == [])
        var single = [9]
        RotateWithReversals.rotateRight(&single, by: 3)
        #expect(single == [9])
    }

    @Test("Keeps duplicates in the right places")
    func duplicates() {
        var values = [1, 1, 2, 2, 3]
        RotateWithReversals.rotateRight(&values, by: 2)
        #expect(values == [2, 3, 1, 1, 2])
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        let original = Array(0..<100_000)
        var values = original
        let k = 1_000_000_007
        RotateWithReversals.rotateRight(&values, by: k)
        let steps = k % original.count
        let expected = Array(original[(original.count - steps)...] + original[..<(original.count - steps)])
        #expect(values == expected)
    }
}
