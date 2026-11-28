import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct OrchardRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TwoWalkerCherryHarvestTests {
    /// Try every pair of routes there and back, counting each cell once
    private func everyPair(_ orchard: [[Int]]) -> Int {
        let n = orchard.count
        var routes: [[Int]] = []                     // each route as a list of cell numbers r * n + c
        func walk(_ r: Int, _ c: Int, _ cells: [Int]) {
            if r >= n || c >= n || orchard[r][c] == -1 { return }
            let cells = cells + [r * n + c]
            if r == n - 1 && c == n - 1 {
                routes.append(cells)
                return
            }
            walk(r, c + 1, cells)
            walk(r + 1, c, cells)
        }
        walk(0, 0, [])
        var best = 0
        for there in routes {
            for back in routes {
                let cells = Set(there).union(back)
                best = max(best, cells.reduce(0) { $0 + orchard[$1 / n][$1 % n] })
            }
        }
        return best
    }

    /// A different method: top-down memoisation over both walkers' positions, from the end backwards
    private func memoised(_ orchard: [[Int]]) -> Int {
        let n = orchard.count
        let impossible = Int.min / 2
        var memo = [Int: Int]()
        func best(_ r1: Int, _ c1: Int, _ r2: Int) -> Int {
            let c2 = r1 + c1 - r2
            if r1 >= n || c1 >= n || r2 >= n || c2 >= n || orchard[r1][c1] == -1 || orchard[r2][c2] == -1 {
                return impossible
            }
            let here = r1 == r2 ? orchard[r1][c1] : orchard[r1][c1] + orchard[r2][c2]
            if r1 == n - 1 && c1 == n - 1 { return here }
            let key = (r1 * n + c1) * n + r2
            if let known = memo[key] { return known }
            let onward = max(best(r1 + 1, c1, r2 + 1), best(r1 + 1, c1, r2), best(r1, c1 + 1, r2 + 1), best(r1, c1 + 1, r2))
            let result = onward == impossible ? impossible : here + onward
            memo[key] = result
            return result
        }
        return max(0, best(0, 0, 0))
    }

    @Test("Examples and small orchards", arguments: [
        ([[1, 0, 1, 0, 0], [1, 0, 0, 0, 0], [1, 1, 1, 1, 1], [0, 0, 0, 0, 1], [0, 1, 0, 0, 1]], 11),
        ([[1]], 1),
        ([[0]], 0),
        ([[-1]], 0),
        ([[1, -1], [-1, 1]], 0),
        ([[1, 1, -1], [1, -1, 1], [0, 1, 1]], 4),
        ([[0, 1], [1, 0]], 2),
        ([[1, 1], [1, 1]], 4),
        ([[1, 1, 1], [1, 1, 1], [1, 1, -1]], 0),
    ] as [([[Int]], Int)])
    func examples(orchard: [[Int]], expected: Int) {
        #expect(TwoWalkerCherryHarvest.maxCherries(orchard) == expected)
    }

    @Test("Two greedy walks get 10 here; planning both together gets all 11")
    func greedyFails() {
        let orchard = [
            [1, 0, 1, 0, 0],
            [1, 0, 0, 0, 0],
            [1, 1, 1, 1, 1],
            [0, 0, 0, 0, 1],
            [0, 1, 0, 0, 1],
        ]
        #expect(TwoWalkerCherryHarvest.maxCherries(orchard) == 11)
    }

    @Test("Matches trying every pair of routes on 300 small random orchards")
    func randomSmall() {
        var random = OrchardRandom(seed: 741)
        for _ in 0..<300 {
            let n = Int.random(in: 1...5, using: &random)
            let thornChance = Int.random(in: 0...25, using: &random)
            let orchard = (0..<n).map { _ in
                (0..<n).map { _ -> Int in
                    let roll = Int.random(in: 0..<100, using: &random)
                    return roll < thornChance ? -1 : (roll < 60 ? 1 : 0)
                }
            }
            #expect(TwoWalkerCherryHarvest.maxCherries(orchard) == everyPair(orchard))
        }
    }

    @Test("A 50 × 50 orchard full of cherries: two routes that only share their ends")
    func fullOrchard() {
        let orchard = Array(repeating: Array(repeating: 1, count: 50), count: 50)
        #expect(TwoWalkerCherryHarvest.maxCherries(orchard) == 2 * 99 - 2)
    }

    @Test("50 × 50 random orchards match memoised search", arguments: [0, 5, 12])
    func largeRandom(thornChance: Int) {
        var random = OrchardRandom(seed: UInt64(50 + thornChance))
        var orchard = (0..<50).map { _ in
            (0..<50).map { _ -> Int in
                let roll = Int.random(in: 0..<100, using: &random)
                return roll < thornChance ? -1 : (roll < 50 ? 1 : 0)
            }
        }
        orchard[0][0] = 0
        orchard[49][49] = 0
        #expect(TwoWalkerCherryHarvest.maxCherries(orchard) == memoised(orchard))
    }
}
