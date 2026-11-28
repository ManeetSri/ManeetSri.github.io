import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same routes
private struct TurnsRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct WaypointTurnsTests {
    /// Decides each turn by comparing the two products of the cross product at full width (128 bits),
    /// so it can't overflow, and uses the dot product's sign for parallel directions.
    private func reference(_ waypoints: [[Int]]) -> String {
        guard waypoints.count >= 3 else { return "" }
        var result = ""
        for i in 1..<(waypoints.count - 1) {
            let ax = waypoints[i][0] - waypoints[i - 1][0], ay = waypoints[i][1] - waypoints[i - 1][1]
            let bx = waypoints[i + 1][0] - waypoints[i][0], by = waypoints[i + 1][1] - waypoints[i][1]
            let left = ax.multipliedFullWidth(by: by)
            let right = ay.multipliedFullWidth(by: bx)
            if (left.high, left.low) > (right.high, right.low) {
                result += "L"
            } else if (left.high, left.low) < (right.high, right.low) {
                result += "R"
            } else {
                // Parallel: same direction if the x steps (or, for vertical moves, the y steps) agree in sign
                let same = ax != 0 ? (ax > 0) == (bx > 0) : (ay > 0) == (by > 0)
                result += same ? "S" : "U"
            }
        }
        return result
    }

    @Test("Examples", arguments: [
        ([[0, 0], [4, 0], [4, 3], [1, 3]], "LL"),
        ([[0, 0], [2, 2], [4, 0], [6, 2]], "RL"),
        ([[1, 1], [2, 2], [5, 5]], "S"),
        ([[0, 0], [3, 0], [1, 0], [1, 4]], "UR"),
        ([[0, 0], [0, 5], [-2, 7]], "L"),
        ([[3, 3], [3, -1], [3, 2]], "U"),
        ([[-2, 0], [0, 0], [1, -5]], "R"),
    ] as [([[Int]], String)])
    func examples(waypoints: [[Int]], expected: String) {
        #expect(WaypointTurns.turns(waypoints) == expected)
    }

    @Test("Fewer than three waypoints have no turns")
    func short() {
        #expect(WaypointTurns.turns([]) == "")
        #expect(WaypointTurns.turns([[5, 5]]) == "")
        #expect(WaypointTurns.turns([[0, 0], [9, -9]]) == "")
    }

    @Test("Coordinates up to a billion")
    func largeCoordinates() {
        let big = 1_000_000_000
        #expect(WaypointTurns.turns([[-big, -big], [big, big], [-big, big]]) == "L")
        #expect(WaypointTurns.turns([[-big, -big], [big, big], [big, -big]]) == "R")
        #expect(WaypointTurns.turns([[-big, -big], [big, big], [-big, -big]]) == "U")
        // Nearly parallel: the second leg drifts one unit in a span of two billion
        #expect(WaypointTurns.turns([[-big, -big], [0, 0], [big, big - 1]]) == "R")
        #expect(WaypointTurns.turns([[-big, -big], [0, 0], [big - 1, big]]) == "L")
        #expect(WaypointTurns.turns([[-big, big], [big, big], [big, -big], [-big, -big], [-big, big - 1]]) == "RRR")
    }

    @Test("Matches the reference on 500 small random routes")
    func randomSmall() {
        var random = TurnsRandom(seed: 65)
        for _ in 0..<500 {
            var route = [[Int.random(in: -3...3, using: &random), Int.random(in: -3...3, using: &random)]]
            for _ in 0..<Int.random(in: 0...12, using: &random) {
                var next: [Int]
                repeat {
                    next = [Int.random(in: -3...3, using: &random), Int.random(in: -3...3, using: &random)]
                } while next == route.last!
                route.append(next)
            }
            #expect(WaypointTurns.turns(route) == reference(route))
        }
    }

    @Test("Matches the reference on random routes with huge coordinates")
    func randomHuge() {
        var random = TurnsRandom(seed: 9)
        let big = 1_000_000_000
        for _ in 0..<200 {
            let route = (0..<10).map { _ in
                [Int.random(in: -big...big, using: &random), Int.random(in: -big...big, using: &random)]
            }
            #expect(WaypointTurns.turns(route) == reference(route))
        }
    }

    @Test("A spiral of 100,000 waypoints")
    func spiral() {
        // Walk east, north, west, south with legs of growing length, one unit per waypoint.
        // Inside a leg the route goes straight on; at the end of each leg it turns left.
        let steps = [(1, 0), (0, 1), (-1, 0), (0, -1)]
        var route = [[0, 0]]
        var expected = ""
        var leg = 1
        var direction = 0
        while route.count < 100_000 {
            for step in 0..<leg where route.count < 100_000 {
                let last = route.last!
                route.append([last[0] + steps[direction].0, last[1] + steps[direction].1])
                if route.count > 2 {
                    expected += step == 0 ? "L" : "S"
                }
            }
            direction = (direction + 1) % 4
            if direction % 2 == 0 {
                leg += 1
            }
        }
        #expect(WaypointTurns.turns(route) == expected)
    }
}
