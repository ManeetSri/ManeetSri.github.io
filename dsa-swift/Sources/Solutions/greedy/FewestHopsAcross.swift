// Reference solution: Fewest hops across the river. The stones reachable in exactly k hops form a
// contiguous range (a BFS level), and the next range runs from just after it to the farthest any stone
// in it can reach. So walk the stones once, tracking the end of the current range and the farthest
// reach seen; each time the walk reaches the end of a range, one more hop is needed. If a range ends
// without anything in it reaching further, the far bank is out of reach. O(n) time, O(1) space.

public enum FewestHopsAcross {
    public static func fewestHops(_ steps: [Int]) -> Int {
        var hops = 0
        var rangeEnd = 0                 // the last stone reachable with `hops` hops
        var farthest = 0                 // the farthest any stone seen so far can reach
        for i in 0..<(steps.count - 1) {
            farthest = max(farthest, i + steps[i])
            if i == rangeEnd {
                if farthest <= i { return -1 }      // nothing in this range gets past it
                hops += 1
                rangeEnd = farthest
            }
        }
        return hops
    }
}
