import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private struct TourRandom {
    var state: UInt64
    mutating func next(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int((state >> 33) % UInt64(bound))
    }
}

@Suite struct GrandTourPlannerTests {
    /// Tries every order of cities 1..<n: (n - 1)! tours, so only for small n.
    private func bruteForce(_ distance: [[Int]]) -> Int {
        let n = distance.count
        if n <= 1 { return 0 }
        var best = Int.max
        var order: [Int] = []
        var used = [Bool](repeating: false, count: n)
        func extend(_ length: Int) {
            if order.count == n - 1 {
                best = min(best, length + distance[order.last!][0])
                return
            }
            for city in 1..<n where !used[city] {
                used[city] = true
                let from = order.last ?? 0
                order.append(city)
                extend(length + distance[from][city])
                order.removeLast()
                used[city] = false
            }
        }
        extend(0)
        return best
    }

    @Test("Small maps", arguments: [
        ([[0, 3, 8, 5], [3, 0, 4, 9], [8, 4, 0, 2], [5, 9, 2, 0]], 14),
        ([[0, 1, 10], [10, 0, 1], [1, 10, 0]], 3),
        ([[0, 5], [7, 0]], 12),
        ([[0]], 0),
        ([[0, 0, 0], [0, 0, 0], [0, 0, 0]], 0),
    ] as [([[Int]], Int)])
    func smallMaps(distance: [[Int]], expected: Int) {
        #expect(GrandTourPlanner.shortestTour(distance) == expected)
    }

    @Test("Matches brute force on 200 random maps of up to 8 cities")
    func randomSmall() {
        var random = TourRandom(state: 16)
        for _ in 0..<200 {
            let n = 1 + random.next(8)
            var distance = [[Int]](repeating: [Int](repeating: 0, count: n), count: n)
            for i in 0..<n {
                for j in 0..<n where i != j { distance[i][j] = 1 + random.next(100) }
            }
            #expect(GrandTourPlanner.shortestTour(distance) == bruteForce(distance))
        }
    }

    @Test("12 cities on a line, in shuffled order")
    func citiesOnALine() {
        var random = TourRandom(state: 3)
        for _ in 0..<3 {
            let positions = (0..<12).map { _ in random.next(1_000) }
            let distance = positions.map { a in positions.map { b in abs(a - b) } }
            // Out to the far end and back covers the line twice, and no tour can do better
            #expect(GrandTourPlanner.shortestTour(distance) == 2 * (positions.max()! - positions.min()!))
        }
    }

    @Test("12 cities with a hidden one-way loop of 1s")
    func hiddenLoop() {
        var random = TourRandom(state: 12)
        for _ in 0..<3 {
            let n = 12
            // Every road costs 2 to 50, except the roads around one hidden loop, which cost 1
            var distance = [[Int]](repeating: [Int](repeating: 0, count: n), count: n)
            for i in 0..<n {
                for j in 0..<n where i != j { distance[i][j] = 2 + random.next(49) }
            }
            var loop = Array(0..<n)
            for i in stride(from: n - 1, to: 0, by: -1) { loop.swapAt(i, random.next(i + 1)) }
            for i in 0..<n { distance[loop[i]][loop[(i + 1) % n]] = 1 }
            #expect(GrandTourPlanner.shortestTour(distance) == n)
        }
    }
}
