import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NearestCafesTests {
    /// True if `chosen` is k different valid indexes, and no café left out is nearer than a chosen one.
    private static func isNearest(_ chosen: [Int], of cafes: [(x: Int, y: Int)], k: Int) -> Bool {
        guard chosen.count == k, Set(chosen).count == k, chosen.allSatisfy({ cafes.indices.contains($0) }) else {
            return false
        }
        let distance = cafes.map { $0.x * $0.x + $0.y * $0.y }
        let picked = Set(chosen)
        let furthestChosen = chosen.map { distance[$0] }.max() ?? Int.min
        let nearestLeftOut = cafes.indices.filter { !picked.contains($0) }.map { distance[$0] }.min() ?? Int.max
        return furthestChosen <= nearestLeftOut
    }

    @Test("Finds the nearest cafés")
    func examples() {
        let cafes = [(x: 3, y: 4), (x: -1, y: 1), (x: 6, y: -2), (x: 0, y: -2)]
        #expect(Set(NearestCafes.nearest(cafes, count: 1)) == [1])
        #expect(Set(NearestCafes.nearest(cafes, count: 2)) == [1, 3])
        #expect(Set(NearestCafes.nearest(cafes, count: 3)) == [0, 1, 3])
        #expect(Set(NearestCafes.nearest(cafes, count: 4)) == [0, 1, 2, 3])
    }

    @Test("A single café")
    func single() {
        #expect(NearestCafes.nearest([(x: 5, y: 5)], count: 1) == [0])
    }

    @Test("Ties at the cut can go either way")
    func ties() {
        let cafes = [(x: 2, y: 0), (x: 0, y: 2), (x: 1, y: 0), (x: -2, y: 0), (x: 0, y: 9)]
        let chosen = NearestCafes.nearest(cafes, count: 2)
        #expect(chosen.contains(2))
        #expect(Self.isNearest(chosen, of: cafes, k: 2))
    }

    @Test("Correct on hundreds of scattered maps")
    func manyMaps() {
        var failures = 0
        for seed in 1...150 {
            let count = 1 + seed % 25
            let cafes = (0..<count).map { (x: ($0 * 37 + seed * 11) % 13 - 6, y: ($0 * 53 + seed * 7) % 11 - 5) }
            for k in 1...count where !Self.isNearest(NearestCafes.nearest(cafes, count: k), of: cafes, k: k) {
                failures += 1
            }
        }
        #expect(failures == 0)
    }

    @Test("100,000 cafés along one street, already nearest first")
    func largeSortedStreet() {
        let cafes = (0..<100_000).map { (x: $0, y: 0) }
        let chosen = NearestCafes.nearest(cafes, count: 50_000)
        #expect(Set(chosen) == Set(0..<50_000))
    }

    @Test("100,000 cafés, all the same distance away")
    func largeAllTied() {
        let spots = [(x: 5, y: 0), (x: 3, y: 4), (x: 0, y: -5), (x: -4, y: 3)]   // all 5 away
        let cafes = (0..<100_000).map { spots[$0 % 4] }
        let chosen = NearestCafes.nearest(cafes, count: 30_000)
        #expect(chosen.count == 30_000)
        #expect(Set(chosen).count == 30_000)
    }

    @Test("100,000 scattered cafés")
    func largeScattered() {
        let cafes = (0..<100_000).map { (x: ($0 * 7_919) % 20_001 - 10_000, y: ($0 * 104_729) % 20_001 - 10_000) }
        let chosen = NearestCafes.nearest(cafes, count: 1_000)
        #expect(Self.isNearest(chosen, of: cafes, k: 1_000))
    }
}
