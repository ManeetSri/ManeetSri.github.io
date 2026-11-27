// Reference solution: Ways up the staircase. ways[i] is the number of ways to stand on stair i, with
// ways[0] = 1 for the ground. The last move onto stair i was one of the step sizes, so ways[i] adds up
// ways[i - step] for every step that fits, and a broken stair simply keeps ways = 0. Reduce modulo
// 1,000,000,007 after every addition. O(stairs · steps.count) time, O(stairs) space.

public enum StairClimbWays {
    public static func count(stairs: Int, steps: [Int], broken: [Int]) -> Int {
        let modulus = 1_000_000_007
        var isBroken = Array(repeating: false, count: stairs + 1)
        for stair in broken {
            isBroken[stair] = true
        }
        var ways = Array(repeating: 0, count: stairs + 1)
        ways[0] = 1
        for i in stride(from: 1, through: stairs, by: 1) where !isBroken[i] {
            for step in steps where step <= i {
                ways[i] = (ways[i] + ways[i - step]) % modulus
            }
        }
        return ways[stairs]
    }
}
