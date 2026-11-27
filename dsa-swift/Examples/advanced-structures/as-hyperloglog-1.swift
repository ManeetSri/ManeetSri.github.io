// Generated from src/dsa/content/lessons/advanced-structures/as-hyperloglog.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A fixed 64-bit hash for integer ids: SplitMix64's mixing steps
func hash(_ id: Int) -> UInt64 {
    var z = UInt64(bitPattern: Int64(id)) &+ 0x9E37_79B9_7F4A_7C15
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z >> 31)
}

// Leading zeros of a few hashes: about half have none, a quarter have one, an eighth two…
for id in 1...6 {
    let bits = String(hash(id), radix: 2)
    let padded = String(repeating: "0", count: 64 - bits.count) + bits
    print(id, padded.prefix(12) + "…", "leading zeros:", hash(id).leadingZeroBitCount)
}

// The most leading zeros seen among n distinct ids, and the guess 2^most
for n in [10, 100, 1_000, 10_000, 100_000, 1_000_000] {
    var most = 0
    for id in 0..<n {
        most = max(most, hash(id).leadingZeroBitCount)
    }
    print("n = \(n): most leading zeros \(most), guess 2^\(most) = \(1 << most)")
}
