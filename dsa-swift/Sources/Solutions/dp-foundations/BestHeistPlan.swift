// Reference solution: Plan the best heist. Fill best[i] = the most from the first i houses, then walk
// back from best[n]: if best[i] equals best[i - 1], house i - 1 can be skipped; otherwise it was robbed,
// so record it and jump to i - 2. Reverse the recorded houses. O(n) time, O(n) space.

public enum BestHeistPlan {
    public static func bestPlan(houses: [Int]) -> [Int] {
        let n = houses.count
        var best = Array(repeating: 0, count: n + 1)
        for i in stride(from: 1, through: n, by: 1) {
            best[i] = max(best[i - 1], (i >= 2 ? best[i - 2] : 0) + houses[i - 1])
        }
        var robbed: [Int] = []
        var i = n
        while i >= 1 {
            if best[i] == best[i - 1] {
                i -= 1
            } else {
                robbed.append(i - 1)
                i -= 2
            }
        }
        return robbed.reversed()
    }
}
