// Reference solution: Exact dice odds. Count the ways to reach each total one die at a time instead of
// listing outcomes; for the highest face, mᵈ − (m − 1)ᵈ outcomes have highest exactly m. Reduce with
// Euclid's gcd. O(dice² × faces²) and O(faces × dice).

public enum DiceExactOdds {
    public struct Fraction: Equatable, CustomStringConvertible {
        public var numerator: Int
        public var denominator: Int

        public init(numerator: Int, denominator: Int) {
            self.numerator = numerator
            self.denominator = denominator
        }

        public var description: String { "\(numerator)/\(denominator)" }
    }

    static func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }

    static func reduced(_ numerator: Int, _ denominator: Int) -> Fraction {
        let g = gcd(numerator, denominator)      // gcd(0, d) = d, so zero becomes 0/1
        return Fraction(numerator: numerator / g, denominator: denominator / g)
    }

    static func power(_ base: Int, _ exponent: Int) -> Int {
        var result = 1
        for _ in 0..<exponent {
            result *= base
        }
        return result
    }

    public static func sumChance(of target: Int, dice: Int, faces: Int) -> Fraction {
        var ways = [1]                           // ways[s]: outcomes so far adding up to s
        for _ in 0..<dice {
            var next = Array(repeating: 0, count: ways.count + faces)
            for (total, count) in ways.enumerated() where count > 0 {
                for face in 1...faces {
                    next[total + face] += count
                }
            }
            ways = next
        }
        let favourable = (0..<ways.count).contains(target) ? ways[target] : 0
        return reduced(favourable, power(faces, dice))
    }

    public static func expectedHighest(dice: Int, faces: Int) -> Fraction {
        var weighted = 0
        for m in 1...faces {
            weighted += m * (power(m, dice) - power(m - 1, dice))   // m × (outcomes with highest exactly m)
        }
        return reduced(weighted, power(faces, dice))
    }
}
