// Reference solution: Smash stones to the smallest remainder. Every smash subtracts one weight from
// another, so the last stone is the difference between two piles, and the smallest pile difference can
// always be reached. With total S, find the largest subset sum P ≤ S / 2 (0/1 subset sum, right to
// left); the answer is S - 2P. O(n · S) time, O(S) space.

public enum StoneSmashLeftover {
    public static func smallestRemainder(_ stones: [Int]) -> Int {
        let total = stones.reduce(0, +)
        let half = total / 2
        var reachable = Array(repeating: false, count: half + 1)
        reachable[0] = true
        for stone in stones where stone <= half {
            for s in stride(from: half, through: stone, by: -1) where reachable[s - stone] {
                reachable[s] = true
            }
        }
        var lighter = half
        while !reachable[lighter] {
            lighter -= 1
        }
        return total - 2 * lighter
    }
}
