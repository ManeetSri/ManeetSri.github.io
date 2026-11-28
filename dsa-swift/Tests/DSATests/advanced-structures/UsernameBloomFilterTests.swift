import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The statement's recipe, written out independently, so the tests know exactly which bits to expect.
private enum Recipe {
    static func fnv1a(_ text: String) -> UInt64 {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01B3
        }
        return hash
    }

    static func mix(_ x: UInt64) -> UInt64 {
        var z = x
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    static func positions(_ name: String, _ m: Int, _ k: Int) -> [Int] {
        let h1 = mix(fnv1a(name))
        let h2 = mix(h1 ^ 0x9E37_79B9_7F4A_7C15) | 1
        return (0..<k).map { Int((h1 &+ UInt64($0) &* h2) % UInt64(m)) }
    }

    /// The words a filter should hold after inserting `names`.
    static func words(_ names: [String], _ m: Int, _ k: Int) -> [UInt64] {
        var words = Array(repeating: UInt64(0), count: (m + 63) / 64)
        for name in names {
            for bit in positions(name, m, k) {
                words[bit / 64] |= UInt64(1) << UInt64(bit % 64)
            }
        }
        return words
    }
}

@Suite struct UsernameBloomFilterTests {
    @Test("positions follows the double-hashing recipe", arguments: [
        ("maneet", 10_000, 7), ("", 64, 3), ("swift", 100, 5), ("ü-ñ-🙂", 1_000_003, 10), ("a", 1, 4),
    ] as [(String, Int, Int)])
    func positions(name: String, bitCount: Int, hashCount: Int) {
        #expect(UsernameBloomFilter.Filter.positions(of: name, bitCount: bitCount, hashCount: hashCount)
                == Recipe.positions(name, bitCount, hashCount))
    }

    @Test("A new filter has every bit clear")
    func empty() {
        let filter = UsernameBloomFilter.Filter(bitCount: 130, hashCount: 4)
        #expect(filter.words == [0, 0, 0])
        #expect(filter.setBitCount == 0)
        #expect(!filter.mightContain("anyone"))
        #expect(filter.estimatedFalsePositiveRate == 0)
    }

    @Test("Inserting sets exactly the recipe's bits", arguments: [64, 100, 1_000, 12_345])
    func insertSetsBits(bitCount: Int) {
        var filter = UsernameBloomFilter.Filter(bitCount: bitCount, hashCount: 5)
        let names = (0..<40).map { "user\($0)" }
        for name in names {
            filter.insert(name)
        }
        #expect(filter.words == Recipe.words(names, bitCount, 5))
        #expect(filter.setBitCount == Recipe.words(names, bitCount, 5).reduce(0) { $0 + $1.nonzeroBitCount })
    }

    @Test("Answers maybe exactly when every bit is set, and never misses an inserted name")
    func queries() {
        let m = 2_000, k = 4
        var filter = UsernameBloomFilter.Filter(bitCount: m, hashCount: k)
        let inserted = (0..<300).map { "taken\($0)" }
        for name in inserted {
            filter.insert(name)
        }
        let words = Recipe.words(inserted, m, k)
        #expect(inserted.allSatisfy { filter.mightContain($0) }, "no false negatives")
        for i in 0..<3_000 {
            let name = "free\(i)"
            let expected = Recipe.positions(name, m, k).allSatisfy { words[$0 / 64] & (UInt64(1) << UInt64($0 % 64)) != 0 }
            if filter.mightContain(name) != expected {
                Issue.record("mightContain(\(name)) should be \(expected)")
                return
            }
        }
    }

    @Test("The false positive rate matches the formula")
    func falsePositiveRate() {
        // m = 20,000, n = 2,000, k = 7: about 50.3% of the bits set, and a rate of about 0.82%
        var filter = UsernameBloomFilter.Filter(bitCount: 20_000, hashCount: 7)
        for i in 0..<2_000 {
            filter.insert("member\(i)")
        }
        let fraction = Double(filter.setBitCount) / 20_000
        #expect(fraction > 0.48 && fraction < 0.53)
        var expectedRate = 1.0
        for _ in 0..<7 { expectedRate *= fraction }
        #expect(abs(filter.estimatedFalsePositiveRate - expectedRate) < 1e-12)
        let falsePositives = (0..<20_000).filter { filter.mightContain("visitor\($0)") }.count
        #expect(falsePositives > 80 && falsePositives < 280, "about 0.82% of 20,000, measured \(falsePositives)")
    }

    @Test("bestHashCount rounds (m / n) · ln 2", arguments: [
        (10_000, 1_000, 7), (8_000, 1_000, 6), (14_378, 1_000, 10), (1_000, 1_000, 1), (100, 1_000, 1),
        (1_000_000, 100_000, 7), (20, 2, 7),
    ])
    func bestHashCount(bitCount: Int, expectedCount: Int, expected: Int) {
        #expect(UsernameBloomFilter.bestHashCount(bitCount: bitCount, expectedCount: expectedCount) == expected)
    }

    @Test("formUnion holds the names of both filters")
    func union() {
        var first = UsernameBloomFilter.Filter(bitCount: 5_000, hashCount: 6)
        var second = UsernameBloomFilter.Filter(bitCount: 5_000, hashCount: 6)
        let a = (0..<200).map { "ios\($0)" }
        let b = (0..<200).map { "mac\($0)" }
        a.forEach { first.insert($0) }
        b.forEach { second.insert($0) }
        first.formUnion(second)
        #expect(first.words == Recipe.words(a + b, 5_000, 6))
        #expect((a + b).allSatisfy { first.mightContain($0) })
    }

    @Test("100,000 names in a million bits")
    func large() {
        var filter = UsernameBloomFilter.Filter(bitCount: 1_000_000, hashCount: 7)
        for i in 0..<100_000 {
            filter.insert("name\(i)")
        }
        #expect((0..<100_000).allSatisfy { filter.mightContain("name\($0)") })
        let falsePositives = (0..<100_000).filter { filter.mightContain("other\($0)") }.count
        #expect(falsePositives > 400 && falsePositives < 1_400, "about 0.82%, measured \(falsePositives)")
        #expect(filter.words.count == 15_625)
    }
}
