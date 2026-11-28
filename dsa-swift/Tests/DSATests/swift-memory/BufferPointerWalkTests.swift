import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BufferPointerWalkTests {
    @Test("sum adds every element", arguments: [
        ([3, 1, 4, 1, 5], 14),
        ([], 0),
        ([42], 42),
        ([-5, 10, -20], -15),
        ([Int.max, Int.min], -1),
    ])
    func sum(numbers: [Int], expected: Int) {
        #expect(BufferPointerWalk.sum(numbers) == expected)
    }

    @Test("sum of 100,000 numbers")
    func largeSum() {
        #expect(BufferPointerWalk.sum(Array(1...100_000)) == 5_000_050_000)
    }

    @Test("reverseInPlace reverses the caller's array", arguments: [
        ([1, 2, 3, 4], [4, 3, 2, 1]),
        ([1, 2, 3], [3, 2, 1]),
        ([7], [7]),
        ([], []),
        ([5, 5, 1], [1, 5, 5]),
    ])
    func reverse(numbers: [Int], expected: [Int]) {
        var values = numbers
        BufferPointerWalk.reverseInPlace(&values)
        #expect(values == expected)
    }

    @Test("Reversing twice gives back the original")
    func reverseTwice() {
        let original = Array(0..<10_001)
        var values = original
        BufferPointerWalk.reverseInPlace(&values)
        #expect(values.first == 10_000)
        #expect(values.last == 0)
        BufferPointerWalk.reverseInPlace(&values)
        #expect(values == original)
    }

    @Test("Reversing a copy leaves the original alone")
    func reverseCopy() {
        let original = [1, 2, 3]
        var copy = original
        BufferPointerWalk.reverseInPlace(&copy)
        #expect(original == [1, 2, 3])
        #expect(copy == [3, 2, 1])
    }

    @Test("sample picks every step-th element from the start", arguments: [
        ([10, 11, 12, 13, 14, 15, 16], 2, [10, 12, 14, 16]),
        ([10, 11, 12, 13, 14, 15, 16], 3, [10, 13, 16]),
        ([10, 11, 12], 1, [10, 11, 12]),
        ([10, 11, 12], 5, [10]),
        ([9], 1, [9]),
        ([], 2, []),
    ])
    func sample(numbers: [Int], step: Int, expected: [Int]) {
        #expect(BufferPointerWalk.sample(numbers, every: step) == expected)
    }

    @Test("sample from a large array")
    func largeSample() {
        let picked = BufferPointerWalk.sample(Array(0..<100_000), every: 1_000)
        #expect(picked.count == 100)
        #expect(picked.first == 0)
        #expect(picked.last == 99_000)
    }
}
