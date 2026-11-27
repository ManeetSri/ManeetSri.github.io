import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct TileRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct DistinctTileArrangementsTests {
    /// Every ordering by swapping, with repeats thrown away: slow, but clearly right
    private func reference(_ tiles: String) -> [String] {
        var letters = Array(tiles)
        var seen = Set<String>()
        func permute(_ position: Int) {
            if position == letters.count {
                seen.insert(String(letters))
                return
            }
            for i in position..<letters.count {
                letters.swapAt(position, i)
                permute(position + 1)
                letters.swapAt(position, i)
            }
        }
        permute(0)
        return seen.sorted()
    }

    @Test("Examples and small cases", arguments: [
        ("TOT", ["OTT", "TOT", "TTO"]),
        ("ABC", ["ABC", "ACB", "BAC", "BCA", "CAB", "CBA"]),
        ("Z", ["Z"]),
        ("QQQQ", ["QQQQ"]),
        ("ABAB", ["AABB", "ABAB", "ABBA", "BAAB", "BABA", "BBAA"]),
    ] as [(String, [String])])
    func examples(tiles: String, expected: [String]) {
        #expect(DistinctTileArrangements.arrangements(of: tiles).sorted() == expected)
    }

    @Test("Matches brute force on 300 random tile sets")
    func randomSmall() {
        var random = TileRandom(seed: 48)
        let alphabet = Array("ABCD")
        for _ in 0..<300 {
            let tiles = String((0..<Int.random(in: 1...7, using: &random)).map { _ in
                alphabet[Int.random(in: 0..<Int.random(in: 1...4, using: &random), using: &random)]
            })
            #expect(DistinctTileArrangements.arrangements(of: tiles).sorted() == reference(tiles), "tiles \(tiles)")
        }
    }

    @Test("Nine A tiles and three B tiles: 220 arrangements, though 12! orderings exist")
    func manyEqualTiles() {
        let result = DistinctTileArrangements.arrangements(of: "AAAAAAAAABBB")
        var expected: [String] = []
        for first in 0..<12 {
            for second in (first + 1)..<12 {
                for third in (second + 1)..<12 {
                    expected.append(String((0..<12).map { [first, second, third].contains($0) ? "B" : "A" }))
                }
            }
        }
        #expect(result.sorted() == expected.sorted())
    }

    @Test("MISSISSIPPI has 34,650 distinct arrangements")
    func mississippi() {
        let result = DistinctTileArrangements.arrangements(of: "MISSISSIPPI")
        #expect(result.count == 34_650)
        #expect(Set(result).count == 34_650)
        #expect(result.allSatisfy { $0.sorted() == "MISSISSIPPI".sorted() })
    }
}
