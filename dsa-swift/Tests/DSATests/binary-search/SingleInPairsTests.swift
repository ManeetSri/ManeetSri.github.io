import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SingleInPairsTests {
    @Test("Finds the single value", arguments: [
        ([1, 1, 2, 3, 3, 4, 4, 8, 8], 2),
        ([3, 3, 7, 7, 10, 11, 11], 10),
        ([5, 6, 6, 9, 9], 5),
        ([1, 1, 4, 4, 6], 6),
        ([-9, -9, -4, -2, -2], -4),
    ])
    func finds(numbers: [Int], expected: Int) {
        #expect(SingleInPairs.single(in: numbers) == expected)
    }

    @Test("A single value on its own")
    func alone() {
        #expect(SingleInPairs.single(in: [42]) == 42)
        #expect(SingleInPairs.single(in: [-1]) == -1)
    }

    @Test("Three values: the single one first or last")
    func three() {
        #expect(SingleInPairs.single(in: [2, 5, 5]) == 2)
        #expect(SingleInPairs.single(in: [2, 2, 5]) == 5)
    }

    @Test("The extremes of Int")
    func extremes() {
        #expect(SingleInPairs.single(in: [Int.min, Int.min, Int.max]) == Int.max)
        #expect(SingleInPairs.single(in: [Int.min, Int.max, Int.max]) == Int.min)
    }

    @Test("Every position of the single value, for up to 15 pairs")
    func everyPosition() {
        var firstMismatch: String? = nil
        for pairs in 0...15 {
            for single in 0...pairs {
                // Values 0...pairs, each twice except `single`, spaced 3 apart
                var numbers: [Int] = []
                for value in 0...pairs {
                    numbers.append(value * 3)
                    if value != single {
                        numbers.append(value * 3)
                    }
                }
                if SingleInPairs.single(in: numbers) != single * 3 {
                    firstMismatch = firstMismatch ?? "\(numbers)"
                }
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer is wrong")
    }

    @Test("Two million values, with the single one in 1,000 places")
    func large() {
        let pairs = 1_000_000
        // Values 0...pairs, with the single value s at index 2s. Moving s on by one changes one element:
        // index 2s + 1 becomes s, completing s's pair, and s + 1 is left alone at index 2s + 2.
        var numbers: [Int] = []
        numbers.reserveCapacity(2 * pairs + 1)
        numbers.append(0)
        for value in 1...pairs {
            numbers.append(value)
            numbers.append(value)
        }
        var wrong = 0
        for s in 0..<pairs {
            if s > 0 {
                numbers[2 * s - 1] = s - 1
            }
            if s % 1_000 == 0 && SingleInPairs.single(in: numbers) != s {
                wrong += 1
            }
        }
        #expect(wrong == 0)
    }
}
