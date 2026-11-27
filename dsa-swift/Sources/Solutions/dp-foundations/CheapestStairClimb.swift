// Reference solution: Cheapest climb. Number the positions: the ground is 0, stair i is position
// i + 1, and the landing is position n + 1, with a toll of 0. cost[p] is the least paid to stand on
// position p, so cost[p] = toll(p) + the smallest cost among the maxStep positions below it.
// O(n · maxStep) time, O(n) space. (A monotonic deque of the window's minimum would make it O(n).)

public enum CheapestStairClimb {
    public static func minimumToll(tolls: [Int], maxStep: Int) -> Int {
        let landing = tolls.count + 1
        var cost = Array(repeating: 0, count: landing + 1)
        for position in stride(from: 1, through: landing, by: 1) {
            var cheapestBefore = Int.max
            for step in 1...maxStep where step <= position {
                cheapestBefore = min(cheapestBefore, cost[position - step])
            }
            let toll = position == landing ? 0 : tolls[position - 1]
            cost[position] = cheapestBefore + toll
        }
        return cost[landing]
    }
}
