import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BannerRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct PalindromeBannerCutsTests {
    /// Tries every set of cut positions and keeps the smallest one whose pieces are all palindromes
    private func bruteForce(_ banner: String) -> Int {
        let s = Array(banner)
        guard s.count > 1 else { return 0 }
        var best = s.count - 1
        for mask in 0..<(1 << (s.count - 1)) {             // bit i: cut after letter i
            var start = 0
            var valid = true
            for end in 0..<s.count where end == s.count - 1 || mask & (1 << end) != 0 {
                let piece = Array(s[start...end])
                if piece != piece.reversed() {
                    valid = false
                    break
                }
                start = end + 1
            }
            if valid {
                best = min(best, mask.nonzeroBitCount)
            }
        }
        return best
    }

    /// A different algorithm for long banners: expand around every centre, updating the fewest cuts
    /// for each prefix as palindromes are found, with no table of palindromes
    private func reference(_ banner: String) -> Int {
        let s = Array(banner)
        let n = s.count
        guard n > 0 else { return 0 }
        var cuts = Array(0..<n)
        for centre in 0..<n {
            for (startLeft, startRight) in [(centre, centre), (centre, centre + 1)] {
                var l = startLeft
                var r = startRight
                while l >= 0 && r < n && s[l] == s[r] {
                    cuts[r] = min(cuts[r], l == 0 ? 0 : cuts[l - 1] + 1)
                    l -= 1
                    r += 1
                }
            }
        }
        return cuts[n - 1]
    }

    private func randomBanner(_ length: Int, letters: [Character], using random: inout BannerRandom) -> String {
        String((0..<length).map { _ in letters.randomElement(using: &random)! })
    }

    @Test("Examples and edge cases", arguments: [
        ("noonabbad", 2),
        ("racecarannakayak", 2),
        ("abcbm", 2),
        ("abaab", 1),
        ("abcd", 3),
        ("level", 0),
        ("aab", 1),
        ("a", 0),
        ("", 0),
    ])
    func examples(banner: String, expected: Int) {
        #expect(PalindromeBannerCuts.fewestCuts(banner) == expected)
    }

    @Test("Matches brute force on 400 short banners")
    func randomSmall() {
        var random = BannerRandom(seed: 58)
        for _ in 0..<400 {
            let letters: [Character] = Bool.random(using: &random) ? ["a", "b"] : ["a", "b", "c"]
            let banner = randomBanner(Int.random(in: 0...12, using: &random), letters: letters, using: &random)
            #expect(PalindromeBannerCuts.fewestCuts(banner) == bruteForce(banner), "banner: \(banner)")
        }
    }

    @Test("1,000-letter banners")
    func large() {
        #expect(PalindromeBannerCuts.fewestCuts(String(repeating: "a", count: 1_000)) == 0)
        // "abab…ab": the first 999 letters read the same both ways, then one cut for the last b
        #expect(PalindromeBannerCuts.fewestCuts(String(repeating: "ab", count: 500)) == 1)
        // The alphabet over and over has no palindrome longer than one letter
        let alphabet = Array("abcdefghijklmnopqrstuvwxyz")
        let cycle = String((0..<1_000).map { alphabet[$0 % 26] })
        #expect(PalindromeBannerCuts.fewestCuts(cycle) == 999)

        var random = BannerRandom(seed: 1_000)
        for letters in [Array("ab"), Array("abc")] {
            let banner = randomBanner(1_000, letters: letters, using: &random)
            #expect(PalindromeBannerCuts.fewestCuts(banner) == reference(banner))
        }
    }
}
