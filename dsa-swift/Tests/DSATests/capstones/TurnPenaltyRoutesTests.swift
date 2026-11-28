import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run builds the same towns
private struct TurnRoutesRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TurnPenaltyRoutesTests {
    /// The statement's town: a 3 × 3 grid of junctions 100 m apart, numbered row by row from the
    /// south-west corner, and place 9, 50 m south of place 1, whose only road leads north into town
    private let town: [[Int]] = [[0, 0], [100, 0], [200, 0], [0, 100], [100, 100], [200, 100],
                                 [0, 200], [100, 200], [200, 200], [100, -50]]
    private let townRoads: [[Int]] = [[0, 1, 100], [1, 2, 100], [3, 4, 100], [4, 5, 100], [6, 7, 100], [7, 8, 100],
                                      [0, 3, 100], [3, 6, 100], [1, 4, 100], [4, 7, 100], [2, 5, 100], [5, 8, 100],
                                      [9, 1, 50]]

    private func cheapest(_ places: [[Int]], _ roads: [[Int]], _ start: Int, _ goal: Int, _ penalty: Int) -> Int? {
        TurnPenaltyRoutes.cheapest(places: places, roads: roads, from: start, to: goal, leftTurnPenalty: penalty)
    }

    /// Brute force: Bellman–Ford over "arrived by directed road i" states, relaxing every state
    /// until nothing changes
    private func reference(_ places: [[Int]], _ roads: [[Int]], _ start: Int, _ goal: Int, _ penalty: Int) -> Int? {
        if start == goal { return 0 }
        var from: [Int] = [], to: [Int] = [], length: [Int] = []
        for road in roads {
            from += [road[0], road[1]]
            to += [road[1], road[0]]
            length += [road[2], road[2]]
        }
        var out = Array(repeating: [Int](), count: places.count)
        for i in from.indices { out[from[i]].append(i) }
        var cost = Array(repeating: Int.max, count: from.count)
        for i in out[start] { cost[i] = length[i] }
        var changed = true
        while changed {
            changed = false
            for i in from.indices where cost[i] != Int.max && to[i] != goal {
                let (u, v) = (from[i], to[i])
                for j in out[v] where to[j] != u {
                    let w = to[j]
                    let a = (places[v][0] - places[u][0], places[v][1] - places[u][1])
                    let b = (places[w][0] - places[v][0], places[w][1] - places[v][1])
                    let total = cost[i] + length[j] + (a.0 * b.1 - a.1 * b.0 > 0 ? penalty : 0)
                    if total < cost[j] {
                        cost[j] = total
                        changed = true
                    }
                }
            }
        }
        return from.indices.filter { to[$0] == goal && cost[$0] != Int.max }.map { cost[$0] }.min()
    }

    @Test("The statement's town: from place 9 to place 0, the first junction is a left turn", arguments: [
        (0, 150), (30, 180), (399, 549), (400, 550), (500, 550), (10_000, 550),
    ])
    func townExample(penalty: Int, expected: Int) {
        #expect(cheapest(town, townRoads, 9, 0, penalty) == expected)
    }

    @Test("Other trips in the town", arguments: [
        (9, 2, 500, 150),       // right at place 1: no penalty
        (9, 7, 500, 250),       // straight on through place 4
        (0, 8, 500, 400),       // leave north, turn right once
        (8, 0, 500, 400),       // leave south, turn right once
        (9, 9, 500, 0),         // already there
        (4, 9, 500, 150),       // leave south through place 1
        (9, 3, 500, 650),       // 1, 4, right to 5, right to 2, right to 1, on to 0, right up to 3
    ])
    func otherTrips(start: Int, goal: Int, penalty: Int, expected: Int) {
        #expect(cheapest(town, townRoads, start, goal, penalty) == expected)
    }

    @Test("A U-turn isn't allowed, even where it would be cheaper")
    func noUTurns() {
        // With U-turns, 9 → 1 → 4 → 1 → 0 would cost 350 and avoid every left turn
        #expect(cheapest(town, townRoads, 9, 0, 500) == 550)
        // Place 10 sits at the end of a road leading west out of place 0
        let places = town + [[-100, 0]]
        let roads = townRoads + [[0, 10, 100]]
        #expect(cheapest(places, roads, 9, 10, 500) == 650)       // round the block, then on through 0
        #expect(cheapest(places, roads, 10, 9, 500) == 250)       // east through 0, then right at 1
    }

    @Test("Places with no road between them")
    func unreachable() {
        let places = town + [[500, 500]]
        #expect(cheapest(places, townRoads, 9, 10, 0) == nil)
        #expect(cheapest(places, townRoads, 10, 0, 0) == nil)
        #expect(cheapest([[0, 0], [5, 5]], [], 0, 1, 3) == nil)
        #expect(cheapest([[0, 0]], [], 0, 0, 3) == 0)
    }

    @Test("Left and right are judged by the direction of travel, with y pointing north")
    func directions() {
        // A junction J at (0, 0) with roads to the south, east, north and west
        let places = [[0, 0], [0, -10], [10, 0], [0, 10], [-10, 0]]
        let roads = [[0, 1, 10], [0, 2, 10], [0, 3, 10], [0, 4, 10]]
        #expect(cheapest(places, roads, 1, 4, 7) == 27)          // north, then west: left
        #expect(cheapest(places, roads, 1, 2, 7) == 20)          // north, then east: right
        #expect(cheapest(places, roads, 1, 3, 7) == 20)          // straight on
        #expect(cheapest(places, roads, 2, 1, 7) == 27)          // west, then south: left
        #expect(cheapest(places, roads, 4, 1, 7) == 20)          // east, then south: right
        // A diagonal road counts too: from the west heading east, a road to the north-east is a left
        let fork = [[0, 0], [-10, 0], [10, 3], [10, -3]]
        let forkRoads = [[0, 1, 10], [0, 2, 10], [0, 3, 10]]
        #expect(cheapest(fork, forkRoads, 1, 2, 5) == 25)
        #expect(cheapest(fork, forkRoads, 1, 3, 5) == 20)
    }

    @Test("Matches Bellman–Ford on random towns")
    func randomTowns() {
        var random = TurnRoutesRandom(seed: 74)
        var firstMismatch: String? = nil
        for _ in 0..<150 where firstMismatch == nil {
            // Distinct places on a small lattice
            let count = Int.random(in: 1...10, using: &random)
            var spots = Set<[Int]>()
            while spots.count < count {
                spots.insert([Int.random(in: 0...4, using: &random), Int.random(in: 0...4, using: &random)])
            }
            let places = Array(spots)
            // Random roads, never two leaving one place in the same direction
            var directions = Array(repeating: Set<[Int]>(), count: count)
            func direction(_ from: Int, _ to: Int) -> [Int] {
                let dx = places[to][0] - places[from][0], dy = places[to][1] - places[from][1]
                var (a, b) = (abs(dx), abs(dy))
                while b != 0 { (a, b) = (b, a % b) }
                return [dx / a, dy / a]
            }
            var roads: [[Int]] = []
            for a in 0..<count {
                for b in (a + 1)..<count where Int.random(in: 0..<3, using: &random) == 0 {
                    let forward = direction(a, b), backward = direction(b, a)
                    guard !directions[a].contains(forward), !directions[b].contains(backward) else { continue }
                    directions[a].insert(forward)
                    directions[b].insert(backward)
                    roads.append([a, b, Int.random(in: 1...20, using: &random)])
                }
            }
            let start = Int.random(in: 0..<count, using: &random)
            let goal = Int.random(in: 0..<count, using: &random)
            let penalty = Int.random(in: 0...30, using: &random)
            let got = cheapest(places, roads, start, goal, penalty)
            let expected = reference(places, roads, start, goal, penalty)
            if got != expected {
                firstMismatch = "places \(places), roads \(roads), \(start) to \(goal), penalty \(penalty): got \(String(describing: got)), expected \(String(describing: expected))"
            }
        }
        #expect(firstMismatch == nil)
    }

    @Test("A 30 × 30 grid town with random block lengths")
    func largeGrid() {
        var random = TurnRoutesRandom(seed: 2_024)
        let size = 30
        let places = (0..<(size * size)).map { [($0 % size) * 10, ($0 / size) * 10] }
        var roads: [[Int]] = []
        for index in 0..<(size * size) {
            if index % size + 1 < size { roads.append([index, index + 1, Int.random(in: 5...15, using: &random)]) }
            if index / size + 1 < size { roads.append([index, index + size, Int.random(in: 5...15, using: &random)]) }
        }
        for (start, goal) in [(0, size * size - 1), (size * size - 1, 0), (size - 1, size * (size - 1)), (465, 466)] {
            #expect(cheapest(places, roads, start, goal, 12) == reference(places, roads, start, goal, 12))
        }
    }
}
