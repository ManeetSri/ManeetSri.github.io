// Reference solution: Filling the sticker album. Expected-value DP over the set of stickers you have,
// as a bitmask. expected[mask] = packs still to open when you hold exactly the stickers in mask, so
// expected[full] = 0. One more pack either repeats a sticker you have (probability `have`, the summed
// probabilities in mask: you stay in mask) or brings a new sticker i (you move to mask | i):
//   expected[mask] = 1 + have · expected[mask] + Σ p[i] · expected[mask | i]
// Solving for expected[mask] removes the self-loop: (1 + Σ p[i] · expected[mask | i]) / (1 - have).
// Bigger masks come first, so fill the table from full - 1 down to 0.
// O(2ⁿ · n) time, O(2ⁿ) space.

public enum StickerAlbumExpectedPacks {
    public static func expectedPacks(weights: [Int]) -> Double {
        let n = weights.count
        let total = Double(weights.reduce(0, +))
        let p = weights.map { Double($0) / total }
        let full = (1 << n) - 1

        var have = [Double](repeating: 0, count: full + 1)    // probability of a sticker already in mask
        for mask in 1...full {                                // weights has at least one sticker
            have[mask] = have[mask & (mask - 1)] + p[mask.trailingZeroBitCount]
        }

        var expected = [Double](repeating: 0, count: full + 1)
        for mask in stride(from: full - 1, through: 0, by: -1) {
            var sum = 1.0
            for i in 0..<n where mask & (1 << i) == 0 {
                sum += p[i] * expected[mask | (1 << i)]
            }
            expected[mask] = sum / (1 - have[mask])
        }
        return expected[0]
    }
}
