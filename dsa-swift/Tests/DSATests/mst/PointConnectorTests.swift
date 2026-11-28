import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PointConnectorTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The answer by a different method: Kruskal's algorithm over every pair of points.
    private func modelCost(_ points: [[Int]]) -> Int {
        var edges: [(Int, Int, Int)] = []
        for i in points.indices {
            for j in points.indices where j > i {
                edges.append((abs(points[i][0] - points[j][0]) + abs(points[i][1] - points[j][1]), i, j))
            }
        }
        var parent = Array(points.indices)
        func root(_ x: Int) -> Int {
            var x = x
            while parent[x] != x { x = parent[x] }
            return x
        }
        var total = 0
        for (weight, a, b) in edges.sorted(by: { $0.0 < $1.0 }) where root(a) != root(b) {
            parent[root(a)] = root(b)
            total += weight
        }
        return total
    }

    @Test("Small sets of points", arguments: [
        ([[0, 0], [1, 1], [3, 0]], 5),
        ([[0, 0], [4, 0], [0, 3], [4, 3]], 10),
        ([[-2, 1], [1, 1], [1, -3], [6, 0]], 13),
        ([[0, 0], [10, 10]], 20),
        ([[5, 5], [5, 6], [5, 7], [5, 8]], 3),
    ])
    func examples(points: [[Int]], expected: Int) {
        #expect(PointConnector.minimumCost(points) == expected)
    }

    @Test("A single point costs nothing")
    func single() {
        #expect(PointConnector.minimumCost([[7, -3]]) == 0)
    }

    @Test("Random points match Kruskal's algorithm", arguments: Array(1...10))
    func random(seed: UInt64) {
        var steps = Steps(seed: seed)
        var used = Set<[Int]>()
        while used.count < 2 + steps.next(below: 50) {
            used.insert([steps.next(below: 41) - 20, steps.next(below: 41) - 20])
        }
        let points = used.sorted { $0[0] != $1[0] ? $0[0] < $1[0] : $0[1] < $1[1] }
        #expect(PointConnector.minimumCost(points) == modelCost(points))
    }

    @Test("Large coordinates don't overflow")
    func largeCoordinates() {
        let far = 1_000_000_000
        #expect(PointConnector.minimumCost([[-far, -far], [far, far], [far, -far]]) == 4 * far)
    }

    @Test("A shuffled 40 × 40 grid of points")
    func grid() {
        var points: [[Int]] = []
        for x in 0..<40 {
            for y in 0..<40 {
                points.append([x * 3, y * 3])
            }
        }
        var steps = Steps(seed: 21)
        for index in stride(from: points.count - 1, to: 0, by: -1) {
            points.swapAt(index, steps.next(below: index + 1))
        }
        #expect(PointConnector.minimumCost(points) == 3 * (40 * 40 - 1))
    }

    @Test("2,000 points on a line, shuffled")
    func line() {
        var points = (0..<2_000).map { [$0 * 7 - 5_000, 12] }
        var steps = Steps(seed: 4)
        for index in stride(from: points.count - 1, to: 0, by: -1) {
            points.swapAt(index, steps.next(below: index + 1))
        }
        #expect(PointConnector.minimumCost(points) == 7 * 1_999)
    }
}
