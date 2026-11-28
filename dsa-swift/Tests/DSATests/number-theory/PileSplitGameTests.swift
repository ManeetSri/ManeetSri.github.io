import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct PileRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

/// Searches the whole game: a position is a win if some move leads to a loss. Positions are stored
/// as sorted lists of non-empty piles, so equal positions share one entry.
private final class PileGameSearch {
    let removals: [Int]
    var memo: [[Int]: Bool] = [:]

    init(removals: [Int]) {
        self.removals = removals
    }

    func wins(_ position: [Int]) -> Bool {
        let piles = position.filter { $0 > 0 }.sorted()
        if let known = memo[piles] { return known }
        var result = false
        search: for (i, pile) in piles.enumerated() {
            var rest = piles
            rest.remove(at: i)
            for s in removals where s <= pile && !wins(rest + [pile - s]) {
                result = true
                break search
            }
            var a = 1
            while a < pile - a {
                if !wins(rest + [a, pile - a]) {
                    result = true
                    break search
                }
                a += 1
            }
        }
        memo[piles] = result
        return result
    }
}

@Suite struct PileSplitGameTests {
    /// Grundy numbers written independently of any solution: the mex of each pile's options
    private func grundyNumbers(upTo limit: Int, removals: [Int]) -> [Int] {
        var grundy: [Int] = []
        for n in 0...limit {
            var present = Array(repeating: false, count: n + removals.count + 2)
            for s in removals where s <= n { present[grundy[n - s]] = true }
            for a in stride(from: 1, to: n, by: 1) where a < n - a {
                let value = grundy[a] ^ grundy[n - a]
                if value < present.count { present[value] = true }
            }
            grundy.append(present.firstIndex(of: false)!)
        }
        return grundy
    }

    @Test("Examples", arguments: [
        ([3], [], true),
        ([1, 2], [], false),
        ([4], [], false),
        ([5], [], true),
        ([3, 6], [], false),
        ([0, 0], [1, 2], false),
        ([2], [1], false),
        ([3], [1], true),
        ([7], [2, 5], true),
        ([1, 4, 8], [2, 5], false),
        ([2000], [], true),
    ] as [([Int], [Int], Bool)])
    func examples(piles: [Int], removals: [Int], expected: Bool) {
        #expect(PileSplitGame.firstPlayerWins(piles: piles, removals: removals) == expected)
    }

    @Test("Matches a full game search on small positions")
    func bruteForce() {
        var random = PileRandom(seed: 9)
        let removalSets: [[Int]] = [[], [1], [2], [1, 2], [2, 3], [1, 3, 4], [2, 5], [4]]
            + (0..<6).map { _ in (1...5).filter { _ in Bool.random(using: &random) } }
        for removals in removalSets {
            let search = PileGameSearch(removals: removals)
            for _ in 0..<40 {
                let piles = (0..<Int.random(in: 1...3, using: &random)).map { _ in Int.random(in: 0...7, using: &random) }
                #expect(PileSplitGame.firstPlayerWins(piles: piles, removals: removals) == search.wins(piles),
                        "piles \(piles), removals \(removals)")
            }
        }
    }

    @Test("Ten thousand piles of up to 2,000 stones")
    func large() {
        var random = PileRandom(seed: 2_000)
        for removals in [[], [3, 7, 11, 200], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [1_999, 2_000]] {
            let grundy = grundyNumbers(upTo: 2_000, removals: removals)
            var piles = (0..<10_000).map { _ in Int.random(in: 0...2_000, using: &random) }
            piles[0] = 2_000
            let total = piles.reduce(0) { $0 ^ grundy[$1] }
            #expect(PileSplitGame.firstPlayerWins(piles: piles, removals: removals) == (total != 0), "removals \(removals)")
            // Add one pile that cancels the XOR, if one exists: now the first player loses
            if let cancel = (0...2_000).first(where: { grundy[$0] == total }) {
                piles.append(cancel)
                #expect(PileSplitGame.firstPlayerWins(piles: piles, removals: removals) == false, "removals \(removals)")
            }
        }
    }
}
