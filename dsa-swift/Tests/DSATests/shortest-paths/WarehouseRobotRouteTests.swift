import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RobotRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct WarehouseRobotRouteTests {
    /// Relaxes every cell from its neighbours until nothing changes. Slow, but clearly right.
    private func reference(_ floor: [[Int]], _ start: [Int], _ goal: [Int]) -> Int {
        let rows = floor.count, cols = floor[0].count
        var cost = Array(repeating: Array(repeating: Int.max, count: cols), count: rows)
        cost[start[0]][start[1]] = 0
        var changed = true
        while changed {
            changed = false
            for row in 0..<rows {
                for col in 0..<cols where cost[row][col] != Int.max {
                    for (dr, dc) in [(0, 1), (1, 0), (0, -1), (-1, 0)] {
                        let r = row + dr, c = col + dc
                        guard r >= 0, r < rows, c >= 0, c < cols, floor[r][c] > 0 else { continue }
                        if cost[row][col] + floor[r][c] < cost[r][c] {
                            cost[r][c] = cost[row][col] + floor[r][c]
                            changed = true
                        }
                    }
                }
            }
        }
        return cost[goal[0]][goal[1]] == Int.max ? -1 : cost[goal[0]][goal[1]]
    }

    /// A random floor with roughly `shelfChance` percent shelves, and the start and goal kept open
    private func randomFloor(rows: Int, cols: Int, shelfChance: Int, costs: ClosedRange<Int>, start: [Int], goal: [Int],
                             using random: inout RobotRandom) -> [[Int]] {
        var floor = (0..<rows).map { _ in
            (0..<cols).map { _ in Int.random(in: 0..<100, using: &random) < shelfChance ? 0 : Int.random(in: costs, using: &random) }
        }
        if floor[start[0]][start[1]] == 0 { floor[start[0]][start[1]] = costs.lowerBound }
        if floor[goal[0]][goal[1]] == 0 { floor[goal[0]][goal[1]] = costs.lowerBound }
        return floor
    }

    @Test("Examples")
    func examples() {
        let floor = [
            [1, 1, 1, 1],
            [1, 0, 0, 1],
            [1, 9, 1, 1],
        ]
        #expect(WarehouseRobotRoute.cheapestRoute(floor, start: [0, 0], goal: [2, 2]) == 6)
        #expect(WarehouseRobotRoute.cheapestRoute(floor, start: [2, 2], goal: [0, 0]) == 6)
        #expect(WarehouseRobotRoute.cheapestRoute(floor, start: [2, 1], goal: [2, 0]) == 1)

        let costly = [
            [1, 6, 1],
            [1, 6, 1],
            [1, 1, 1],
        ]
        #expect(WarehouseRobotRoute.cheapestRoute(costly, start: [0, 0], goal: [0, 2]) == 6)
        #expect(WarehouseRobotRoute.cheapestRoute(costly, start: [1, 0], goal: [1, 1]) == 6)
    }

    @Test("Edge cases")
    func edgeCases() {
        // Already at the goal
        #expect(WarehouseRobotRoute.cheapestRoute([[3]], start: [0, 0], goal: [0, 0]) == 0)
        // Walled off by shelves
        #expect(WarehouseRobotRoute.cheapestRoute([[1, 0, 1]], start: [0, 0], goal: [0, 2]) == -1)
        // The start cell's own cost isn't paid, the goal's is
        #expect(WarehouseRobotRoute.cheapestRoute([[9, 4]], start: [0, 0], goal: [0, 1]) == 4)
        #expect(WarehouseRobotRoute.cheapestRoute([[9, 4]], start: [0, 1], goal: [0, 0]) == 9)
        // Expensive cells everywhere: a heuristic that assumes cost 1 per step is still admissible, just weak
        #expect(WarehouseRobotRoute.cheapestRoute(Array(repeating: Array(repeating: 7, count: 5), count: 5), start: [0, 0], goal: [4, 4]) == 56)
    }

    @Test("Matches the slow reference on 300 small random floors")
    func randomSmall() {
        var random = RobotRandom(seed: 8)
        for _ in 0..<300 {
            let rows = Int.random(in: 1...7, using: &random), cols = Int.random(in: 1...7, using: &random)
            let start = [Int.random(in: 0..<rows, using: &random), Int.random(in: 0..<cols, using: &random)]
            let goal = [Int.random(in: 0..<rows, using: &random), Int.random(in: 0..<cols, using: &random)]
            let low = Int.random(in: 1...9, using: &random)
            let floor = randomFloor(rows: rows, cols: cols, shelfChance: Int.random(in: 0...40, using: &random),
                                    costs: low...Int.random(in: low...9, using: &random), start: start, goal: goal, using: &random)
            #expect(WarehouseRobotRoute.cheapestRoute(floor, start: start, goal: goal) == reference(floor, start, goal))
        }
    }

    @Test("A random 80 × 80 floor matches the slow reference")
    func randomMedium() {
        var random = RobotRandom(seed: 80)
        let floor = randomFloor(rows: 80, cols: 80, shelfChance: 25, costs: 1...9, start: [0, 0], goal: [79, 79], using: &random)
        #expect(WarehouseRobotRoute.cheapestRoute(floor, start: [0, 0], goal: [79, 79]) == reference(floor, [0, 0], [79, 79]))
        #expect(WarehouseRobotRoute.cheapestRoute(floor, start: [79, 0], goal: [3, 70]) == reference(floor, [79, 0], [3, 70]))
    }

    @Test("400 × 400 floors with known answers")
    func large() {
        // An empty floor where every cell costs 2: the answer is 2 × the Manhattan distance
        let open = Array(repeating: Array(repeating: 2, count: 400), count: 400)
        #expect(WarehouseRobotRoute.cheapestRoute(open, start: [0, 0], goal: [399, 399]) == 2 * 798)
        #expect(WarehouseRobotRoute.cheapestRoute(open, start: [200, 13], goal: [7, 350]) == 2 * (193 + 337))

        // Rows of shelves with one gap each, alternating ends, so the only route zigzags across the
        // whole floor: every open cell costs 1, and the route visits 200 rows of 400 cells plus the gaps
        var maze = Array(repeating: Array(repeating: 1, count: 400), count: 400)
        for row in stride(from: 1, to: 400, by: 2) {
            for col in 0..<400 { maze[row][col] = 0 }
            maze[row][(row / 2) % 2 == 0 ? 399 : 0] = 1
        }
        #expect(WarehouseRobotRoute.cheapestRoute(maze, start: [0, 0], goal: [398, 0]) == 200 * 399 + 199 * 2)
        #expect(WarehouseRobotRoute.cheapestRoute(maze, start: [0, 0], goal: [399, 0]) == 200 * 399 + 199 * 2 + 1)
        // Close as the crow flies, but the shelves force the long way round
        #expect(WarehouseRobotRoute.cheapestRoute(maze, start: [0, 5], goal: [2, 5]) == 394 + 2 + 394)
    }
}
