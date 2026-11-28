import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BoxRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct NestingGiftBoxesTests {
    /// Can `inner` be turned to fit strictly inside `outer`? Checks both ways round.
    private func fits(_ inner: [Int], inside outer: [Int]) -> Bool {
        (inner[0] < outer[0] && inner[1] < outer[1]) || (inner[0] < outer[1] && inner[1] < outer[0])
    }

    /// Longest chain by the O(n²) DP, using the fits check directly. A box that fits inside another has a
    /// strictly smaller base area, so sorting by area puts every possible inner box first.
    private func reference(_ boxes: [[Int]]) -> Int {
        let sorted = boxes.sorted { $0[0] * $0[1] < $1[0] * $1[1] }
        var depth = Array(repeating: 1, count: sorted.count)
        for i in sorted.indices {
            for j in 0..<i where fits(sorted[j], inside: sorted[i]) {
                depth[i] = max(depth[i], depth[j] + 1)
            }
        }
        return depth.max() ?? 0
    }

    /// Writes each box's sides in a random order, since boxes may be listed either way round
    private func randomlyTurned(_ boxes: [[Int]], using random: inout BoxRandom) -> [[Int]] {
        boxes.map { Bool.random(using: &random) ? $0 : [$0[1], $0[0]] }
    }

    @Test("Examples and edge cases", arguments: [
        ([[5, 4], [6, 4], [6, 7], [2, 3]], 3),
        ([[8, 3], [4, 9]], 2),
        ([[3, 8], [9, 2], [4, 7]], 1),
        ([[2, 5], [5, 2], [3, 6]], 2),
        ([[1, 1], [1, 1], [1, 1]], 1),
        ([[4, 4], [4, 5], [4, 6], [4, 7]], 1),
        ([[1, 9], [2, 8], [3, 7], [4, 6]], 1),
        ([[7, 7]], 1),
        ([], 0),
    ] as [([[Int]], Int)])
    func examples(boxes: [[Int]], expected: Int) {
        #expect(NestingGiftBoxes.deepestNesting(boxes) == expected)
    }

    @Test("Matches the O(n²) check on 500 small inputs full of ties")
    func randomSmall() {
        var random = BoxRandom(seed: 56)
        for _ in 0..<500 {
            let boxes = (0..<Int.random(in: 0...9, using: &random)).map { _ in
                [Int.random(in: 1...6, using: &random), Int.random(in: 1...6, using: &random)]
            }
            #expect(NestingGiftBoxes.deepestNesting(boxes) == reference(boxes), "boxes: \(boxes)")
        }
    }

    @Test("Matches the O(n²) check on 1,500 boxes")
    func medium() {
        var random = BoxRandom(seed: 1_500)
        for maxSide in [1_000, 60] {
            let boxes = (0..<1_500).map { _ in
                [Int.random(in: 1...maxSide, using: &random), Int.random(in: 1...maxSide, using: &random)]
            }
            #expect(NestingGiftBoxes.deepestNesting(boxes) == reference(boxes))
        }
    }

    @Test("100,000 boxes with a known answer (needs O(n log n))")
    func large() {
        var random = BoxRandom(seed: 100_000)

        // Levels: every box on level t has shorter side 1,000·t and a longer side below the next level's
        // shorter side. Boxes on one level can't nest (equal shorter sides), and every box fits inside
        // every box on a higher level, so the deepest nesting takes one box per level.
        var leveled: [[Int]] = []
        var levels = 0
        while leveled.count < 100_000 {
            levels += 1
            let short = 1_000 * levels
            for _ in 0..<Int.random(in: 1...80, using: &random) where leveled.count < 100_000 {
                leveled.append([short, short + Int.random(in: 0...999, using: &random)])
            }
        }
        leveled.shuffle(using: &random)
        #expect(NestingGiftBoxes.deepestNesting(randomlyTurned(leveled, using: &random)) == levels)

        // The tie trap: equal shorter sides with rising longer sides can't nest at all
        let sameShort = (0..<100_000).map { [5, 10 + $0] }.shuffled(using: &random)
        #expect(NestingGiftBoxes.deepestNesting(randomlyTurned(sameShort, using: &random)) == 1)

        // Every box fits inside the next
        let chain = (0..<100_000).map { [$0 + 1, $0 + 3] }.shuffled(using: &random)
        #expect(NestingGiftBoxes.deepestNesting(randomlyTurned(chain, using: &random)) == 100_000)
    }
}
