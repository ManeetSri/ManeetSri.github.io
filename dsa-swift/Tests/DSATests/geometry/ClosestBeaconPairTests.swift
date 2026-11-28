import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same beacons
private struct BeaconRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct ClosestBeaconPairTests {
    /// Every pair. Small inputs only.
    private func bruteForce(_ beacons: [[Int]]) -> Int {
        var best = Int.max
        for i in beacons.indices {
            for j in beacons.indices where j > i {
                let dx = beacons[i][0] - beacons[j][0], dy = beacons[i][1] - beacons[j][1]
                best = min(best, dx * dx + dy * dy)
            }
        }
        return best
    }

    @Test("Examples", arguments: [
        ([[0, 0], [5, 5], [1, 2], [9, 0]], 5),
        ([[3, 4], [0, 0]], 25),
        ([[1, 1], [7, 3], [1, 1], [4, 4]], 0),
        ([[0, 0], [10, 0], [20, 0], [21, 0], [40, 0]], 1),
        ([[-5, 3], [-5, -3], [5, 3], [5, -3]], 36),
        ([[2, 2], [8, 9], [3, 7], [2, 6], [9, 1]], 2),
    ] as [([[Int]], Int)])
    func examples(beacons: [[Int]], expected: Int) {
        #expect(ClosestBeaconPair.smallestSquaredDistance(beacons) == expected)
    }

    @Test("The two farthest corners of the map: 8 × 10¹⁸ still fits in an Int")
    func extremes() {
        let big = 1_000_000_000
        #expect(ClosestBeaconPair.smallestSquaredDistance([[-big, -big], [big, big]]) == 8_000_000_000_000_000_000)
        #expect(ClosestBeaconPair.smallestSquaredDistance([[-big, big], [big, -big], [big, big]]) == 4_000_000_000_000_000_000)
    }

    @Test("Matches every pair on 500 small random maps, with plenty of shared spots")
    func randomSmall() {
        var random = BeaconRandom(seed: 65)
        for round in 0..<500 {
            let range = round < 250 ? 6 : 1_000
            let beacons = (0..<Int.random(in: 2...40, using: &random)).map { _ in
                [Int.random(in: -range...range, using: &random), Int.random(in: -range...range, using: &random)]
            }
            #expect(ClosestBeaconPair.smallestSquaredDistance(beacons) == bruteForce(beacons))
        }
    }

    @Test("Matches every pair on 1,000 random beacons across the whole map")
    func randomMedium() {
        var random = BeaconRandom(seed: 7)
        let big = 1_000_000_000
        for _ in 0..<5 {
            let beacons = (0..<1_000).map { _ in
                [Int.random(in: -big...big, using: &random), Int.random(in: -big...big, using: &random)]
            }
            #expect(ClosestBeaconPair.smallestSquaredDistance(beacons) == bruteForce(beacons))
        }
    }

    @Test("100,000 beacons in a jittered grid, with one planted close pair")
    func plantedPair() {
        // One beacon near the middle of each cell of a 1,000-wide grid: any two are at least 800 apart,
        // except the planted pair, which is 5 apart.
        var random = BeaconRandom(seed: 100_000)
        var beacons: [[Int]] = []
        for row in 0..<316 {
            for column in 0..<316 {
                beacons.append([column * 1_000 + Int.random(in: -100...100, using: &random),
                                row * 1_000 + Int.random(in: -100...100, using: &random)])
            }
        }
        let anchor = beacons[50_000]
        beacons.append([anchor[0] + 3, anchor[1] - 4])
        beacons.shuffle(using: &random)
        #expect(ClosestBeaconPair.smallestSquaredDistance(beacons) == 25)
    }

    @Test("100,000 beacons on one vertical line")
    func verticalLine() {
        // Every beacon shares one x, so "check the neighbours that are close in x" checks them all
        var random = BeaconRandom(seed: 3)
        var beacons = (0..<100_000).map { [7, $0 * 10] }
        beacons.append([7, 500_003])
        beacons.shuffle(using: &random)
        #expect(ClosestBeaconPair.smallestSquaredDistance(beacons) == 9)
    }

    @Test("100,000 beacons on one horizontal line")
    func horizontalLine() {
        var random = BeaconRandom(seed: 4)
        var beacons = (0..<100_000).map { [$0 * 10 - 500_000, -7] }
        beacons.append([123_454, -7])
        beacons.shuffle(using: &random)
        #expect(ClosestBeaconPair.smallestSquaredDistance(beacons) == 16)
    }
}
