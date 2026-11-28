import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PolynomialStringHashTests {
    @Test("Hashes short strings with base 31", arguments: [
        ("a", 97),
        ("ab", 3105),
        ("abc", 96354),
        ("hash", 3195150),
    ])
    func base31(text: String, expected: Int) {
        #expect(PolynomialStringHash.hash(of: text, base: 31, modulus: 1_000_000_007) == expected)
    }

    @Test("The empty string hashes to 0")
    func empty() {
        #expect(PolynomialStringHash.hash(of: "", base: 31, modulus: 1_000_000_007) == 0)
        #expect(PolynomialStringHash.hash(of: "", base: 7, modulus: 13) == 0)
    }

    @Test("Takes the remainder by the modulus")
    func smallModulus() {
        #expect(PolynomialStringHash.hash(of: "abc", base: 31, modulus: 7) == 6)
        #expect(PolynomialStringHash.hash(of: "abc", base: 10, modulus: 1_000) == 779)
        #expect(PolynomialStringHash.hash(of: "anything", base: 31, modulus: 1) == 0)
    }

    @Test("Works on Unicode scalars, so é written two ways hashes differently")
    func unicodeScalars() {
        #expect(PolynomialStringHash.hash(of: "\u{E9}", base: 31, modulus: 1_000_000_007) == 233)
        #expect(PolynomialStringHash.hash(of: "e\u{301}", base: 31, modulus: 1_000_000_007) == 3900)
    }

    @Test("Order matters: anagrams get different hashes")
    func orderMatters() {
        let hashes = ["stop", "pots", "tops", "spot"].map {
            PolynomialStringHash.hash(of: $0, base: 31, modulus: 1_000_000_007)
        }
        #expect(Set(hashes).count == 4)
    }

    @Test("Never overflows on 100,000 characters")
    func longText() {
        let text = String(repeating: "zebra", count: 20_000)
        var expected = 0
        for scalar in text.unicodeScalars {
            expected = (expected * 1_000_000 + Int(scalar.value)) % 1_000_000_007
        }
        #expect(PolynomialStringHash.hash(of: text, base: 1_000_000, modulus: 1_000_000_007) == expected)
        // With base 1 the hash is the sum of the scalar values
        #expect(PolynomialStringHash.hash(of: text, base: 1, modulus: 1_000_000_007) == 20_000 * (122 + 101 + 98 + 114 + 97))
    }

    @Test("Counts the words in each bucket")
    func buckets() {
        #expect(PolynomialStringHash.bucketSizes(for: ["stop", "pots", "tops", "spot", "opts", "post"], bucketCount: 8)
            == [2, 0, 2, 0, 0, 0, 2, 0])
        #expect(PolynomialStringHash.bucketSizes(for: ["apple", "banana", "cherry", "date", "elder", "fig", "grape", "kiwi"], bucketCount: 5)
            == [2, 1, 1, 1, 3])
        #expect(PolynomialStringHash.bucketSizes(for: [], bucketCount: 3) == [0, 0, 0])
        #expect(PolynomialStringHash.bucketSizes(for: ["a", "a", "a"], bucketCount: 1) == [3])
    }

    @Test("Every word lands in exactly one bucket")
    func bucketTotals() {
        let words = (0..<1_000).map { "word\($0)" }
        let sizes = PolynomialStringHash.bucketSizes(for: words, bucketCount: 97)
        #expect(sizes.count == 97)
        #expect(sizes.reduce(0, +) == 1_000)
    }
}
