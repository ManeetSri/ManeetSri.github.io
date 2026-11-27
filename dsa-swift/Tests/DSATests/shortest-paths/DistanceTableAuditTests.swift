import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct DistanceAuditRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct DistanceTableAuditTests {
    /// The true table, by relaxing every road both ways until a whole pass changes nothing
    private func truth(_ places: Int, _ roads: [[Int]], _ start: Int) -> [Int?] {
        var distance: [Int?] = Array(repeating: nil, count: places)
        distance[start] = 0
        var changed = true
        while changed {
            changed = false
            for road in roads {
                for (from, to) in [(road[0], road[1]), (road[1], road[0])] {
                    if let here = distance[from], here + road[2] < (distance[to] ?? Int.max) {
                        distance[to] = here + road[2]
                        changed = true
                    }
                }
            }
        }
        return distance
    }

    private static let town = [[0, 3, 10], [0, 1, 2], [1, 2, 3], [2, 3, 2]]

    @Test("The town from the lesson", arguments: [
        ([0, 2, 5, 7], true),
        ([0, 2, 5, 10], false),        // the road from the shop gives school 7
        ([0, 2, 5, 6], false),         // no route to school takes 6 minutes
        ([0, 2, 5, nil], false),       // school can be reached
        ([1, 3, 6, 8], false),         // the start must be 0
        ([0, 2, 4, 6], false),
        ([0, 1, 5, 7], false),
    ] as [([Int?], Bool)])
    func town(claimed: [Int?], expected: Bool) {
        #expect(DistanceTableAudit.isExact(places: 4, roads: Self.town, start: 0, claimed: claimed) == expected)
    }

    @Test("Small cases", arguments: [
        (3, [[0, 1, 5], [1, 2, 0]], 0, [0, 5, 5], true),
        (3, [[0, 1, 5], [1, 2, 0]], 0, [0, 3, 3], false),           // a 0-minute road can't vouch both ways
        (3, [[0, 1, 4]], 0, [0, 4, nil], true),
        (3, [[0, 1, 4]], 0, [0, 4, 9], false),                      // place 2 can't be reached
        (3, [[0, 1, 4]], 2, [nil, nil, 0], true),
        (1, [], 0, [0], true),
        (1, [], 0, [nil], false),
        (2, [[0, 1, 9], [0, 1, 4], [1, 1, 3]], 0, [0, 4], true),    // parallel roads and a loop
        (2, [[0, 1, 9], [0, 1, 4], [1, 1, 3]], 0, [0, 9], false),
        (2, [[0, 1, 3]], 0, [0, -1], false),
        (2, [[0, 1, 3]], 1, [3, 0], true),                          // roads go both ways
        (2, [[0, 1, 0]], 1, [0, 0], true),
        (4, [[0, 1, 1], [2, 3, 0]], 0, [0, 1, 5, 5], false),        // 2 and 3 only vouch for each other
        (4, [[0, 1, 1], [2, 3, 0]], 0, [0, 1, nil, nil], true),
        (5, [[0, 1, 2], [1, 2, 2], [0, 2, 4], [2, 3, 1], [3, 4, 0]], 0, [0, 2, 4, 5, 5], true),
        (5, [[0, 1, 2], [1, 2, 2], [0, 2, 4], [2, 3, 1], [3, 4, 0]], 0, [0, 2, 4, 5, 4], false),
    ] as [(Int, [[Int]], Int, [Int?], Bool)])
    func small(places: Int, roads: [[Int]], start: Int, claimed: [Int?], expected: Bool) {
        #expect(DistanceTableAudit.isExact(places: places, roads: roads, start: start, claimed: claimed) == expected)
    }

    @Test("Random maps: the true table passes, and altered tables match a direct comparison")
    func randomSmall() {
        var random = DistanceAuditRandom(seed: 4_404)
        for round in 0..<400 {
            let places = Int.random(in: 1...7, using: &random)
            let maxMinutes = round % 2 == 0 ? 2 : 9                      // half the maps have many 0s
            let roads = (0..<Int.random(in: 0...12, using: &random)).map { _ in
                [Int.random(in: 0..<places, using: &random), Int.random(in: 0..<places, using: &random), Int.random(in: 0...maxMinutes, using: &random)]
            }
            let start = Int.random(in: 0..<places, using: &random)
            let exact = truth(places, roads, start)
            #expect(DistanceTableAudit.isExact(places: places, roads: roads, start: start, claimed: exact))

            for _ in 0..<4 {
                var claimed = exact
                for _ in 0..<Int.random(in: 1...2, using: &random) {
                    let place = Int.random(in: 0..<places, using: &random)
                    switch Int.random(in: 0..<3, using: &random) {
                    case 0: claimed[place] = nil
                    case 1: claimed[place] = Int.random(in: 0...20, using: &random)
                    default: claimed[place] = claimed[place].map { $0 + [-2, -1, 1, 2][Int.random(in: 0..<4, using: &random)] }
                    }
                }
                let expected = claimed == exact
                #expect(DistanceTableAudit.isExact(places: places, roads: roads, start: start, claimed: claimed) == expected)
            }
        }
    }

    @Test("A pocket joined by 0-minute roads, claimed too low as a group")
    func pocket() {
        // 0 – 1 – 2 in a line, then places 3...9 chained by 0-minute roads, hanging off place 2
        var roads = [[0, 1, 4], [1, 2, 6], [2, 3, 7]]
        roads += (3..<9).map { [$0, $0 + 1, 0] }
        let exact: [Int?] = [0, 4, 10] + Array(repeating: 17, count: 7)
        #expect(DistanceTableAudit.isExact(places: 10, roads: roads, start: 0, claimed: exact))
        let tooLow: [Int?] = [0, 4, 10] + Array(repeating: 16, count: 7)
        #expect(!DistanceTableAudit.isExact(places: 10, roads: roads, start: 0, claimed: tooLow))
        let oneTooLow: [Int?] = [0, 4, 10] + Array(repeating: 17, count: 6) + [16]
        #expect(!DistanceTableAudit.isExact(places: 10, roads: roads, start: 0, claimed: oneTooLow))
    }

    @Test("100,000 places and 200,000 roads with a planted table")
    func large() {
        // Give every place a target distance, join each to an earlier place by a road of exactly the
        // difference, and make every other road too slow to help. The true table is then the targets.
        var random = DistanceAuditRandom(seed: 99)
        let places = 100_000
        var target = (0..<places).map { _ in Int.random(in: 1...1_000_000_000, using: &random) }
        target[0] = 0
        let order = (0..<places).sorted { (target[$0], $0) < (target[$1], $1) }
        var roads: [[Int]] = []
        for position in 1..<places {
            let place = order[position]
            let earlier = order[Int.random(in: 0..<position, using: &random)]
            roads.append([earlier, place, target[place] - target[earlier]])
        }
        while roads.count < 199_000 {
            let a = Int.random(in: 0..<places, using: &random), b = Int.random(in: 0..<places, using: &random)
            roads.append([a, b, abs(target[a] - target[b]) + Int.random(in: 0...50, using: &random)])
        }
        // A pocket of 1,000 extra places chained by 0-minute roads, hanging off place 12,345
        let pocket = places..<(places + 1_000)
        roads.append([12_345, pocket.lowerBound, 7])
        roads += pocket.dropLast().map { [$0, $0 + 1, 0] }
        roads.shuffle(using: &random)

        let total = places + pocket.count
        let exact: [Int?] = target + Array(repeating: target[12_345] + 7, count: pocket.count)
        #expect(DistanceTableAudit.isExact(places: total, roads: roads, start: 0, claimed: exact))

        var changed = exact
        changed[54_321]! += 1
        #expect(!DistanceTableAudit.isExact(places: total, roads: roads, start: 0, claimed: changed))
        changed = exact
        changed[54_321]! -= 1
        #expect(!DistanceTableAudit.isExact(places: total, roads: roads, start: 0, claimed: changed))
        changed = exact
        changed[order.last!] = nil
        #expect(!DistanceTableAudit.isExact(places: total, roads: roads, start: 0, claimed: changed))
        changed = exact
        for place in pocket {
            changed[place]! -= 1
        }
        #expect(!DistanceTableAudit.isExact(places: total, roads: roads, start: 0, claimed: changed))

        // An extra place with no roads must be nil
        #expect(DistanceTableAudit.isExact(places: total + 1, roads: roads, start: 0, claimed: exact + [nil]))
        #expect(!DistanceTableAudit.isExact(places: total + 1, roads: roads, start: 0, claimed: exact + [5]))
    }
}
