import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct DiceExactOddsTests {
    typealias Fraction = DiceExactOdds.Fraction

    static func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }

    // Every outcome of a few small dice, listed one by one
    static func outcomes(dice: Int, faces: Int) -> [[Int]] {
        var all: [[Int]] = [[]]
        for _ in 0..<dice {
            all = all.flatMap { roll in (1...faces).map { roll + [$0] } }
        }
        return all
    }

    @Test("Sum examples", arguments: [
        (7, 2, 6, 1, 6), (2, 2, 6, 1, 36), (10, 3, 6, 1, 8), (1, 2, 6, 0, 1), (3, 1, 6, 1, 6),
        (14, 4, 6, 73, 648), (11, 2, 12, 5, 72), (13, 2, 6, 0, 1), (-4, 3, 6, 0, 1), (4, 2, 2, 1, 4),
    ])
    func sumExamples(target: Int, dice: Int, faces: Int, numerator: Int, denominator: Int) {
        #expect(DiceExactOdds.sumChance(of: target, dice: dice, faces: faces) == Fraction(numerator: numerator, denominator: denominator))
    }

    @Test("Sums match listing every outcome, for small dice")
    func sumsMatchListing() {
        var wrong: [String] = []
        for dice in 1...4 {
            for faces in 2...5 {
                let all = Self.outcomes(dice: dice, faces: faces)
                for target in -1...(dice * faces + 1) {
                    let count = all.filter { $0.reduce(0, +) == target }.count
                    let g = Self.gcd(count, all.count)
                    let expected = Fraction(numerator: count / g, denominator: all.count / g)
                    if DiceExactOdds.sumChance(of: target, dice: dice, faces: faces) != expected {
                        wrong.append("target \(target), \(dice) dice, \(faces) faces")
                    }
                }
            }
        }
        #expect(wrong.isEmpty, "wrong for \(Array(wrong.prefix(5)))")
    }

    @Test("Ten dice: far too many outcomes to list")
    func sumsLarge() {
        #expect(DiceExactOdds.sumChance(of: 35, dice: 10, faces: 6) == Fraction(numerator: 7_631, denominator: 104_976))
        #expect(DiceExactOdds.sumChance(of: 50, dice: 10, faces: 6) == Fraction(numerator: 21_307, denominator: 15_116_544))
        #expect(DiceExactOdds.sumChance(of: 105, dice: 10, faces: 20) == Fraction(numerator: 2_757_920_191, denominator: 128_000_000_000))
        #expect(DiceExactOdds.sumChance(of: 10, dice: 10, faces: 20) == Fraction(numerator: 1, denominator: 10_240_000_000_000))
        #expect(DiceExactOdds.sumChance(of: 200, dice: 10, faces: 20) == Fraction(numerator: 1, denominator: 10_240_000_000_000))
        #expect(DiceExactOdds.sumChance(of: 201, dice: 10, faces: 20) == Fraction(numerator: 0, denominator: 1))
    }

    @Test("The chances of every total add up to 1")
    func sumsAddToOne() throws {
        var top = 0
        let denominator = 6 * 6 * 6 * 6 * 6
        for target in 5...30 {
            let chance = DiceExactOdds.sumChance(of: target, dice: 5, faces: 6)
            try #require(chance.denominator > 0 && denominator % chance.denominator == 0)
            top += chance.numerator * (denominator / chance.denominator)
        }
        #expect(top == denominator)
    }

    @Test("Expected highest examples", arguments: [
        (1, 6, 7, 2), (2, 6, 161, 36), (3, 6, 119, 24), (4, 2, 31, 16), (1, 20, 21, 2), (5, 10, 35_167, 4_000),
    ])
    func highestExamples(dice: Int, faces: Int, numerator: Int, denominator: Int) {
        #expect(DiceExactOdds.expectedHighest(dice: dice, faces: faces) == Fraction(numerator: numerator, denominator: denominator))
    }

    @Test("Expected highest matches listing every outcome")
    func highestMatchesListing() {
        var wrong: [String] = []
        for dice in 1...4 {
            for faces in 2...6 {
                let all = Self.outcomes(dice: dice, faces: faces)
                let total = all.reduce(0) { $0 + $1.max()! }
                let g = Self.gcd(total, all.count)
                if DiceExactOdds.expectedHighest(dice: dice, faces: faces) != Fraction(numerator: total / g, denominator: all.count / g) {
                    wrong.append("\(dice) dice, \(faces) faces")
                }
            }
        }
        #expect(wrong.isEmpty, "wrong for \(wrong)")
    }

    @Test("Expected highest for ten twenty-sided dice")
    func highestLarge() {
        #expect(DiceExactOdds.expectedHighest(dice: 10, faces: 20) == Fraction(numerator: 3_817_528_566_383, denominator: 204_800_000_000))
    }
}
