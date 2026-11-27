// Reference solution: Plus or minus to hit the target. If P is the sum of the numbers given a plus sign
// and M the rest, P - M = target and P + M = total, so P = (total + target) / 2. Each sign pattern is
// a subset with sum P, so count those with the subset-counting DP (right to left, reaching s = 0 so
// that zeros double the count), modulo 1,000,000,007. O(n · total) time, O(total) space.

public enum PlusMinusTarget {
    public static func ways(_ numbers: [Int], target: Int) -> Int {
        let mod = 1_000_000_007
        let total = numbers.reduce(0, +)
        if abs(target) > total || (total + target) % 2 != 0 { return 0 }
        let plusSum = (total + target) / 2
        var ways = Array(repeating: 0, count: plusSum + 1)
        ways[0] = 1
        for x in numbers {
            for s in stride(from: plusSum, through: x, by: -1) {
                ways[s] = (ways[s] + ways[s - x]) % mod
            }
        }
        return ways[plusSum]
    }
}
