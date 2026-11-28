// Reference solution: Biscuits for children. Sort both lists and walk the biscuits from smallest to
// largest, giving each one to the least greedy child still waiting if it's big enough; a biscuit too
// small for that child is too small for everyone left. An exchange argument shows the least greedy
// child can always take the smallest biscuit that satisfies them.
// O(n log n + m log m) time, O(n + m) space for the sorted copies.

public enum BiscuitsForChildren {
    public static func happyChildren(greed: [Int], biscuits: [Int]) -> Int {
        let children = greed.sorted()
        var child = 0
        for size in biscuits.sorted() where child < children.count && size >= children[child] {
            child += 1
        }
        return child
    }
}
