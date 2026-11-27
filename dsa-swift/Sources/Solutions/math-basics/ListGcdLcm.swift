// Reference solution: GCD and LCM of a list. Fold Euclid's gcd over the list starting from 0
// (gcd(0, x) = x), and fold lcm(a, b) = a / gcd(a, b) * b starting from 1, dividing first and
// checking the multiplication for overflow. O(n log M) time for values up to M, O(1) space.

public enum ListGcdLcm {
    public static func gcd(of numbers: [Int]) -> Int {
        numbers.reduce(0, gcd)
    }

    public static func lcm(of numbers: [Int]) -> Int? {
        var result = 1
        for number in numbers {
            let step = (result / gcd(result, number)).multipliedReportingOverflow(by: number)
            if step.overflow {
                return nil
            }
            result = step.partialValue
        }
        return result
    }

    private static func gcd(_ first: Int, _ second: Int) -> Int {
        var a = first
        var b = second
        while b != 0 {
            (a, b) = (b, a % b)
        }
        return a
    }
}
