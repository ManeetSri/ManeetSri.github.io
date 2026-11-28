import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same rugs
private struct RugRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct CoveredFloorAreaTests {
    /// Compress both axes, then check every cell of the compressed grid against every rug: O(n³).
    private func bruteForce(_ rugs: [[Int]]) -> Int {
        let xs = Array(Set(rugs.flatMap { [$0[0], $0[2]] })).sorted()
        let ys = Array(Set(rugs.flatMap { [$0[1], $0[3]] })).sorted()
        var area = 0
        for i in 0..<max(xs.count - 1, 0) {
            for j in 0..<max(ys.count - 1, 0) {
                let covered = rugs.contains { $0[0] <= xs[i] && xs[i + 1] <= $0[2] && $0[1] <= ys[j] && ys[j + 1] <= $0[3] }
                if covered {
                    area += (xs[i + 1] - xs[i]) * (ys[j + 1] - ys[j])
                }
            }
        }
        return area
    }

    @Test("Examples", arguments: [
        ([[0, 0, 2, 2], [1, 1, 3, 3]], 7),
        ([[0, 2, 6, 4], [2, 0, 4, 6]], 20),
        ([[0, 0, 10, 10], [2, 2, 5, 5]], 100),
        ([[0, 0, 1, 1], [2, 2, 3, 3]], 2),
        ([[0, 0, 2, 1], [2, 0, 4, 1]], 4),
        ([[1, 1, 1, 5], [3, 2, 7, 2]], 0),
        ([[0, 0, 3, 3], [0, 0, 3, 3], [1, 1, 2, 2]], 9),
        ([], 0),
    ] as [([[Int]], Int)])
    func examples(rugs: [[Int]], expected: Int) {
        #expect(CoveredFloorArea.coveredArea(rugs) == expected)
    }

    @Test("One rug the size of the whole floor: 10¹⁸")
    func huge() {
        let big = 1_000_000_000
        #expect(CoveredFloorArea.coveredArea([[0, 0, big, big]]) == big * big)
        #expect(CoveredFloorArea.coveredArea([[0, 0, big, big], [0, 0, big / 2, big], [1, 1, 2, 2]]) == big * big)
    }

    @Test("Matches the compressed grid on 500 small random floors")
    func randomSmall() {
        var random = RugRandom(seed: 65)
        for round in 0..<500 {
            let limit = round < 250 ? 8 : 1_000_000_000
            let rugs = (0..<Int.random(in: 0...12, using: &random)).map { _ -> [Int] in
                let (x1, x2) = (Int.random(in: 0...limit, using: &random), Int.random(in: 0...limit, using: &random))
                let (y1, y2) = (Int.random(in: 0...limit, using: &random), Int.random(in: 0...limit, using: &random))
                return [min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2)]
            }
            #expect(CoveredFloorArea.coveredArea(rugs) == bruteForce(rugs))
        }
    }

    @Test("20,000 rugs with 20,000 different edges")
    func large() {
        // Cut the floor into a 100 × 100 grid of tiles at random positions, lay 5,000 tiles as rugs, and
        // add 15,000 smaller rugs, each inside one of those tiles. The small rugs add no area, but their
        // edges make about 30,000 distinct y values: a sweep that rescans every slab at each event does
        // about a billion steps.
        var random = RugRandom(seed: 20_000)
        let big = 1_000_000_000
        func cuts() -> [Int] {
            var positions: Set<Int> = [0, big]
            while positions.count < 101 {
                positions.insert(Int.random(in: 1..<big, using: &random))
            }
            return positions.sorted()
        }
        let xs = cuts(), ys = cuts()
        var tiles = Set<[Int]>()
        while tiles.count < 5_000 {
            tiles.insert([Int.random(in: 0..<100, using: &random), Int.random(in: 0..<100, using: &random)])
        }
        let laid = tiles.sorted { $0.lexicographicallyPrecedes($1) }
        var rugs = laid.map { [xs[$0[0]], ys[$0[1]], xs[$0[0] + 1], ys[$0[1] + 1]] }
        let expected = rugs.reduce(0) { $0 + ($1[2] - $1[0]) * ($1[3] - $1[1]) }
        for _ in 0..<15_000 {
            let tile = rugs[Int.random(in: 0..<5_000, using: &random)]
            let (x1, x2) = (Int.random(in: tile[0]...tile[2], using: &random), Int.random(in: tile[0]...tile[2], using: &random))
            let (y1, y2) = (Int.random(in: tile[1]...tile[3], using: &random), Int.random(in: tile[1]...tile[3], using: &random))
            rugs.append([min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2)])
        }
        rugs.shuffle(using: &random)
        #expect(CoveredFloorArea.coveredArea(rugs) == expected)
    }

    @Test("20,000 nested squares")
    func nested() {
        var random = RugRandom(seed: 5)
        let centre = 500_000_000
        var largest = 0
        var rugs: [[Int]] = []
        for _ in 0..<20_000 {
            let half = Int.random(in: 1...400_000_000, using: &random)
            largest = max(largest, half)
            rugs.append([centre - half, centre - half, centre + half, centre + half])
        }
        #expect(CoveredFloorArea.coveredArea(rugs) == 4 * largest * largest)
    }
}
