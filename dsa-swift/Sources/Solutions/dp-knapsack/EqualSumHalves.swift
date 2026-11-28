// Reference solution: Split into two equal-sum halves. If the total is odd, or one number is bigger
// than half of it, there's no split. Otherwise it's subset sum with target total / 2: a Boolean row of
// reachable sums, updated right to left so each number is used once. The numbers left out of the half
// make the other half. O(n · total) time, O(total) space.

public enum EqualSumHalves {
    public static func canSplit(_ numbers: [Int]) -> Bool {
        let total = numbers.reduce(0, +)
        if total % 2 != 0 { return false }
        let half = total / 2
        if numbers.contains(where: { $0 > half }) { return false }
        var reachable = Array(repeating: false, count: half + 1)
        reachable[0] = true
        for x in numbers {
            for s in stride(from: half, through: x, by: -1) where reachable[s - x] {
                reachable[s] = true
            }
            if reachable[half] { return true }
        }
        return reachable[half]
    }
}
