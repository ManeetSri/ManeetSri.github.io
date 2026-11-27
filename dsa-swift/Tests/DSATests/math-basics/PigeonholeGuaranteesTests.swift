import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PigeonholeGuaranteesTests {
    @Test("Sock examples")
    func sockExamples() {
        #expect(PigeonholeGuarantees.drawsToGuarantee(matching: 2, counts: [5, 5, 5]) == 4)
        #expect(PigeonholeGuarantees.drawsToGuarantee(matching: 3, counts: [2, 10, 1]) == 6)
        #expect(PigeonholeGuarantees.drawsToGuarantee(matching: 4, counts: [3, 3]) == nil)
    }

    @Test("Edge cases for socks")
    func sockEdges() {
        #expect(PigeonholeGuarantees.drawsToGuarantee(matching: 1, counts: [0, 4]) == 1)
        #expect(PigeonholeGuarantees.drawsToGuarantee(matching: 1, counts: [0, 0]) == nil)
        #expect(PigeonholeGuarantees.drawsToGuarantee(matching: 5, counts: [5]) == 5)
        #expect(PigeonholeGuarantees.drawsToGuarantee(matching: 2, counts: [1, 1, 1, 2]) == 5)
        #expect(PigeonholeGuarantees.drawsToGuarantee(matching: 3, counts: [0, 0, 7, 0]) == 3)
    }

    @Test("Birthday months: 9 in a month is guaranteed with 97 people")
    func months() {
        #expect(PigeonholeGuarantees.drawsToGuarantee(matching: 9, counts: Array(repeating: 1_000, count: 12)) == 97)
        #expect(PigeonholeGuarantees.drawsToGuarantee(matching: 2, counts: Array(repeating: 1_000, count: 12)) == 13)
    }

    @Test("Large drawers")
    func largeDrawers() {
        let counts = Array(repeating: 1_000_000_000, count: 100_000)
        #expect(PigeonholeGuarantees.drawsToGuarantee(matching: 1_000_000_000, counts: counts) == 99_999_999_900_001)
        let mixed = (0..<100_000).map { $0 % 2 == 0 ? 7 : 1_000_000_000 }
        #expect(PigeonholeGuarantees.drawsToGuarantee(matching: 10, counts: mixed) == 50_000 * 7 + 50_000 * 9 + 1)
    }

    @Test("Remainder examples")
    func remainderExamples() {
        let first = PigeonholeGuarantees.sharedRemainder([3, 9, 4, 7])
        #expect(first.first == 0 && first.second == 1)
        let second = PigeonholeGuarantees.sharedRemainder([1, 5, -2, 8, 6])
        #expect(second.first == 0 && second.second == 1)
        let third = PigeonholeGuarantees.sharedRemainder([2, 7, 4, 13, 9])
        #expect(third.first == 3 && third.second == 4)
    }

    @Test("Negative values need a non-negative remainder")
    func negatives() {
        // modulo 3: -1 → 2, 4 → 1, -6 → 0, 5 → 2
        let pair = PigeonholeGuarantees.sharedRemainder([-1, 4, -6, 5])
        #expect(pair.first == 0 && pair.second == 3)
        // modulo 2: -3 and 7 are both odd
        let odd = PigeonholeGuarantees.sharedRemainder([-3, 10, 7])
        #expect(odd.first == 0 && odd.second == 2)
        // modulo 1, everything collides
        let one = PigeonholeGuarantees.sharedRemainder([-1_000_000_000_000_000_000, 1_000_000_000_000_000_000])
        #expect(one.first == 0 && one.second == 1)
    }

    @Test("The pair found ends as early as possible, on many inputs")
    func earliestPair() {
        var seed = 99
        func next() -> Int {
            seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
            return seed % 2_001 - 1_000
        }
        for size in 2...60 {
            let numbers = (0..<size).map { _ in next() }
            let n = size - 1
            let pair = PigeonholeGuarantees.sharedRemainder(numbers)
            // the earliest j with an earlier i of the same remainder
            var expected = (first: -1, second: -1)
            search: for j in 1..<size {
                for i in 0..<j where (numbers[j] - numbers[i]) % n == 0 {
                    expected = (i, j)
                    break search
                }
            }
            #expect(pair.first == expected.first && pair.second == expected.second, "numbers \(numbers)")
        }
    }

    @Test("A hundred thousand values, with the collision at the very end")
    func large() {
        let n = 100_000
        var numbers = (0..<n).map { $0 * 3 + 1_000_000_000_000 }
        // values 3i + 10¹² all differ modulo 10⁵; the last one, like numbers[0], is a multiple of 10⁵
        numbers.append(-7_000_000_000_000_000)
        let pair = PigeonholeGuarantees.sharedRemainder(numbers)
        #expect(pair.first == 0 && pair.second == n)
    }
}
