// Reference solution: Multiples below a limit. One loop with an accumulator, O(limit) time, O(1) space.
// (An O(1) version using arithmetic series and inclusion–exclusion is described in the statement.)

public enum MultiplesBelow {
    public static func sum(below limit: Int, divisibleBy a: Int, or b: Int) -> Int {
        var total = 0
        for n in stride(from: 1, to: limit, by: 1) where n % a == 0 || n % b == 0 {
            total += n
        }
        return total
    }
}
