import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RoundingDivisionTests {
    @Test("Small values, every sign", arguments: [
        (7, 2, 3, 4), (-7, 2, -4, -3), (7, -2, -4, -3), (-7, -2, 3, 4), (-6, 3, -2, -2),
        (6, -3, -2, -2), (0, -5, 0, 0), (-1, 10, -1, 0), (1, 10, 0, 1), (5, 1, 5, 5), (-5, -1, 5, 5),
    ])
    func small(a: Int, b: Int, floor: Int, ceiling: Int) {
        #expect(RoundingDivision.floorQuotient(a, b) == floor)
        #expect(RoundingDivision.ceilingQuotient(a, b) == ceiling)
    }

    @Test("Matches a reference built from multiplication, for every small pair")
    func matchesDefinition() {
        var wrong: [String] = []
        for a in -60...60 {
            for b in -12...12 where b != 0 {
                // the floor is the largest q with q × b ≤ a (for b > 0) or q × b ≥ a (for b < 0)
                var q = -100
                while b > 0 ? (q + 1) * b <= a : (q + 1) * b >= a {
                    q += 1
                }
                let floor = q
                let ceiling = floor * b == a ? floor : floor + 1
                if RoundingDivision.floorQuotient(a, b) != floor || RoundingDivision.ceilingQuotient(a, b) != ceiling {
                    wrong.append("\(a) / \(b)")
                }
            }
        }
        #expect(wrong.isEmpty, "wrong for \(Array(wrong.prefix(5)))")
    }

    @Test("The extremes of Int")
    func extremes() {
        #expect(RoundingDivision.floorQuotient(Int.max, 2) == 4_611_686_018_427_387_903)
        #expect(RoundingDivision.ceilingQuotient(Int.max, 2) == 4_611_686_018_427_387_904)
        #expect(RoundingDivision.floorQuotient(Int.min, 2) == -4_611_686_018_427_387_904)
        #expect(RoundingDivision.ceilingQuotient(Int.min, 2) == -4_611_686_018_427_387_904)
        #expect(RoundingDivision.floorQuotient(Int.min, 3) == -3_074_457_345_618_258_603)
        #expect(RoundingDivision.ceilingQuotient(Int.min, 3) == -3_074_457_345_618_258_602)
        #expect(RoundingDivision.floorQuotient(Int.min, -2) == 4_611_686_018_427_387_904)
        #expect(RoundingDivision.floorQuotient(Int.min, Int.max) == -2)
        #expect(RoundingDivision.ceilingQuotient(Int.min, Int.max) == -1)
        #expect(RoundingDivision.floorQuotient(Int.max, Int.min) == -1)
        #expect(RoundingDivision.ceilingQuotient(Int.max, Int.min) == 0)
        #expect(RoundingDivision.ceilingQuotient(Int.max, 1) == Int.max)
        #expect(RoundingDivision.floorQuotient(Int.min, 1) == Int.min)
        #expect(RoundingDivision.ceilingQuotient(Int.max - 1, 3) == 3_074_457_345_618_258_602)
    }

    @Test("Values a Double can't hold exactly")
    func beyondDouble() {
        #expect(RoundingDivision.ceilingQuotient(9_007_199_254_740_993, 2) == 4_503_599_627_370_497)
        #expect(RoundingDivision.floorQuotient(-9_007_199_254_740_993, 2) == -4_503_599_627_370_497)
        #expect(RoundingDivision.floorQuotient(999_999_999_999_999_999, 1_000) == 999_999_999_999_999)
        #expect(RoundingDivision.ceilingQuotient(999_999_999_999_999_999, 1_000) == 1_000_000_000_000_000)
    }

    @Test("Offsets", arguments: [
        (-1, 10, 9), (-10, 10, 0), (-11, 10, 9), (25, 10, 5), (0, 7, 0), (7, 1, 0), (-7, 1, 0), (-3, 4, 1),
    ])
    func offsets(a: Int, b: Int, expected: Int) {
        #expect(RoundingDivision.offset(a, within: b) == expected)
    }

    @Test("Offsets with huge blocks, where adding b first would overflow")
    func offsetsHuge() {
        #expect(RoundingDivision.offset(5, within: Int.max) == 5)
        #expect(RoundingDivision.offset(-5, within: Int.max) == Int.max - 5)
        #expect(RoundingDivision.offset(Int.min, within: Int.max) == Int.max - 1)
        #expect(RoundingDivision.offset(Int.max, within: Int.max) == 0)
        #expect(RoundingDivision.offset(Int.min, within: 3) == 1)
        #expect(RoundingDivision.offset(Int.max - 1, within: Int.max - 2) == 1)
    }

    @Test("Floor and offset rebuild a, for blocks of every small size")
    func floorAndOffsetAgree() {
        var wrong: [String] = []
        for a in -100...100 {
            for b in 1...15 {
                let offset = RoundingDivision.offset(a, within: b)
                if !(0..<b).contains(offset) || RoundingDivision.floorQuotient(a, b) * b + offset != a {
                    wrong.append("\(a) within \(b)")
                }
            }
        }
        #expect(wrong.isEmpty, "wrong for \(Array(wrong.prefix(5)))")
    }
}
