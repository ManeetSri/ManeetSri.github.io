import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same orchards
private struct FenceRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct FenceCornerPostsTests {
    /// Brute force from the definition: a tree is a corner unless it lies on a segment between two other
    /// trees or inside a triangle of three others (every point inside the hull does, by Carathéodory's
    /// theorem). Then the corners are sorted counterclockwise around the first one. Tiny inputs only.
    private func reference(_ trees: [[Int]]) -> [[Int]] {
        let unique = Array(Set(trees))
        func cross(_ o: [Int], _ a: [Int], _ b: [Int]) -> Int {
            (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
        }
        func onSegment(_ p: [Int], _ a: [Int], _ b: [Int]) -> Bool {
            cross(a, b, p) == 0 && (a[0] - p[0]) * (b[0] - p[0]) + (a[1] - p[1]) * (b[1] - p[1]) <= 0
        }
        func inTriangle(_ p: [Int], _ a: [Int], _ b: [Int], _ c: [Int]) -> Bool {
            let area = cross(a, b, c)
            guard area != 0 else { return false }       // flat triangles are covered by onSegment
            let signs = [cross(a, b, p), cross(b, c, p), cross(c, a, p)]
            return area > 0 ? signs.allSatisfy { $0 >= 0 } : signs.allSatisfy { $0 <= 0 }
        }
        let corners = unique.filter { p in
            let others = unique.filter { $0 != p }
            for i in others.indices {
                for j in others.indices where j > i {
                    if onSegment(p, others[i], others[j]) { return false }
                    for k in others.indices where k > j {
                        if inTriangle(p, others[i], others[j], others[k]) { return false }
                    }
                }
            }
            return true
        }
        guard let start = corners.min(by: { $0.lexicographicallyPrecedes($1) }) else { return [] }
        let rest = corners.filter { $0 != start }.sorted { cross(start, $0, $1) > 0 }
        return [start] + rest
    }

    @Test("Examples", arguments: [
        ([[0, 0], [4, 0], [4, 4], [0, 4], [2, 2], [1, 3]], [[0, 0], [4, 0], [4, 4], [0, 4]]),
        ([[1, 1], [2, 2], [2, 0], [2, 4], [3, 3], [4, 2]], [[1, 1], [2, 0], [4, 2], [2, 4]]),
        ([[0, 0], [2, 0], [4, 0], [4, 2], [4, 4], [2, 4], [0, 4], [0, 2]], [[0, 0], [4, 0], [4, 4], [0, 4]]),
        ([[3, 1], [0, 5], [-2, 2]], [[-2, 2], [3, 1], [0, 5]]),
        ([[1, 1], [3, 3], [2, 2], [5, 5]], [[1, 1], [5, 5]]),
        ([[0, 7], [0, -1], [0, 3]], [[0, -1], [0, 7]]),
        ([[4, 4], [4, 4], [4, 4]], [[4, 4]]),
        ([[2, 9]], [[2, 9]]),
        ([[5, 0], [1, 2]], [[1, 2], [5, 0]]),
        ([], []),
    ] as [([[Int]], [[Int]])])
    func examples(trees: [[Int]], expected: [[Int]]) {
        #expect(FenceCornerPosts.corners(trees) == expected)
    }

    @Test("Several leftmost trees: the lowest one starts the fence")
    func startCorner() {
        #expect(FenceCornerPosts.corners([[0, 3], [0, 1], [2, 0], [3, 2], [0, 2]]) == [[0, 1], [2, 0], [3, 2], [0, 3]])
    }

    @Test("Matches the brute force on 600 small random orchards, full of duplicates and collinear trees")
    func randomSmall() {
        var random = FenceRandom(seed: 65)
        for _ in 0..<600 {
            let range = Int.random(in: 1...5, using: &random)
            let trees = (0..<Int.random(in: 1...12, using: &random)).map { _ in
                [Int.random(in: -range...range, using: &random), Int.random(in: -range...range, using: &random)]
            }
            #expect(FenceCornerPosts.corners(trees) == reference(trees))
        }
    }

    @Test("Every point of a parabola is a corner: 60,001 corners among 165,000 trees")
    func parabola() {
        // Gift wrapping is O(n × corners) here, far too slow. The trees between the parabola and the top
        // edge are inside, and trees on the top edge lie between its two end corners.
        var random = FenceRandom(seed: 30_000)
        let top = 30_000 * 30_000
        let curve = (-30_000...30_000).map { [$0, $0 * $0] }
        var trees = curve
        for _ in 0..<100_000 {
            let x = Int.random(in: -29_999...29_999, using: &random)
            trees.append([x, Int.random(in: (x * x + 1)...(top - 1), using: &random)])
        }
        for _ in 0..<4_000 {
            trees.append([Int.random(in: -29_999...29_999, using: &random), top])
        }
        for _ in 0..<1_000 {
            trees.append(curve[Int.random(in: 0..<curve.count, using: &random)])
        }
        trees.shuffle(using: &random)
        #expect(FenceCornerPosts.corners(trees) == curve)
    }

    @Test("200,000 trees in a square two billion wide")
    func bigSquare() {
        var random = FenceRandom(seed: 1)
        let big = 1_000_000_000
        var trees = [[big, big], [-big, big], [big, -big], [-big, -big]]
        for _ in 0..<150_000 {
            trees.append([Int.random(in: -big...big, using: &random), Int.random(in: -big...big, using: &random)])
        }
        for _ in 0..<50_000 {            // on the edges
            let t = Int.random(in: -big...big, using: &random)
            trees.append([[t, big], [t, -big], [big, t], [-big, t]][Int.random(in: 0..<4, using: &random)])
        }
        trees.shuffle(using: &random)
        #expect(FenceCornerPosts.corners(trees) == [[-big, -big], [big, -big], [big, big], [-big, big]])
    }
}
