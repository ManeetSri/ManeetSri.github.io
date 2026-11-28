// Reference solution: Connect every point. Every pair of points could be joined, so the graph is
// complete: n(n - 1) / 2 edges. Prim's algorithm with an array instead of a heap never builds them:
// cheapest[v] holds the cheapest known wire from the tree to point v. Each round adds the outside
// point with the smallest cheapest[v], then updates every other outside point with its distance to
// the new one. n rounds of O(n) work: O(n²) time and O(n) space, the best possible on a dense graph.

public enum PointConnector {
    public static func minimumCost(_ points: [[Int]]) -> Int {
        let n = points.count
        guard n > 1 else { return 0 }
        var inTree = Array(repeating: false, count: n)
        var cheapest = Array(repeating: Int.max, count: n)
        cheapest[0] = 0
        var total = 0
        for _ in 0..<n {
            var next = -1
            for v in 0..<n where !inTree[v] && (next == -1 || cheapest[v] < cheapest[next]) {
                next = v
            }
            inTree[next] = true
            total += cheapest[next]
            for v in 0..<n where !inTree[v] {
                let distance = abs(points[v][0] - points[next][0]) + abs(points[v][1] - points[next][1])
                if distance < cheapest[v] {
                    cheapest[v] = distance
                }
            }
        }
        return total
    }
}
