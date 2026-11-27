import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ZeroesToTheFrontTests {
    private func gathered(_ numbers: [Int]) -> [Int] {
        var values = numbers
        ZeroesToTheFront.gather(&values)
        return values
    }

    // The straightforward version, building a new array
    private func expected(_ numbers: [Int]) -> [Int] {
        numbers.filter { $0 == 0 } + numbers.filter { $0 != 0 }
    }

    @Test("Moves zeroes to the front, keeping the order of the rest", arguments: [
        ([1, 0, 2, 0, 3], [0, 0, 1, 2, 3]),
        ([0, 5, 0], [0, 0, 5]),
        ([3, 1, 0], [0, 3, 1]),
        ([7, 0, 0, 0, 4, 0, 9], [0, 0, 0, 0, 7, 4, 9]),
        ([-2, 0, 5, -2], [0, -2, 5, -2]),
        ([1, 2, 3, 0], [0, 1, 2, 3]),
    ])
    func gathers(numbers: [Int], expected: [Int]) {
        #expect(gathered(numbers) == expected)
    }

    @Test("Arrays with no zeroes, or only zeroes, are unchanged", arguments: [
        [Int](),
        [8],
        [0],
        [4, -1, 7],
        [0, 0, 0],
        [0, 0, 1, 2],
    ])
    func unchanged(numbers: [Int]) {
        #expect(gathered(numbers) == numbers)
    }

    @Test("Matches building a new array on many small arrays")
    func matchesNewArray() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<400 {
            let numbers = (0..<(seed % 10)).map { ($0 * 7 + seed * 3) % 5 - 1 }
            if gathered(numbers) != expected(numbers) {
                firstMismatch = firstMismatch ?? numbers
            }
        }
        #expect(firstMismatch == nil, "the first array where the result is wrong")
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        let numbers = (0..<100_000).map { $0 % 3 == 0 ? 0 : $0 }
        let result = gathered(numbers)
        #expect(result.count == numbers.count)
        #expect(result == expected(numbers))
    }
}
