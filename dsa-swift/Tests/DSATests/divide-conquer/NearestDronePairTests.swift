import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct DroneRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct NearestDronePairTests {
    private func squared(_ a: [Int], _ b: [Int]) -> Int {
        (a[0] - b[0]) * (a[0] - b[0]) + (a[1] - b[1]) * (a[1] - b[1])
    }

    /// Every pair. Slow, but clearly right.
    private func bruteForce(_ drones: [[Int]]) -> Int {
        var best = Int.max
        for i in drones.indices {
            for j in (i + 1)..<drones.count {
                best = min(best, squared(drones[i], drones[j]))
            }
        }
        return best
    }

    /// Sort by x and compare each drone with later ones until the x gap alone is too big. Quadratic in the
    /// worst case, but fast on points spread at random.
    private func sweep(_ drones: [[Int]]) -> Int {
        let sorted = drones.sorted { $0[0] < $1[0] }
        var best = Int.max
        for i in sorted.indices {
            var j = i + 1
            while j < sorted.count {
                let dx = sorted[j][0] - sorted[i][0]
                if dx * dx >= best { break }
                best = min(best, squared(sorted[i], sorted[j]))
                j += 1
            }
        }
        return best
    }

    @Test("Examples and small cases", arguments: [
        ([[0, 0], [7, 2], [3, 4], [10, 10]], 20),
        ([[1, 1], [4, 5]], 25),
        ([[2, -3], [2, -3], [9, 9]], 0),
        ([[-5, 0], [0, 0], [5, 0], [10, 0]], 25),
        ([[0, 0], [0, 6], [0, 13], [1, 3]], 10),
        ([[100, 100], [-100, -100], [100, -100], [-100, 100]], 40_000),
        ([[-1_000_000_000, -1_000_000_000], [1_000_000_000, 1_000_000_000]], 8_000_000_000_000_000_000),
        ([[1_000_000_000, -1_000_000_000], [-1_000_000_000, 1_000_000_000], [0, 0]], 2_000_000_000_000_000_000),
    ] as [([[Int]], Int)])
    func examples(drones: [[Int]], expected: Int) {
        #expect(NearestDronePair.smallestSquaredDistance(drones) == expected)
    }

    @Test("Matches the brute force on 400 small random sets, crowded with ties and duplicates")
    func randomSmall() {
        var random = DroneRandom(seed: 1_975)
        for _ in 0..<400 {
            let spread = Int.random(in: 1...40, using: &random)
            let drones = (0..<Int.random(in: 2...60, using: &random)).map { _ in
                [Int.random(in: -spread...spread, using: &random), Int.random(in: -spread...spread, using: &random)]
            }
            #expect(NearestDronePair.smallestSquaredDistance(drones) == bruteForce(drones))
        }
    }

    @Test("Matches the brute force on 800 drones spread over the whole range")
    func randomMedium() {
        var random = DroneRandom(seed: 86)
        for _ in 0..<2 {
            let drones = (0..<800).map { _ in
                [Int.random(in: -1_000_000_000...1_000_000_000, using: &random), Int.random(in: -1_000_000_000...1_000_000_000, using: &random)]
            }
            #expect(NearestDronePair.smallestSquaredDistance(drones) == bruteForce(drones))
        }
    }

    @Test("20,000 drones on a jittered grid with planted close pairs")
    func plantedGrid() {
        // One drone per 20,000-wide cell, jittered by less than 5,000, so drones in different cells are
        // more than 15,000 apart in some direction. Then plant pairs much closer than that.
        var random = DroneRandom(seed: 2_049)
        var drones: [[Int]] = []
        for column in 0..<80 {
            for row in 0..<250 {
                drones.append([column * 20_000 - 800_000 + Int.random(in: 0..<5_000, using: &random),
                               row * 20_000 - 2_500_000 + Int.random(in: 0..<5_000, using: &random)])
            }
        }
        var planted = drones
        planted.append([drones[13_337][0] + 3, drones[13_337][1] + 4])
        planted.shuffle(using: &random)
        #expect(NearestDronePair.smallestSquaredDistance(planted) == 25)

        planted.append([drones[77][0] - 1, drones[77][1] + 1])
        planted.shuffle(using: &random)
        #expect(NearestDronePair.smallestSquaredDistance(planted) == 2)
    }

    @Test("Large sets in a line, so every drone lands in the strip")
    func lines() {
        var random = DroneRandom(seed: 12)
        let vertical = (0..<15_000).map { [0, 7 * $0 - 200_000] }.shuffled(using: &random)
        #expect(NearestDronePair.smallestSquaredDistance(vertical) == 49)
        let horizontal = (0..<15_000).map { [5 * $0, -3] }.shuffled(using: &random)
        #expect(NearestDronePair.smallestSquaredDistance(horizontal) == 25)
        let twoColumns = (0..<15_000).map { [$0 % 2 == 0 ? -1 : 1, 10 * ($0 / 2)] }.shuffled(using: &random)
        #expect(NearestDronePair.smallestSquaredDistance(twoColumns) == 4)
    }

    @Test("Large random sets: spread out, and crowded with duplicates")
    func largeRandom() {
        var random = DroneRandom(seed: 3_141)
        let spread = (0..<20_000).map { _ in
            [Int.random(in: -1_000_000_000...1_000_000_000, using: &random), Int.random(in: -1_000_000_000...1_000_000_000, using: &random)]
        }
        #expect(NearestDronePair.smallestSquaredDistance(spread) == sweep(spread))
        // 30,000 drones in a 120 by 120 square: some position must be shared
        let crowded = (0..<30_000).map { _ in [Int.random(in: 0..<120, using: &random), Int.random(in: 0..<120, using: &random)] }
        #expect(NearestDronePair.smallestSquaredDistance(crowded) == 0)
    }
}
