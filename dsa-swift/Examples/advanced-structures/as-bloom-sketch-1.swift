// Generated from src/dsa/content/lessons/advanced-structures/as-bloom-sketch.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

// FNV-1a: a simple, fixed hash of a string's UTF-8 bytes. Same answer on every run and every device.
func fnv1a(_ text: String) -> UInt64 {
    var hash: UInt64 = 0xcbf2_9ce4_8422_2325
    for byte in text.utf8 {
        hash ^= UInt64(byte)
        hash = hash &* 0x0000_0100_0000_01B3
    }
    return hash
}

// SplitMix64's finishing step: spreads every input bit across the whole output
func mix(_ x: UInt64) -> UInt64 {
    var z = x
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z >> 31)
}

struct BloomFilter {
    let bitCount: Int
    let hashCount: Int
    private var words: [UInt64]

    init(bitCount: Int, hashCount: Int) {
        self.bitCount = bitCount
        self.hashCount = hashCount
        words = Array(repeating: 0, count: (bitCount + 63) / 64)
    }

    // k bit positions from two hashes: h1, h1 + h2, h1 + 2·h2, … (double hashing)
    private func positions(of item: String) -> [Int] {
        let h1 = mix(fnv1a(item))
        let h2 = mix(h1 ^ 0x9E37_79B9_7F4A_7C15) | 1      // odd, so never 0
        return (0..<hashCount).map { Int((h1 &+ UInt64($0) &* h2) % UInt64(bitCount)) }
    }

    mutating func insert(_ item: String) {
        for bit in positions(of: item) {
            words[bit >> 6] |= 1 << (bit & 63)
        }
    }

    // false means definitely absent; true means probably present
    func mightContain(_ item: String) -> Bool {
        positions(of: item).allSatisfy { words[$0 >> 6] & (1 << ($0 & 63)) != 0 }
    }

    var bitsSet: Int {
        words.reduce(0) { $0 + $1.nonzeroBitCount }
    }
}

var taken = BloomFilter(bitCount: 10_000, hashCount: 7)    // 1,250 bytes
for i in 0..<1_000 {
    taken.insert("user\(i)")
}
print("bits set:", taken.bitsSet, "of", taken.bitCount)
print("user42:", taken.mightContain("user42"), " user999:", taken.mightContain("user999"))
print("every inserted name found:", (0..<1_000).allSatisfy { taken.mightContain("user\($0)") })

let falsePositives = (0..<10_000).filter { taken.mightContain("guest\($0)") }.count
let predicted = pow(1 - exp(-7.0 * 1_000 / 10_000), 7)
print("false positives:", falsePositives, "of 10000 =", String(format: "%.2f%%", Double(falsePositives) / 100))
print("formula predicts:", String(format: "%.2f%%", predicted * 100))
